extends Area2D

export var god_mode = false

var speed = 300
var move_input = Vector2.ZERO
var move_dir = Vector2.ZERO

var limit_min
var limit_max

func _ready():
	set_process(false)
	set_physics_process(false)
	
	limit_min = get_parent().get_node("dodge_limit_0").global_position
	limit_max = get_parent().get_node("dodge_limit_1").global_position
	
	#adjusting for vi's size
	limit_min.x += 34
	limit_min.y += 38.5
	limit_max.x -= 33.5
	limit_max.y -= 38

func activate():
	set_process(true)
	$animated_sprite.stop()
	$animated_sprite.set_frame(0)

func deactivate():
	set_process(false)
	$animated_sprite.play()

func _process(delta):
	move_input = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		move_input.y = -1
	if Input.is_action_pressed("move_down"):
		move_input.y = 1
	if Input.is_action_pressed("move_left"):
		move_input.x = -1
	if Input.is_action_pressed("move_right"):
		move_input.x = 1
	
	move_dir = move_input.normalized()
	
	move(delta, move_dir)

func move(delta, dir):
	var step = dir*delta*speed
	var new_pos = position + step
	
	var step_x_min = new_pos.x > limit_min.x
	var step_x_max = new_pos.x < limit_max.x
	
	if new_pos.x < limit_min.x:
		new_pos.x = limit_min.x
	elif new_pos.x > limit_max.x:
		new_pos.x = limit_max.x
	
	if new_pos.y < limit_min.y:
		new_pos.y = limit_min.y
	elif new_pos.y > limit_max.y:
		new_pos.y = limit_max.y
	
	position = new_pos

func _on_tamagotchi_area_entered(area):
	if god_mode:
		return
	$AnimationPlayer.play("hit",-1,4.5)
	area.hide() #disable collision too
	get_parent().get_node("hp_count/point0").hide()
	
	get_parent().get_node("noise_screen/AnimationPlayer").play("game_over",-1,1.5)
