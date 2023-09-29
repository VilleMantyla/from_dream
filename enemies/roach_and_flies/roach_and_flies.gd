extends Node2D

signal enemy_died
signal gp_dropped
signal dmg_number

export (NodePath) var bullet_pattern

var fly_gp_value = 150
var roach_gp_value = 1000

var fly_speed = 300
var roach_speed = 1

var appear_time = 1.0

var roach
var flies
var part_count = 0
enum enemy_ids {ROACH, FLY}

func _ready():
	bullet_pattern = get_node(bullet_pattern)
	roach = $cockroach
	flies = get_children()
	flies.pop_front() #remove cockroach
	
	roach.id = enemy_ids.ROACH
	for fly in flies:
		fly.id = enemy_ids.FLY
	
	deactivate_and_reset()

func appear_and_prepare():
	var animation_player = roach.get_node("AnimationPlayer")
	animation_player.connect("animation_finished", self, "animation_finished")
	animation_player.play("appear", -1, 1/appear_time)
	roach.disable_collisionshape(false)
	
	for fly in flies:
		fly.disable_collisionshape(false)
		#var pf = fly.get_node("Path2D/PathFollow2D")
		#var random_offset = rng.randf_range(0.0, 1.0)
		#pf.set_unit_offset(pf.get_unit_offset()+random_offset)
		fly.get_node("AnimationPlayer").play("appear",-1,1/appear_time)
	
	return appear_time

func animation_finished(anim):
	if anim == "appear":
		activate()

func activate():
	set_process(true)

func _process(delta):
	#roach
	var rpf = roach.get_node("Path2D/PathFollow2D")
	#rpf.set_offset(rpf.get_offset()+roach_speed*delta)
	#flies
	for fly in flies:
		if !fly.dead:
			var pf = fly.get_node("Path2D/PathFollow2D")
			pf.set_offset(pf.get_offset()+fly_speed*delta)

func deactivate_and_reset():
	part_count = 0
	# cockroach
	part_count += 1
	roach.disable_collisionshape(true)
	var anim_sp = roach.get_node("Path2D/PathFollow2D/Area2D/AnimatedSprite")
	anim_sp.set_animation("shield")
	#flies
	part_count += flies.size()
	for fly in flies:
		fly.disable_collisionshape(true)
	
	set_process(false)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	if part.id == enemy_ids.ROACH:
		var shield_on = part.shield > 0
		print("roach takes damage " + str(dmg))
		
		if shield_on:
			if part.shield <= dmg:
				part.shield = 0
				part.get_node("AnimationPlayer").play("shield_off")
			else:
				dmg = 0
		else:
			part.hp -= dmg
			if part.hp > 0:
				part.get_node("AnimationPlayer").play("damaged")
				part.get_node("AnimationPlayer").seek(0, true)
			else:
				part.disable_collisionshape(true)
				part.get_node("AnimationPlayer").play("die",-1,1.3)
				part_count -= 1
				emit_signal("gp_dropped", roach_gp_value)
	elif part.id == enemy_ids.FLY:
		part.hp -= dmg
		if part.hp <= 0:
			part.disable_collisionshape(true)
			part.dead = true
			part_count -= 1
			emit_signal("gp_dropped", fly_gp_value)
			part.get_node("AnimationPlayer").play("die")
		else:
			part.get_node("AnimationPlayer").play("damaged")
	
	var pos = part.get_node("Path2D/PathFollow2D").global_position
	emit_signal("dmg_number",dmg, pos)

	if part_count == 0:
		emit_signal("enemy_died")
