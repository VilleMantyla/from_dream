extends Spatial

enum cutscenes {FROM_TREE, BANGING_ELEVATOR, KILLING_TV}
var current_scene = null

var tv

var battle_on_hold = null

var interactables = {
	"ladder" : "press space to cilmb"
}

func _ready():
	$Chat.connect("chat_ended", self, "end_chat")
	$Player.connect("show_context_msg", self, "show_context_msg")
	$Player.connect("next_chat_text", self, "read_next_chat")
	
	$Battle.connect("leave_battle", self, "exit_battle")
	
	for gs in $glitch_suckers.get_children():
		gs.get_node("AnimationPlayer").get_animation("s_twiggle2_alt").set_loop(true)
		gs.get_node("AnimationPlayer").play("s_twiggle2_alt",-1,1.5)
	
	
	tv = $tv_ver2
	tv.get_node("AnimationPlayer").get_animation("on_the_noose").set_loop(true)
	tv.get_node("AnimationPlayer").play("on_the_noose",-1,2)
	tv.get_node("AnimationPlayer").connect("animation_finished", self, "tv_FROM_TREE_anims")
	
	$tv_3/AnimationPlayer.get_animation("banging_door").set_loop(true)
	$tv_3/AnimationPlayer.play("banging_door",-1,2)
	$tv_3/AnimationPlayer.get_animation("stuck").set_loop(true)
	$tv_3/AnimationPlayer.connect("animation_finished", self, "BANGING_ELEVATOR_anims")
	
	$void2/AnimationPlayer.get_animation("holding_tv_idle").set_loop(true)
	$void2/AnimationPlayer.play("holding_tv_idle")
	$tv_ver3/AnimationPlayer.get_animation("let_me_go").set_loop(true)
	$tv_ver3/AnimationPlayer.play("let_me_go",-1,1.5)
	#$tv_ver3/AnimationPlayer.play("die_in_hand",-1,0.5)
	


var flip_open = true
#func _process(delta):
#	if Input.is_action_just_pressed("interact"):
#		if $Player.looking_at_interactable:
#			if $Player.looking_at_interactable.is_in_group("ladder"):
#				$Player.climb_to_ladder()
#
##		if flip_open:
##			var location_tween = create_tween()
##			location_tween.tween_property($Player, "global_transform:origin", $door_test_spot.global_transform.origin, 1.8).set_trans(Tween.EASE_IN_OUT)
##			var target_rot_y = deg2rad(180)
##			var new_rot
##			if target_rot_y - $Player.global_rotation.y < PI:
##				new_rot = Vector3(0,deg2rad(180),0)
##			else:
##				new_rot = Vector3(0,deg2rad(-180),0)
##			var rot_tween = create_tween()
##			rot_tween.tween_property($Player, "global_rotation", new_rot, 1.8).set_trans(Tween.EASE_IN_OUT)
##			$house_floor2/AnimationPlayer.play("open",-1,0.45)
##		else:
##			$house_floor2/AnimationPlayer.play("close",-1,0.45)
##		flip_open = !flip_open
#		if $Player.interacting:
#			$Chat.try_reading_next_paragraph()

func show_character(code):
	if code == 1:
		$TVsprite.texture = load("res://tv/tv_angry_yell.png")
		$TVsprite.position = Vector2(1568, 1350)
		var new_pos = Vector2(1568, 824)
		var pop_up_tween = create_tween()
		pop_up_tween.tween_property($TVsprite, \
		"position", new_pos, 0.4).set_trans(Tween.EASE_OUT)
		$TVsprite.show()
		$TVsprite/AnimationPlayer.get_animation("decal_spin").set_loop(true)
		$TVsprite/AnimationPlayer.play("decal_spin")
	elif code == 2:
		$TVsprite/decal0.hide()
		$TVsprite/decal1.hide()
		$TVsprite/decal2.show()
		$TVsprite.texture = load("res://tv/tv_mocking_no_eye_sparkle.png")
		$TVsprite/AnimationPlayer.get_animation("half_closed_sparkle_up_down").set_loop(true)
		$TVsprite/AnimationPlayer.play("half_closed_sparkle_up_down",-1,5)
		$TVsprite.position = Vector2(1720, 824)
		var pop_up_tween = create_tween()
		pop_up_tween.tween_property($TVsprite, \
		"position", Vector2(1568, 824), 0.4).set_trans(Tween.EASE_OUT)
		#$TVsprite/AnimationPlayer.play("pop_left",-1,2.5)


func end_chat():
	$Chat.hide()
	$Player.disable_input(false)
	$Player.chatting = false
	$chat_bg.hide()
	
	check_for_cutscene_after_chat()
	
	if battle_on_hold:
		enter_battle(battle_on_hold)
	
	#RESET TVspirte node and its children
	$TVsprite.hide()

func check_for_cutscene_after_chat():
	if current_scene == cutscenes.FROM_TREE:
		remove_child(tv)
		$Path/PathFollow.add_child(tv)
		tv.global_transform.origin = Vector3.ZERO
		$Path.start_a_path()
	elif cutscene_chat == "tv_plead":
		KILLING_TV("tv_plead")
	else:
		return false

func enter_battle(enemy):
	battle_on_hold = null
	
	$Player.activate(false)
	
	$Battle.start_battle(enemy)

