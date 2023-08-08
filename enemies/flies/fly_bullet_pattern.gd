extends Node2D


var speed = 400
const run_time = 4.5 #seconds till this pattern is finished

var flies = []
var run_time_count = run_time

func _ready():
	flies.append($fly_bullet)
	flies.append($fly_bullet2)
	disable_colliders(true)
	set_process(false)

func disable_colliders(val):
	for fly in flies:
		fly.get_node("PathFollow2D/Area2D/CollisionShape2D").disabled = val

func reset_pattern():
	for fly in flies:
		var pf = fly.get_node("PathFollow2D")
		pf.set_offset(0)
	run_time_count = run_time

func run_pattern():
	disable_colliders(false)
	set_process(true)

func _process(delta):
	for fly in flies:
		var pf = fly.get_node("PathFollow2D")
		pf.set_offset(pf.get_offset()+speed*delta)
	
	if run_time_count <= 0:
		get_parent().emit_signal("bulletshooter_finished")
		set_process(false)
	
	run_time_count -= delta
