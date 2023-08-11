extends Node2D

var slimes = []
var delays = [0,2]
var speeds = [4,8]
var positions = [Vector2(960,-200), Vector2(1026,-200)]

const run_time = 6.5
var run_time_count = run_time

func _ready():
	slimes = get_children()
	set_process(false)

func _process(delta):
	for slime in slimes:
		if slime.delay > 0:
			slime.delay -= delta
		else:
			slime.global_position += Vector2.DOWN * slime.speed
	
	if run_time_count <= 0:
		get_parent().emit_signal("bulletshooter_finished")
		set_process(false)
	
	run_time_count -= delta

func reset_pattern():
	for i in slimes.size():
		slimes[i].delay = delays[i]
		slimes[i].speed = speeds[i]
		slimes[i].global_position = positions[i]
	run_time_count = run_time

func run_pattern():
	print("run slimes")
	reset_pattern()
	#disable_colliders(false)
	set_process(true)
