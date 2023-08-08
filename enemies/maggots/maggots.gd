extends Node2D

signal enemy_died
signal gp_dropped

export (NodePath) var bullet_pattern

var gp_value = 100

var part_count = 0
var appear_count = 0

var dead = true

func _ready():
	bullet_pattern = get_node(bullet_pattern)
	deactivate()
#	for maggot in get_children():
#		var ap = maggot.get_node("AnimationPlayer")
#		ap.connect("animation_finished", self, "on_animation_finished", [maggot])

func appear_and_prepare():
	for maggot in get_children():
		maggot.disable_collisionshape(false)
	part_count = get_children().size()
	appear_count = part_count
	dead = false
	play_appear_anim()
	return 0.67

func deactivate():
	for maggot in get_children():
#		maggot.get_node("Area2D/AnimatedSprite").stop()
#		maggot.get_node("Area2D/AnimatedSprite").set_frame(0)
		maggot.disable_collisionshape(true)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	if part.hp <= 0:
		part.get_node("AnimationPlayer").play("die",-1,2.3)
		part.disable_collisionshape(true)
		part_count -= 1
		part.get_node("Area2D/AnimatedSprite").stop()
		emit_signal("gp_dropped", gp_value)
	
	if part_count <= 5 and !dead:
		for maggot in get_children():
			if maggot.hp > 0:
				var temp = Vector2(0,-5000)
				temp = temp.rotated(maggot.global_rotation)
				temp = temp+maggot.global_position
				var tween = create_tween()
				tween.tween_property(maggot, "global_position", temp, 6).set_trans(Tween.EASE_OUT)
		
		emit_signal("enemy_died")
		dead = true

func play_appear_anim():
	for m in get_children():
		m.get_node("AnimationPlayer").play("appear",-1,1.5)
