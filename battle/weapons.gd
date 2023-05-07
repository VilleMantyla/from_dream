extends Node2D

var weapon
enum weapons {PISTOL, GRENADE_LAUCNHER}
var pistol_damage = 1

var enemy = null

func _ready():
	change_weapon(weapons.PISTOL)
	
	set_process(false)
	set_physics_process(false)

func activate(e):
	enemy = e
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process(true)
	set_physics_process(true)

func deactivate():
	enemy = null
	set_process(false)
	set_physics_process(false)

func _process(delta): #could be changed to input
	position = get_global_mouse_position()

func _physics_process(delta):
	if Input.is_action_just_pressed("fire"):
		var space = get_world_2d().direct_space_state
		
		var targets = null
		if weapon == weapons.PISTOL:
			targets = pistol_collision_query(space)
			$AudioStreamPlayer.play()
		
		if targets:
			attack(targets)

func pistol_collision_query(space):
	var top_target = null
	var top_target_index = -1
	
	var query = Physics2DShapeQueryParameters.new()
	query.set_collision_layer(1)
	query.set_shape($pistol/CollisionShape2D.get_shape())
	query.set_collide_with_areas(true)
	query.transform = $pistol.global_transform
	query.set_exclude([$pistol])
	
	var shapes = space.intersect_shape(query, 32)
	
	for s in shapes:
		if s.collider.get_target().get_index() > top_target_index:
			top_target = s.collider.get_target()
			top_target_index = top_target.get_index()
	if top_target:
		return [top_target]
	else:
		return null

func change_weapon(new_weapon):
	if new_weapon == weapons.PISTOL:
		weapon = weapons.PISTOL

func attack(targets):
	if weapon == weapons.PISTOL:
		enemy.take_damage(targets, pistol_damage)
