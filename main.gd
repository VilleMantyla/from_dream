extends Spatial

func _ready():
	$Chat.connect("end_chat", self, "chat_ended")

var flip_open = true
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if $Player.looking_at_interactable:
			if $Player.looking_at_interactable.is_in_group("ladder"):
				$Player.clibm_to_ladder()
				
#		if flip_open:
#			var location_tween = create_tween()
#			location_tween.tween_property($Player, "global_transform:origin", $door_test_spot.global_transform.origin, 1.8).set_trans(Tween.EASE_IN_OUT)
#			var target_rot_y = deg2rad(180)
#			var new_rot
#			if target_rot_y - $Player.global_rotation.y < PI:
#				new_rot = Vector3(0,deg2rad(180),0)
#			else:
#				new_rot = Vector3(0,deg2rad(-180),0)
#			var rot_tween = create_tween()
#			rot_tween.tween_property($Player, "global_rotation", new_rot, 1.8).set_trans(Tween.EASE_IN_OUT)
#			$house_floor2/AnimationPlayer.play("open",-1,0.45)
#		else:
#			$house_floor2/AnimationPlayer.play("close",-1,0.45)
#		flip_open = !flip_open
		if $Player.interacting:
			$Chat.try_reading_next_paragraph()

func chat_ended():
	$Chat.hide()
	$Player.disable_input(false)

func interact_with_world_object(node_pos, object_text, focus, enemy):
	$Chat.show()
	$Chat.start_chat("res://texts/chat.json", object_text)
	$Player.disable_input(true)
	$Player.interacting = true
	
	if focus:
		focus_on_node(node_pos)
	if enemy:
		#start_battle_after_chat = enemy
		pass

func focus_on_node(node_pos):
	var original_rot = $Player/rotation_helper.global_rotation
	$Player/rotation_helper.look_at(node_pos, Vector3.UP)
	var new_basis_for_helper =  $Player/rotation_helper.global_transform.basis
	$Player/rotation_helper.global_rotation = original_rot
	
	original_rot = $Player.global_rotation
	$Player.look_at(node_pos, Vector3.UP)
	var new_player_rot = $Player.global_rotation
	$Player.global_rotation = original_rot
	new_player_rot.x = 0
	new_player_rot.z = 0

	var c_tween = create_tween()
	c_tween.tween_property($Player/rotation_helper, "global_transform:basis:y", new_basis_for_helper.y, 1).set_trans(Tween.EASE_IN_OUT)
	var v_tween = create_tween()
	v_tween.tween_property($Player, "global_rotation", new_player_rot, 1).set_trans(Tween.EASE_IN_OUT)
