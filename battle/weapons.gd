extends Node2D

var weapon
enum weapons {PISTOL, GRENADE_LAUCNHER}
var weapon_node
var pistol_damage = 1
var grenade_launcher_damage = 5
var gl_explode

var enemy = null

var weapon_change_timer

var battle_player

func _ready():
	weapon_node = $pistol
	change_weapon(weapons.PISTOL)
	
	gl_explode = get_parent().get_node("gl_explode")
	gl_explode.connect("animation_finished",self,"gl_exploded")
	
	set_process(false)
	set_physics_process(false)
	
	weapon_change_timer = Timer.new()
	weapon_change_timer.wait_time = 2.5
	weapon_change_timer.one_shot = true
	weapon_change_timer.connect("timeout", self, "switch_out")
	add_child(weapon_change_timer)
	$AnimationPlayer.connect("animation_finished", self, "switch_anim_finished")
	
	battle_player = get_parent()

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
	
	if $load_bar.value < 100: #and !pause_meter:
		$load_bar.value = clamp($load_bar.value+delta*100, 0, 100)
	
	if Input.is_action_just_pressed("one"):
		change_weapon(weapons.PISTOL)
	elif Input.is_action_just_pressed("two"):
		#$AnimationPlayer.play("switch_in",-1,1.85)
		#get_parent().get_node("ColorRect").show()
		change_weapon(weapons.GRENADE_LAUCNHER)

func _physics_process(delta):
	if Input.is_action_just_pressed("fire"):
		var space = get_world_2d().direct_space_state
		
		var targets = null
		if weapon == weapons.PISTOL:
			targets = pistol_collision_query(space)
			$AudioStreamPlayer.play()
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

func switch_out():
	$AnimationPlayer.play("switch_out",-1,2.5)
	get_parent().get_node("tv_gun_text").hide()

func switch_anim_finished(anim):
	if anim == "switch_in":
		weapon_change_timer.start()
		get_parent().get_node("tv_gun_text").show()
	elif anim == "switch_out":
		get_parent().get_node("ColorRect").hide()
