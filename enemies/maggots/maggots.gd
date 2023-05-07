extends Node2D

signal enemy_died

var part_count = 0

var dead = true

func _ready():
	deactivate()

func activate():
	for maggot in get_children():
		maggot.get_node("Area2D/AnimatedSprite").play()
		maggot.disable_collisionshape(false)
	part_count = get_children().size()
	dead = false
	play_appear_anim()

func deactivate():
	for maggot in get_children():
		maggot.get_node("Area2D/AnimatedSprite").stop()
		maggot.get_node("Area2D/AnimatedSprite").set_frame(0)
		maggot.disable_collisionshape(true)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	if part.hp <= 0:
		part.hide()
		part.disable_collisionshape(true)
		part_count -= 1
	
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
		m.get_node("AnimationPlayer").play("appear",-1,1)
