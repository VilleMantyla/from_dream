extends Node2D

signal appear_finished
signal enemy_died
signal attack_message
signal clear_message
signal attack
signal gp

var part_count = 0
var appear_count = 0

var dead = true

func _ready():
	deactivate()
	for maggot in get_children():
		var ap = maggot.get_node("AnimationPlayer")
		ap.connect("animation_finished", self, "on_animation_finished", [maggot])

func activate():
	for maggot in get_children():
		#maggot.get_node("Area2D/AnimatedSprite").play()
		maggot.disable_collisionshape(false)
	part_count = get_children().size()
	appear_count = part_count
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

var money = 0
func damage_to_part(part, dmg):
	part.hp -= dmg
	if part.hp <= 0:
		part.get_node("AnimationPlayer").play("die",-1,2.3)
		part.disable_collisionshape(true)
		part_count -= 1
		part.get_node("Area2D/AnimatedSprite").stop()
		money += 10
		get_parent().get_parent().get_node("gp").text = "GP: $" + str(money)
	
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
	#get ready text
	#get_parent().get_parent().get_node("battle_ready/AnimationPlayer").play("show_up",-1,2)
	#get_parent().get_parent().get_node("battle_ready/AnimationPlayer").seek(0.6)
	for m in get_children():
		m.get_node("AnimationPlayer").play("appear",-1,1.5)

func on_animation_finished(anim, maggot):
	if anim == "appear":
		appear_count -= 1
		if appear_count == 0:
			for maggot in get_children():
				maggot.get_node("Area2D/AnimatedSprite").play()
			emit_signal("appear_finished")