func exit_battle():
	$Battle.hide()
	$Player.activate(true)
	$Player.disable_input(false)
	print("fix player activate and disable input logic")

func show_context_msg(key):
	$context_msg.text = interactables[key]

func read_next_chat():
	$Chat.try_reading_next_paragraph()

func interact_with_world_object(chat, focus_point, enemy):
	if chat:
		$Chat.show()
		$chat_bg.show()
		$Chat.start_chat("res://texts/chat.json", chat)
		$Player.chatting = true
	if focus_point:
		focus_on_point(focus_point)
	if enemy:
		if chat:
			battle_on_hold = enemy
		else:
			enter_battle(enemy)
		
	$Player.disable_input(true)

func focus_on_point(focus_point):
	var original_rot = $Player/rotation_helper.global_rotation
	$Player/rotation_helper.look_at(focus_point, Vector3.UP)
	var new_basis_for_helper =  $Player/rotation_helper.global_transform.basis
	$Player/rotation_helper.global_rotation = original_rot
	
	original_rot = $Player.global_rotation
	$Player.look_at(focus_point, Vector3.UP)
	var new_player_rot = $Player.global_rotation
	$Player.global_rotation = original_rot
	new_player_rot.x = 0
	new_player_rot.z = 0

	var c_tween = create_tween()
	c_tween.tween_property($Player/rotation_helper, "global_transform:basis:y", new_basis_for_helper.y, 1).set_trans(Tween.EASE_IN_OUT)
	var v_tween = create_tween()
	v_tween.tween_property($Player, "global_rotation", new_player_rot, 1).set_trans(Tween.EASE_IN_OUT)

###############
## CUTSCENES ##
###############
# variable that will be checked at the end of a chat if there's next shot 
var cutscene_chat = null

func start_cutscene(cutscene_name):
	current_scene = cutscene_name
	if cutscene_name == cutscenes.FROM_TREE:
		tv.global_transform.origin.y = 0
		tv.get_node("AnimationPlayer").play("getting_up",-1,1.2)
		$cutscene_audio1.play()
		get_node("Camera2").current = true
	elif cutscene_name == cutscenes.BANGING_ELEVATOR:
		
		$Player.global_transform.origin = Vector3(-105.1,1.6,5.25)
		$Player.global_rotation.y = deg2rad(-160)
		$Player/rotation_helper.global_rotation.x = deg2rad(-19)
		
		
		var left = $house_build_ver2/elevatordoorbottom1
		var right = $house_build_ver2/elevatordoorbottom2
		var left_target = left.global_transform.origin.x + 0.07
		var right_target = right.global_transform.origin.x - 0.07
		var tween1 = create_tween()
		tween1.tween_property(left, "global_transform:origin:x", left_target, 0.25)
		var tween2 = create_tween()
		tween2.tween_property(right, "global_transform:origin:x", right_target, 0.25)
		tween2.connect("finished", self, "BANGING_ELEVATOR_anims", ["doors"])
	elif cutscene_name == cutscenes.KILLING_TV:
		$Camera4.current = true
		$Camera4/AnimationPlayer.play("floor_to_head",-1,0.4)

func end_cutscene():
	current_scene = null

func tv_FROM_TREE_anims(anim):
	if anim == "getting_up":
		tv.global_rotation.y = deg2rad(148)
		tv.get_node("AnimationPlayer").play("stand_rise")
		
		$Player.global_transform.origin = Vector3(-3.475,1.6,-10.2)
		$Player.global_rotation.y = deg2rad(148)
		$Player/rotation_helper.global_rotation.x = deg2rad(-10)
		$Player/rotation_helper/Camera.current = true
	
	if anim == "stand_rise":
		tv.get_node("AnimationPlayer").play("to_taunting")
	
	if anim == "to_taunting":
		tv.get_node("AnimationPlayer").get_animation("taunting_idle").set_loop(true)
		tv.get_node("AnimationPlayer").play("taunting_idle",-1,1.2)
		
		interact_with_world_object("melph_tree_first", false, false)

func BANGING_ELEVATOR_anims(anim):
	if anim == "doors":
		$tv_3/AnimationPlayer.play("fall_to_stuck")
		var trgt = $tv_3.global_transform.origin.z + 0.15
		var tween = create_tween()
		tween.tween_property($tv_3, "global_transform:origin:z", trgt, 0.8)
		$Chat.show()
		$Chat.start_chat_timed("res://texts/chat.json", "TV_fall_scream")
		#$Sprite.show()
	if anim == "fall_to_stuck":
		$tv_3/AnimationPlayer.play("stuck")
		$AnimationPlayer.play("rise")

func KILLING_TV(anim):
	if anim == "floor_to_head":
		$Camera5.current = true
		cutscene_chat = "tv_plead"
		$Chat.show()
		$chat_bg.show()
		$Chat.start_chat("res://texts/chat.json", "let_me_go")
		$Player.chatting = true
	elif anim == "tv_plead":
		cutscene_chat = null
		$Camera6.current = true
		$Camera6/AnimationPlayer.play("show_knife",-1,0.33)
	elif anim == "show_knife":
		$Camera7.current = true
		$void2/AnimationPlayer.play("knifing_tv_alt")
