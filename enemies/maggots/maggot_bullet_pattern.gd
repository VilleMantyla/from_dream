extends Node2D

var bullets

var speed = 700
var spx = [960,827,1093,895,1026]
var bullet_capacity = -1
const run_time = 3.39 #seconds till this pattern is finished

var run_time_count = run_time

func _ready():
	bullets = get_children()
	set_process(false)

func run_pattern():
	reset_pattern()
	set_process(true)

func reset_pattern():
	bullet_capacity = bullets.size()
	randomize_bullet_positions()
	for bullet in get_children():
		bullet.show()
	run_time_count = run_time

func _process(delta):
	for bullet in get_children():
		bullet.position += Vector2(0,1)*speed*delta
	
	if run_time_count <= 0:
		get_parent().emit_signal("bulletshooter_finished")
		set_process(false)
	
	run_time_count -= delta

func randomize_bullet_positions():
	print("kojraa mahdottomat patternit")
	spx.shuffle()
	
	bullets[0].position = Vector2(spx[0], -200)
	bullets[1].position = Vector2(spx[1], -400)
	bullets[2].position = Vector2(spx[2], -600)
	bullets[3].position = Vector2(spx[3], -800)
	bullets[4].position = Vector2(spx[4], -1000)
