extends Spatial

func _ready():
	$Chat.connect("end_chat", self, "chat_ended")

func _process(delta):
	if Input.is_action_just_pressed("interact"):
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
