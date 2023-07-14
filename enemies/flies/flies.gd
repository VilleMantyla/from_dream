extends Node2D

signal appear_finished
signal enemy_died
signal gp_dropped

var part_count = 0

var flies
var normal_speed = 300

func _ready():
	deactivate()

func activate():
	var rng = RandomNumberGenerator.new()
	var appear = get_child(0).get_node("AnimationPlayer")
	appear.connect("animation_finished", self, "appear_finished")
	for fly in get_children():
		fly.disable_collisionshape(false)
		var pf = fly.get_node("Path2D/PathFollow2D")
		#var random_offset = rng.randf_range(0.0, 1.0)
		#pf.set_unit_offset(pf.get_unit_offset()+random_offset)
		fly.get_node("AnimationPlayer").play("appear",-1,1)
		
	part_count = get_children().size()
	flies = get_children()

func deactivate():
	for fly in get_children():
		fly.disable_collisionshape(true)
	
	set_process(false)

func appear_finished(a):
	#set_process(true)
	var empty_node = Node2D.new()
	var empty_tween = create_tween()
	empty_tween.connect("finished",self,"tween_testi_aika")
	empty_tween.tween_property(empty_node, "position",Vector2.ZERO,1)
	emit_signal("appear_finished")

func tween_testi_aika():
	set_process(true)

func _process(delta):
	for fly in flies:
		var pf = fly.get_node("Path2D/PathFollow2D")
		pf.set_offset(pf.get_offset()+normal_speed*delta)

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
