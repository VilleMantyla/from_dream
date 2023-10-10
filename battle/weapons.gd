extends Node2D

signal player_turn_completed

const SHOOTING_Y_LIMIT = 858

var weapon
enum weapons {PISTOL, GRENADE_LAUCNHER}
var weapon_node
var pistol_normal_damage = 100
var pistol_crit_damage = 2
var pistol_damage = pistol_normal_damage
var grenade_launcher_damage = 5
var gl_explode

var enemy = null

var bullets_left = 5


enum states {WAIT, FIRE}
var state = states.WAIT

var pistol_crit_enabled = false
export var force_pistol_crit = false #for debug only
var g_bullets_enabled = false

var clip_empty_timer #timer for small wait after shooting to check if player won
					 #on last bullet
var clip_empty_wait = 0.3

var gp = 0
var gp_label

var bomb_btn
onready var actions = get_parent().get_node("actions")

func _ready():
	gp_label = get_parent().get_node("gp")
	bomb_btn = get_parent().get_node("actions/bomb")
	
	clip_empty_timer = Timer.new()
	clip_empty_timer.one_shot = true
	clip_empty_timer.wait_time = clip_empty_wait
	clip_empty_timer.connect("timeout", self, "end_shooting")
	add_child(clip_empty_timer)
	
	weapon_node = $pistol
	change_weapon(weapons.PISTOL)
	
	gl_explode = get_parent().get_node("gl_explode")
	gl_explode.connect("animation_finished",self,"gl_exploded")
	
	set_process(false)
	set_physics_process(false)
	
	$pistol/Sprite/AnimationPlayer.get_animation("spin").set_loop(true)
	$pistol/Sprite/AnimationPlayer.play("spin")
	
	if force_pistol_crit:
		print_debug("pistol crit forced mode")
		pistol_crit_enabled = true

#################
## Bonus wheel ##
#################
var pistol_critted = false
func set_pistol_to_bonus(val):
	pistol_critted = val

func activate(e):
	enemy = e
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	reload()
	set_process(true)
	set_physics_process(true)
	
	add_gp(-gp)
	
	if pistol_crit_enabled:
		$pistol/Sprite.show()
		$pistol/Sprite2.show()
	else:
		$pistol/Sprite.hide()
		$pistol/Sprite2.hide()
	if g_bullets_enabled:
		actions.get_node("gl_bullets").show()
	else:
		actions.get_node("gl_bullets").hide()
	

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
	
#	if Input.is_action_just_pressed("one"):
#		change_weapon(weapons.PISTOL)
#	elif Input.is_action_just_pressed("two"):
#		if get_parent().gp >= 500:
#			change_weapon(weapons.GRENADE_LAUCNHER)
#			get_parent().on_gp_drop(-500)

func _physics_process(delta):
	if state == states.FIRE and \
	Input.is_action_just_pressed("fire") and bullets_left > 0 and \
	get_global_mouse_position().y < SHOOTING_Y_LIMIT:
		
		var space = get_world_2d().direct_space_state
		
		var targets = null
		if weapon == weapons.PISTOL:
			targets = pistol_collision_query(space)
			$AudioStreamPlayer.play()
			if pistol_critted and pistol_crit_enabled:
				get_parent().get_node("pistol_bang").global_position = get_global_mouse_position()
				get_parent().get_node("pistol_bang/AnimationPlayer").play("bonus",-1,2)
				get_parent().get_node("pistol_bang/AnimationPlayer").seek(0)
				pistol_damage = pistol_crit_damage
				$ap_crit.play()
			else:
				get_parent().get_node("pistol_bang").global_position = get_global_mouse_position()
				get_parent().get_node("pistol_bang/AnimationPlayer").play("normal",-1,2)
				get_parent().get_node("pistol_bang/AnimationPlayer").seek(0)
				pistol_damage = pistol_normal_damage
			spend_bullet()
		elif weapon == weapons.GRENADE_LAUCNHER and gp >= 300: #and $load_bar.value == 100:
			targets = grenade_launcher_collision_query(space)
			gl_explode.global_position = get_global_mouse_position()
			gl_explode.show()
			gl_explode.play("default")
			$AudioStreamPlayer.play()
			$load_bar.value = 0
			
			add_gp(-300)
			spend_bullet()
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
		$AudioStreamPlayer.stream = load("res://sounds/pistol_sho9.wav")
	elif new_weapon == weapons.GRENADE_LAUCNHER:
		weapon = weapons.GRENADE_LAUCNHER
		$grenade_launcher/CollisionShape2D.disabled = false
		$grenade_launcher.show()
		weapon_node = $grenade_launcher
		$AudioStreamPlayer.stream = load("res://sounds/shotgun2.wav")

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
		clip_empty_timer.start()

func end_shooting():
	emit_signal("player_turn_completed")

func reload():
	bullets_left = 0
	for b in get_parent().get_node("bullets").get_children():
		b.show()
		bullets_left += 1

func _on_gl_bullets_button_down():
	change_weapon(weapons.GRENADE_LAUCNHER)

func add_gp(val):
	gp += val
	update_gp_text()
	update_actions()

func update_actions():
	if gp >= 1000:
		activate_hand_grenade()
	else:
		disable_hand_grenade()

func update_gp_text():
	var gp_as_string = str(gp)
	if gp_as_string.length() > 3:
		var first_comma = gp_as_string.length() - 3
		gp_as_string = gp_as_string.insert(first_comma, ",")
	
	gp_label.text = "¥" + gp_as_string

func change_to_normal_gun():
	change_weapon(weapons.PISTOL)

func use_bomb():
	add_gp(-1000)
	enemy.damage_to_all(1)

func activate_hand_grenade():
	bomb_btn.disabled = false
	bomb_btn.get_node("normal").bbcode_text = "Bomb \n[color=#008000]¥ 1 000[/color]"

func disable_hand_grenade():
	bomb_btn.disabled = true
	bomb_btn.get_node("normal").bbcode_text = "Bomb \n[color=#FF0000]¥ 1 000[/color]"
