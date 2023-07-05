extends Node2D

signal appear_finished
signal enemy_died
signal attack_message
signal clear_message
signal attack
signal gp

var part_count = 0
var appear_count = 0

var big_slimes = []
var big_slime_speed = 100

enum big_slime_states{INTACT, BROKEN}
enum slime_ids{BIG, SMALL}

## attack variables ##
var player
var start_poisoning_timer

func _ready():
	deactivate()
	player = get_parent().get_parent()
	$slime_big.connect("broken_timeout", self, "rebuild_big_slime")
	$slime_big2.connect("broken_timeout", self, "rebuild_big_slime")
	
#	for big_slime in get_children():
#		big_slime.start_poisoning_timer = Timer.new()
#		big_slime.start_poisoning_timer.wait_time = 0.5
#		big_slime.start_poisoning_timer.one_shot = true
#		big_slime.start_poisoning_timer.connect("timeout", self, "ooze_poison", [big_slime])
#		big_slime.add_child(big_slime.start_poisoning_timer)
	
	

func activate():
	big_slimes = []
	for big_slime in get_children():
		big_slimes.append(big_slime)
		big_slime.disable_collisionshape(false)
		big_slime.state = big_slime_states.INTACT
		big_slime.id = slime_ids.BIG
		big_slime.oozing_poison = false
		
		
		for small_slime in big_slime.get_small_slimes().get_children():
			small_slime.id = slime_ids.SMALL
			part_count += 1
		
		appear_count += 1
		
		var ap = big_slime.get_node("AnimationPlayer")
		ap.connect("animation_finished", self, "on_animation_finished", [big_slime])
		ap.play("appear")

func deactivate():
	for big_slime in get_children():
		big_slime.disable_collisionshape(true)
		for small_slime in big_slime.get_small_slimes().get_children():
			small_slime.disable_collisionshape(true)
	appear_count = 0
	
	set_process(false)

func on_animation_finished(anim, slime):
	if anim == "appear":
		appear_count -= 1
		slime.poisoning_timer.start()
		if appear_count == 0:
			set_process(true)
			emit_signal("appear_finished")

func _process(delta):
	for big_slime in big_slimes:
		if big_slime.state == big_slime_states.INTACT:
			var pf = big_slime.get_node("Path2D/PathFollow2D")
			pf.set_offset(pf.get_offset()+big_slime_speed*delta)
	
	attack_update(delta)

func attack_update(delta):
	var intact_big_slimes = big_slimes.size()
	for big_slime in big_slimes:
		if big_slime.state == big_slime_states.BROKEN:
			intact_big_slimes -= 1
	if intact_big_slimes == 0:
		player.remove_poisoning()

func ooze_poison(big_slime):
	print("slime oozes poison")
	#emit_signal("attack_message", "slime oozes poison")
	#emit_signal("attack", EnemyStuff.attack_types.POISON, 0)
	big_slime.get_node("AnimationPlayer").play("ooze_poison_attack", -1, 2)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	part.get_node("AnimationPlayer").play("damaged", -1, 4)
	
	if part.id == slime_ids.BIG:
		if part.hp <= 0:
			switch_to_small_slimes(part)
	
	if part.id == slime_ids.SMALL:
		if part.hp <= 0:
			part.disable_collisionshape(true)
			part.hide()
			part_count -= 1
			emit_signal("gp", 1)
			
				#big_slime.hide()
	
	#check for dead big slimes
#	for big_slime in big_slimes:
#		var all_dead = true
#		for small_slime in big_slime.get_small_slimes().get_children():
#			if small_slime.hp > 0:
#				all_dead = false
	
	if part_count == 0:
		emit_signal("enemy_died")

func switch_to_small_slimes(big_slime):
	big_slime.get_node("Path2D").hide()
	big_slime.disable_collisionshape(true)
	big_slime.state = big_slime_states.BROKEN
	var pf = big_slime.get_node("Path2D/PathFollow2D")
	
	big_slime.get_small_slimes().show()
	big_slime.get_small_slimes().global_position = pf.get_node("Area2D").global_position
	
	var o_vec = big_slime.get_small_slimes().global_position
	for small_slime in big_slime.get_small_slimes().get_children():
		if small_slime.hp > 0:
			var dir_vec = o_vec - small_slime.global_position
			dir_vec = dir_vec.normalized()
		
			var target_pos = small_slime.global_position+dir_vec*-20
		
			var tween = create_tween()
			tween.tween_property(small_slime, "global_position", target_pos, 0.3)
		
			small_slime.disable_collisionshape(false)
	
	big_slime.broken_timer.start()

func rebuild_big_slime(big_slime):
	var target_pos = big_slime.get_small_slimes().global_position
	var last_tween = false
	var tweens = []
	for small_slime in big_slime.get_small_slimes().get_children():
		var tween = create_tween()
		tweens.append(tween)
		tween.tween_property(small_slime, "global_position", target_pos, 0.3)
	tweens.back().connect("finished", self, "rebuild_finished", [big_slime])

func rebuild_finished(big_slime):
	if big_slime.all_small_slimes_dead():
		return false
	big_slime.hp = big_slime.hp_max
	big_slime.get_node("AnimationPlayer").play("RESET")
	big_slime.get_node("Path2D").show()
	big_slime.disable_collisionshape(false)
	big_slime.state = big_slime_states.INTACT
	
	big_slime.get_small_slimes().hide()
	for small_slime in big_slime.get_small_slimes().get_children():
		small_slime.position = small_slime.original_local_pos
		small_slime.disable_collisionshape(true)
	
	big_slime.poisoning_timer.start()
