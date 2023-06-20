extends KinematicBody2D

var speed = 300
var move_input = Vector2.ZERO
var move_dir = Vector2.ZERO

func _ready():
	set_process(false)
	set_physics_process(false)

func activate():
	set_process(true)
	set_physics_process(true)

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

func _physics_process(delta):
	move_and_slide(move_dir*speed)
