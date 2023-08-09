extends Node2D

signal enemy_died
signal gp_dropped

var wait_before_slide = 0.01
var slide_dist = 300
var slide_dirs = [Vector2(0,-1), Vector2(0.707, -0.707), Vector2(1,0),\
Vector2(0.707, 0.707), Vector2(0,1),Vector2(-0.707, 0.707),\
Vector2(-1,0), Vector2(-0.707, -0.707)]

#slide shape(s)
var slide_eight = [1,3,5,7,7,5,3,1]
var shape_i = 0
var shape_max_i = -1
var slide_path = null

var rng

var small_slimes = []

func _ready():
	small_slimes.append($slime_small)
	small_slimes.append($slime_small2)
	small_slimes.append($slime_small3)
	small_slimes.append($slime_small4)
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	slide_path = slide_eight
	shape_max_i = slide_path.size()-1
	
	slide()

func _process(delta):
	if Input.is_action_just_pressed("debug_btn_1"):
		break_to_small_slimes()

func slide_to_random_dir():
	var slime = $slime
	#var random_i = rng.randi_range(0, slide_dirs.size()-1)
	var slide_dir = slide_dirs[slide_path[shape_i]]
	if shape_i == shape_max_i:
		shape_i = 0
	else:
		shape_i += 1
	var new_pos = slide_dir*slide_dist + slime.position
	var slide_tween = create_tween()
	slide_tween.connect("finished", self , "slide")
	slide_tween.tween_property(slime, "position", new_pos, 0.5).set_trans(Tween.EASE_IN_OUT)

func slide():
	var timer_tween = create_tween()
	var empty_node2d = Node2D.new()
	timer_tween.connect("finished", self , "slide_to_random_dir")
	timer_tween.tween_property(empty_node2d, "position", Vector2(10,10), wait_before_slide)

func break_to_small_slimes():
	$slime.hide()
	var pos = $slime.position
	var i = 2
	for small_slime in small_slimes:
		small_slime.position = pos
		var new_pos = pos+slide_dirs[i] * 200
		var slide_tween = create_tween()
		slide_tween.tween_property(small_slime, "position", new_pos, 0.5).set_trans(Tween.EASE_IN_OUT)
		i += 1
