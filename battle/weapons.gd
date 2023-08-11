extends Node2D

signal player_turn_completed

var weapon
enum weapons {PISTOL, GRENADE_LAUCNHER}
var weapon_node
var pistol_damage = 1
var grenade_launcher_damage = 5
var gl_explode

var enemy = null

var bullets_left = 5

enum states {WAIT, FIRE}
var state = states.WAIT

func _ready():
	weapon_node = $pistol
	change_weapon(weapons.PISTOL)
	
	gl_explode = get_parent().get_node("gl_explode")
	gl_explode.connect("animation_finished",self,"gl_exploded")
	
	set_process(false)
	set_physics_process(false)
	
	$pistol/Sprite/AnimationPlayer.get_animation("spin").set_loop(true)
	$pistol/Sprite/AnimationPlayer.play("spin")

#################
## Bonus wheel ##
#################
var pistol_bonus_on = false
func set_pistol_to_bonus(val):
	pistol_bonus_on = val

func activate(e):
	enemy = e
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process(true)
	set_physics_process(true)

func deactivate():
	enemy = null
	set_process(false)
	set_physics_process(false)

func set_state_to_FIRE():
	state = states.FIRE

func set_state_to_WAIT():
	state = states.WAIT

func _process(delta): #could be changed to input
	position = get_global_mouse_position()
	
	if $load_bar.value < 100: #and !pause_meter:
		$load_bar.value = clamp($load_bar.value+delta*100, 0, 100)
	
	if Input.is_action_just_pressed("one"):
		change_weapon(weapons.PISTOL)
	elif Input.is_action_just_pressed("two"):
		if get_parent().gp >= 500:
			change_weapon(weapons.GRENADE_LAUCNHER)
			get_parent().on_gp_drop(-500)

func _physics_process(delta):
	if state == states.FIRE and \
	Input.is_action_just_pressed("fire") and bullets_left > 0:
		spend_bullet()
		
		var space = get_world_2d().direct_space_state
		
		var targets = null
		if weapon == weapons.PISTOL:
			targets = pistol_collision_query(space)
			$AudioStreamPlayer.play()
			if pistol_bonus_on:
				get_parent().get_node("pistol_bang").global_position = get_global_mouse_position()
				get_parent().get_node("pistol_bang/AnimationPlayer").play("bonus",-1,2)
				get_parent().get_node("pistol_bang/AnimationPlayer").seek(0)
				pistol_damage = 2
			else:
				get_parent().get_node("pistol_bang").global_position = get_global_mouse_position()
				get_parent().get_node("pistol_bang/AnimationPlayer").play("normal",-1,2)
				get_parent().get_node("pistol_bang/AnimationPlayer").seek(0)
				pistol_damage = 1
		elif weapon == weapons.GRENADE_LAUCNHER and $load_bar.value == 100:
			targets = grenade_launcher_collision_query(space)
			gl_explode.global_position = get_global_mouse_position()
			gl_explode.show()
			gl_explode.play("default")
			$AudioStreamPlayer.play()
			$load_bar.value = 0
		
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

func grenade_launcher_collision_query(space):
	var query = Physics2DShapeQueryParameters.new()
	query.set_collision_layer(1)
	query.set_shape($grenade_launcher/CollisionShape2D.get_shape())
	query.set_collide_with_areas(true)
	query.transform = $grenade_launcher.global_transform
	query.set_exclude([$grenade_launcher])
	
	var shapes = space.intersect_shape(query, 32)
	var result = []
	
	print("HIT " + str(shapes.size()) + " shapes")
	
	print(shapes)
	
	print("rids are:")
	for shape in shapes:
		print(shape.rid.get_id())
		if !result.has(shape.collider):
			result.append(shape.collider)
	var resultresult = []
	for r in result:
		resultresult.append(r.get_target())
	
	if result.empty():
		return null
	else:
		return resultresult

func change_weapon(new_weapon):
	weapon_node.get_node("CollisionShape2D").disabled = true
	weapon_node.hide()
		
	if new_weapon == weapons.PISTOL:
		weapon = weapons.PISTOL
		$pistol/CollisionShape2D.disabled = false
		$pistol.show()
		weapon_node = $pistol
		$AudioStreamPlayer.stream = load("res://sounds/pistol_fire.wav")
	elif new_weapon == weapons.GRENADE_LAUCNHER:
		weapon = weapons.GRENADE_LAUCNHER
		$grenade_launcher/CollisionShape2D.disabled = false
		$grenade_launcher.show()
		weapon_node = $grenade_launcher
		$AudioStreamPlayer.stream = load("res://sounds/grenade_launcher.wav")

func attack(targets):
	if weapon == weapons.PISTOL:
		enemy.take_damage(targets, pistol_damage)
	elif weapon == weapons.GRENADE_LAUCNHER:
		enemy.take_damage(targets, grenade_launcher_damage)

func gl_exploded():
	gl_explode.hide()
	gl_explode.stop()
	#gl_explode.set_frame(0)

func spend_bullet():
	bullets_left -= 1
	get_parent().get_node("bullets").get_child(bullets_left).hide()
	
	if bullets_left == 0:
		emit_signal("player_turn_completed")

func reload():
	for b in get_parent().get_node("bullets").get_children():
		b.show()
		bullets_left += 1



