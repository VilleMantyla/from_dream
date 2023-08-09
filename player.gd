extends KinematicBody

const PLAYER_HEIGHT = 1.6

var MOUSE_SENSITIVITY = 0.06
var rotation_x_limit = Vector2(deg2rad(70), deg2rad(-70))

var move_input = Vector2.ZERO
var move_dir = Vector3.ZERO

var height #defined in _ready
var player_on_floor = true
var gravity = -6.5
var drop_limit = -0.2
var walk_speed = 3
const FLOOR_RAY_START = Vector3(0.0,1.5,0.0)
const FLOOR_RAY_END = Vector3(0.0,-1000.0,0.0)

var stop_player = false

enum {IDLE, WALK, LADDER}
var state = null

signal show_context_msg
signal hide_context_msg
var chatting = false
var looking_at_interactable = null

#climbing on ladder
var active_ladder = null
var lad_climb_speed = 1.2
var ladder_exit_range = 0.5 #includes + and -

#climbing on levels
var climb_padding = 0.25
#var climbing_time = 100
#var climbing = false
#var climb_distance = null
#var mov_dist_cur = 0

func _ready():
	height = PLAYER_HEIGHT#global_transform.origin.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func activate(val):
	set_process_input(val)
	set_process(val)
	set_physics_process(val)
	if val:
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
		if state == LADDER:
			climb_ladder(-1*move_input.x, delta)
		else:
			#walk
			move_dir = (transform.basis*Vector3(move_input.x, 0, -move_input.y)).normalized()
	else:
		#idle
		move_dir = Vector3.ZERO
	
	if Input.is_action_just_pressed("interact"):
		if state == LADDER:
			try_exit_ladder()
		elif looking_at_interactable:
			if looking_at_interactable.is_in_group("ladder"):
				var floor_n = set_active_ladder(looking_at_interactable)
				climb_to_ladder(floor_n)
			elif looking_at_interactable.is_in_group("cutscene"):
				get_parent().start_cutscene(looking_at_interactable.cutscene_name)
			elif looking_at_interactable.is_in_group("area_switch"):
				switch_area(looking_at_interactable)
			elif looking_at_interactable.is_in_group("chat"):
				var chat_key = looking_at_interactable.chat_key
				get_parent().interact_with_world_object(chat_key, null, null)
			elif looking_at_interactable.is_in_group("climb"):
				var climb = looking_at_interactable
				if climb.climb_along_z:
					var new_pos = climb.climb_spot
					new_pos.x = global_transform.origin.x
					new_pos.x = clamp(new_pos.x, climb.limit_min, climb.limit_max)
					new_pos.y += PLAYER_HEIGHT
					var tween = create_tween()
					tween.tween_property(self, "global_transform:origin",\
					new_pos, 0.4).set_trans(Tween.EASE_OUT)
			elif looking_at_interactable.is_in_group("pick_up"):
				looking_at_interactable.picked_up()
			elif looking_at_interactable.is_in_group("regular_door") and\
			!looking_at_interactable.is_open:
				looking_at_interactable.is_open = true
				var new_loc = looking_at_interactable.get_door_spot(global_transform.origin)
				new_loc.y = global_transform.origin.y
				var location_tween = create_tween()
				location_tween.tween_property(self, "global_transform:origin",\
				new_loc, 0.7).set_trans(Tween.EASE_IN_OUT)

				var new_roty = looking_at_interactable.get_roty(global_transform.origin,\
				global_rotation)
				var rot_tween = create_tween()
				rot_tween.tween_property(self, "global_rotation:y",\
				new_roty, 0.7).set_trans(Tween.EASE_IN_OUT)
				
				looking_at_interactable.play_anim(1.3)
			elif looking_at_interactable.is_in_group("chain"):
				looking_at_interactable.cut_chain()

func _physics_process(delta):
	var space_state = get_world().direct_space_state
	#####################
	## gravity raycast ##
	#####################
	if state == LADDER:
		pass
	else:
		#state walk/walking abled
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
	
	##########################
	## LOOKING AT SOMETHING ##
	##########################
	if $rotation_helper/RayCast.is_colliding():
		var result = $rotation_helper/RayCast.get_collider()
		if result.is_in_group("interactable"):
			looking_at_interactable = result
		else:
			looking_at_interactable = null
			#emit_signal("hide_context_msg")
	else:
		looking_at_interactable = null
		#emit_signal("hide_context_msg")

