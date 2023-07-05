extends Node2D

signal appear_finished
signal enemy_died
signal attack
signal attack_message
signal clear_message

var part_count = 0

var flies
var normal_speed = 300
var attack_dmg = 1

## attack variables ##
var attacking_fly = null
var five_left_attack = true
var attack_speed = 2*normal_speed
var attack_ms = "fly attacks"

func _ready():
	deactivate()

func activate():
	var rng = RandomNumberGenerator.new()
	var appear = get_child(0).get_node("AnimationPlayer")
	appear.connect("animation_finished", self, "appear_finished")
	for fly in get_children():
		fly.disable_collisionshape(false)
		var pf = fly.get_node("Path2D/PathFollow2D")
		var random_offset = rng.randf_range(0.0, 1.0)
		pf.set_unit_offset(pf.get_unit_offset()+random_offset)
		fly.get_node("AnimationPlayer").play("appear")
		
	part_count = get_children().size()
	flies = get_children()

func deactivate():
	for fly in get_children():
		fly.disable_collisionshape(true)
	
	set_process(false)

func appear_finished(a):
	set_process(true)
	emit_signal("appear_finished")

func _process(delta):
	for fly in flies:
		var pf = fly.get_node("Path2D/PathFollow2D")
		pf.set_offset(pf.get_offset()+normal_speed*delta)
	
	attack_update(delta)

func attack_update(delta):
	if part_count == 5 and five_left_attack:
		five_left_attack = false
		attacking_fly = start_attack()
		
	if attacking_fly:
		var pf = attacking_fly.get_node("Path2D/PathFollow2D")
		pf.set_offset(pf.get_offset()+attack_speed*delta)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	if part.hp <= 0:
		part.hide()
		part.disable_collisionshape(true)
		part_count -= 1
	
	if part_count == 0:
		emit_signal("enemy_died")
	
	if attacking_fly and attacking_fly.hp <= 0:
		emit_signal("clear_message")

func start_attack():
	var fly = get_random_fly()
	flies.erase(fly)
	move_child(fly, get_children().size()-1)
	print("fix fly postion")
	
	var sprite = fly.get_node("Path2D/PathFollow2D/Area2D/Sprite")
	sprite.set_texture(load("res://enemies/flies/fly_attacking.png"))
	
	var area = fly.get_node("Path2D/PathFollow2D/Area2D")
	var tween = create_tween()
	tween.connect("finished",self, "attack", [fly])
	tween.tween_property(area, "global_scale", Vector2(3,3), 1.5)
	
	emit_signal("attack_message", attack_ms)
	return fly

func get_random_fly():
	var alive_flies = []
	for fly in flies:
		if fly.hp > 0:
			alive_flies.append(fly)
	return alive_flies[0]

func attack(fly):
	if fly.hp <= 0:
		return
	attacking_fly = null
	damage_to_part(fly, 1000000)
	
#	emit_signal("attack", EnemyStuff.attack_types.NORMAL, attack_dmg)
