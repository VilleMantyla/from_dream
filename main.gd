extends Spatial

enum cutscenes {IN_TREE}
var current_scene = cutscenes.IN_TREE

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
		gs.get_node("AnimationPlayer").get_animation("twiggle_normal").set_loop(true)
		gs.get_node("AnimationPlayer").play("twiggle_normal",-1,1)
	
	
	tv = $tv_ver2
	if current_scene == cutscenes.IN_TREE:
		tv_in_tree()
		tv.get_node("AnimationPlayer").connect("animation_finished", self, "tv_in_tree_anims")

func tv_in_tree():
	tv.get_node("AnimationPlayer").get_animation("on_the_noose").set_loop(true)
	tv.get_node("AnimationPlayer").play("on_the_noose",-1,2)

func start_cutscene(cutscene_name):
	if cutscene_name == cutscenes.IN_TREE:
		tv.global_transform.origin.y = 0
		tv.get_node("AnimationPlayer").play("getting_up",-1,1.2)
		get_node("AudioStreamPlayer2D").play()
		get_node("Camera2").current = true

var flip_open = true
#func _process(delta):
#	$Camera.translation.y -= delta*0.5
#	print("asdfsadfsda")
#	if $Camera.translation.y <= 1.5:
#		set_process(false)
#	if $Player.looking_at_interactable:
#		if $Player.looking_at_interactable.is_in_group("ladder"):
#			$context_msg.text = "press space to climb"
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

func end_chat():
	$Chat.hide()
	$Player.disable_input(false)
	$Player.chatting = false
	
	check_if_cutscene_continues()
	if battle_on_hold:
		enter_battle(battle_on_hold)

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

func check_if_cutscene_continues():
	if current_scene == cutscenes.IN_TREE:
		remove_child(tv)
		$Path/PathFollow.add_child(tv)
		tv.global_transform.origin = Vector3.ZERO
		$Path.start_a_path()
		$Sprite.hide()
	else:
		return false

func tv_in_tree_anims(anim):
	if anim == "getting_up":
		tv.global_rotation.y = deg2rad(-22.5)
		tv.get_node("AnimationPlayer").play("stand_rise")
		
		$Player.global_transform.origin = Vector3(113,1.6,-25)
		$Player.global_rotation.y = deg2rad(-22.5)
		$Player/rotation_helper.global_rotation.x = deg2rad(-10)
		$Player/rotation_helper/Camera.current = true
	
	if anim == "stand_rise":
		tv.get_node("AnimationPlayer").play("to_taunting")
	
	if anim == "to_taunting":
		tv.get_node("AnimationPlayer").get_animation("taunting_idle").set_loop(true)
		tv.get_node("AnimationPlayer").play("taunting_idle",-1,1.2)
		
		$Sprite.show()
		interact_with_world_object("melph_tree_first", false, false)


func _on_teleport_forest(body):
	$Player.global_transform.origin = Vector3(0,1.6,-5.5)
	$Player.global_rotation.y = deg2rad(-90)
	pass # Replace with function body.


