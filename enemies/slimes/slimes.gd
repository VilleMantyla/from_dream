extends Node2D

signal enemy_died
signal gp_dropped
signal dmg_number

var big_slime_gp_value = 600
var small_slime_gp_value = 1

var big_slime_speed = 200

export (NodePath) var bullet_pattern

#var wait_before_slide = 0.01
#var slide_dist = 200
var slide_dirs = [Vector2(0,-1), Vector2(0.707, -0.707), Vector2(1,0),\
Vector2(0.707, 0.707), Vector2(0,1),Vector2(-0.707, 0.707),\
Vector2(-1,0), Vector2(-0.707, -0.707)]

##slide shape(s)
#var slide_eight = [1,3,5,7,7,5,3,1]
#var slide_eight2 = [5,7,1,3,3,1,7,5]

var small_slime_speed = 250

var rng
var appear_time = 1.0

var slimes = []
enum slime_ids {BIG, SMALL}
var part_count = -1

func _ready():
	bullet_pattern = get_node(bullet_pattern)
	
	slimes =  [$slime, $slime2]
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for slime in slimes:
		slime.id = slime_ids.BIG
		for small_slime in slime.get_node("small_slimes").get_children():
			small_slime.id = slime_ids.SMALL
	
	deactivate_and_reset()
	
	set_process(false)

func _process(delta):
	for big_slime in slimes:
		if !big_slime.dead:
			var pf = big_slime.get_node("Path2D/PathFollow2D")
			pf.set_offset(pf.get_offset()+big_slime_speed*delta)

func appear_and_prepare():
	var appear = get_child(0).get_node("AnimationPlayer")
	appear.connect("animation_finished", self, "on_part_animation_finished")
	for slime in slimes:
		slime.get_node("AnimationPlayer").play("appear", -1, 1/appear_time)
		slime.disable_collisionshape(false)
	
	return appear_time

func on_part_animation_finished(anim):
	if anim == "appear":
		activate()
#	if anim == "appear":
#		var empty_node = Node2D.new()
#		var empty_tween = create_tween()
#		#empty_tween.connect("finished",self,"activate")
#		empty_tween.tween_property(empty_node, "position", Vector2.ZERO,1)

func activate():
	set_process(true)

func deactivate_and_reset():
	part_count = 0
	for slime in slimes:
		slime.disable_collisionshape(true)
		slime.show()
		for small_slime in slime.get_node("small_slimes").get_children():
			small_slime.disable_collisionshape(true)
			part_count += 1
			small_slime.hide()

#func wait_to_slide(slide_data):
#	var timer_tween = create_tween()
#	var empty_node2d = Node2D.new()
#	timer_tween.connect("finished", self , "slide", [slide_data])
#	timer_tween.tween_property(empty_node2d, "position", Vector2.ZERO, wait_before_slide)

func break_to_small_slimes(slime):
	slime.disable_collisionshape(true)
	var big_slime = slime.get_node("Path2D")
	var center_pos = big_slime.global_position
	var i = 1
	for small_slime in slime.get_node("small_slimes").get_children():
		small_slime.global_position = center_pos+slide_dirs[i] * 30
		small_slime.show()
		small_slime.disable_collisionshape(false)
		small_slime.velocity = slide_dirs[i]*small_slime_speed
		small_slime.set_physics_process(true)
		i += 2

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	var pos = -1
	
	if part.id == slime_ids.BIG:
		pos = part.get_node("Path2D/PathFollow2D").global_position
		if part.hp <= 0:
			part.dead = true
			part.get_node("AnimationPlayer").play("die",-1,1.3)
			break_to_small_slimes(part)
			emit_signal("gp_dropped", big_slime_gp_value)
		else:
			part.get_node("AnimationPlayer").play("damaged")
	elif part.id == slime_ids.SMALL:
		pos = part.global_position
		if part.hp <= 0:
			part.disable_collisionshape(true)
			part.velocity = Vector2.ZERO
			part.get_node("AnimationPlayer").play("die",-1,1.3)
			part_count -= 1
			emit_signal("gp_dropped", small_slime_gp_value)
		else:
			part.get_node("AnimationPlayer").play("damaged")
	
	emit_signal("dmg_number",dmg, pos)

func damage_to_all(dmg):
	for big_slime in slimes:
		if big_slime.hp > 0:
			damage_to_part(big_slime, dmg)
		else:
			for small_slime in big_slime.get_node("small_slimes").get_children():
				if small_slime.hp > 0:
					damage_to_part(small_slime, dmg)

	if part_count == 0:
		emit_signal("enemy_died")
