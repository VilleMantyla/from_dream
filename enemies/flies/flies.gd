extends Node2D

signal enemy_died
signal gp_dropped
signal dmg_number

export (NodePath) var bullet_pattern

var gp_value = 500

var part_count = 0

var flies
var speed = 400

var appear_time = 1.0

func _ready():
	bullet_pattern = get_node(bullet_pattern)
	deactivate()

func appear_and_prepare():
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
	var animation_player = get_child(0).get_node("AnimationPlayer")
	animation_player.connect("animation_finished", self, "animation_finished")
	for fly in get_children():
		fly.disable_collisionshape(false)
#		var pf = fly.get_node("Path2D/PathFollow2D")
#		var random_offset = rng.randf_range(0.0, 1.0)
#		pf.set_unit_offset(pf.get_unit_offset()+random_offset)
		fly.get_node("AnimationPlayer").play("appear",-1,1/appear_time)
		fly.dead = false
		
	part_count = get_children().size()
	flies = get_children()
	
	return appear_time

func animation_finished(anim):
	if anim == "appear":
		var empty_node = Node2D.new()
		var empty_tween = create_tween()
		empty_tween.connect("finished",self,"activate")
		empty_tween.tween_property(empty_node, "position",Vector2.ZERO,1)

func deactivate():
	for fly in get_children():
		fly.disable_collisionshape(true)
	set_process(false)

func activate():
	set_process(true)

func _process(delta):
	for fly in flies:
		if !fly.dead:
			var pf = fly.get_node("Path2D/PathFollow2D")
			pf.set_offset(pf.get_offset()+speed*delta)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	if part.hp <= 0:
		part.dead = true
		part.get_node("AnimationPlayer").play("die",-1,2.3)
		part.get_node("Path2D/PathFollow2D/Area2D/AnimatedSprite").stop()
		part.disable_collisionshape(true)
		part_count -= 1
		emit_signal("gp_dropped", gp_value)
	else:
		part.get_node("AnimationPlayer").play("damaged")
	
	if part_count == 0:
		emit_signal("enemy_died")
	
	var pos = part.get_node("Path2D/PathFollow2D").global_position
	emit_signal("dmg_number",dmg, pos)

func damage_to_all(dmg):
	for fly in get_children():
		if fly.hp > 0:
			damage_to_part(fly, dmg)
