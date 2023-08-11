extends Node2D

var speed = 400
var delay_between_flies = 1.0
const run_time = 5.5 #seconds till this pattern is finished

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
	for i in flies.size():
		var pf = flies[i].get_node("PathFollow2D")
		pf.set_offset(0)
		
		flies[i].delay = i*delay_between_flies
	run_time_count = run_time
	

func run_pattern():
	reset_pattern()
	disable_colliders(false)
	set_process(true)

func _process(delta):
	for fly in flies:
		if fly.delay <= 0:
			var pf = fly.get_node("PathFollow2D")
			pf.set_offset(pf.get_offset()+speed*delta)
		else:
			fly.delay -= delta
	
	
	if run_time_count <= 0:
		get_parent().emit_signal("bulletshooter_finished")
		set_process(false)
	
	run_time_count -= delta