func drop_player(fall_max, delta):
	var fall_step = gravity*delta
	if fall_max - fall_step < 0:
		translation.y += fall_step
		return false #player still not on floor
	else:
		translation.y += fall_max
		return true 

func climb_to_ladder(floor_n):
	state = LADDER
	
	var climb_to_point = active_ladder.climb_offset
	climb_to_point.y = active_ladder.get_enter_height(floor_n, translation.y-height, translation.y)
	var location_tween = create_tween()
	location_tween.tween_property(self, "global_transform:origin",
	climb_to_point, 1.0).set_trans(Tween.EASE_IN_OUT)

func try_exit_ladder():
	var exit_data = active_ladder.get_next_exit_pos(translation.y-height,
	translation.y, ladder_exit_range)
	if exit_data:
		print("got ladder exit data")
		activate(false)
		exit_ladder(exit_data[0], exit_data[1])

func exit_ladder(exit_to_pos, exit_dir):
	if exit_dir == Vector2(0,0):
		#bottom
		pass
	elif exit_dir == Vector2(1,0):
		#exit to the right
		exit_to_pos.y += height
		var location_tween = create_tween()
		location_tween.tween_property(self, "global_transform:origin",
		exit_to_pos, 1.8).set_trans(Tween.EASE_IN_OUT)
		
		var target_rot_y = -90
		var current_rot = rad2deg(global_rotation.y)
		var target_rot = target_rot_y
		if global_rotation.y < 0:
			current_rot = rad2deg(abs(global_rotation.y)+PI)
		if target_rot_y < 0:
			target_rot = abs(target_rot_y)+180
		print("current_rot " + str(current_rot) + " target_rot " + str(target_rot))
		var rot_sign = fmod((target_rot-current_rot+540),360)-180
		
		var new_rot_y
		if rot_sign < 0:
			new_rot_y = Vector3(0,deg2rad(-90),0)
		else:
			new_rot_y = Vector3(0,deg2rad(270),0)
		var roty_tween = create_tween()
		roty_tween.tween_property(self, "global_rotation", new_rot_y, 1.8).set_trans(Tween.EASE_IN_OUT)
		var new_rot_x = Vector3(deg2rad(-45),0,0)
		var rotx_tween = create_tween()
		rotx_tween.tween_property($rotation_helper, "rotation", new_rot_x, 1.8).set_trans(Tween.EASE_IN_OUT)
		
		#something more general later
		rotx_tween.connect("finished", self, "on_ladder_exited")

func climb_ladder(move_dir, delta):
	var on_top_limit = translation.y + delta*move_dir*lad_climb_speed < active_ladder.top_max
	var on_bottom_limit = translation.y + delta*move_dir*lad_climb_speed > active_ladder.btm_max + height
	if on_bottom_limit and on_top_limit:
		translation.y += delta*move_dir*lad_climb_speed
	elif !on_bottom_limit:
		translation.y = active_ladder.btm_max + height
		print("player on ladder bottom")
	elif !on_top_limit:
		translation.y = active_ladder.top_max
		print("player on ladder TOP")

func set_active_ladder(ladder_floor_area):
	active_ladder = ladder_floor_area.get_parent()
	return ladder_floor_area.floor_number

func on_ladder_exited():
	state = null
	activate(true)

func switch_area(new_area):
	if new_area.slide_to_pos:
		var new_pos = new_area.target_pos
		new_pos.y += PLAYER_HEIGHT
		var tween1 = create_tween()
		tween1.tween_property(self, "global_transform:origin", new_pos, 0.75).set_trans(Tween.EASE_OUT)
	else:
		var new_pos = new_area.target_pos
		new_pos.y += PLAYER_HEIGHT
		global_transform.origin = new_pos
	
		var new_rot_y = new_area.target_rot.y
		global_rotation.y = deg2rad(new_rot_y)
