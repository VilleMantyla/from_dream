extends KinematicBody

var MOUSE_SENSITIVITY = 0.06
var rotation_x_limit = Vector2(deg2rad(60), deg2rad(-60))

var move_input = Vector2.ZERO
var move_dir = Vector3.ZERO

var height #defined in _ready
var player_on_floor = true
var gravity = -6.5
var drop_limit = -0.2
var walk_speed = 3
const FLOOR_RAY_START = Vector3(0.0,1.5,0.0)
const FLOOR_RAY_END = Vector3(0.0,-100.0,0.0)

var stop_player = false
var interacting = false

func _ready():
	height = global_transform.origin.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:# and !stop_mouse_rot:
		
		var input_x = deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1)
		var rotation_x = $rotation_helper.rotation.x+input_x
		$rotation_helper.rotation.x = clamp(rotation_x, rotation_x_limit.y, rotation_x_limit.x)
		#$rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

func _process(delta):
	move_input = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		move_input.x = -1
	if Input.is_action_pressed("move_down"):
		move_input.x = 1
	if Input.is_action_pressed("move_left"):
		move_input.y = -1
	if Input.is_action_pressed("move_right"):
		move_input.y = 1
	
	if move_input != Vector2.ZERO:
		#walk
		move_dir = (transform.basis*Vector3(move_input.x, 0, -move_input.y)).normalized()
	else:
		#idle
		move_dir = Vector3.ZERO

func _physics_process(delta):
	var space_state = get_world().direct_space_state
	#####################
	## gravity raycast ##
	#####################
	var ray_start = global_transform.origin+FLOOR_RAY_START
	var ray_end = global_transform.origin+FLOOR_RAY_END
	var collision = space_state.intersect_ray(ray_start, ray_end, [self])
	var fall_distance = 0
	if collision:
		if (collision.position - global_transform.origin).y + height < drop_limit:
			#player falls
			player_on_floor = false
			fall_distance = (collision.position - global_transform.origin).y + height
		elif player_on_floor:
			translation.y = collision.position.y+height
	else:
		#no floor collision, player falls
		player_on_floor = false
		fall_distance = -100
	
	if !player_on_floor:
		player_on_floor = drop_player(fall_distance, delta)

	if !stop_player and player_on_floor:
		var move = (move_dir*walk_speed).cross(collision.normal)
		move_and_slide(move, Vector3.UP, true)

func drop_player(fall_max, delta):
	var fall_step = gravity*delta
	if fall_max - fall_step < 0:
		translation.y += fall_step
		return false #player still not on floor
	else:
		translation.y += fall_max
		return true 

func disable_input(val):
	set_process_input(!val)
	stop_player = val
