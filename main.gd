extends Spatial

var interactables = {
	"ladder" : "press space to cilmb"
}

func _ready():
	$Chat.connect("chat_ended", self, "end_chat")
	$Player.connect("show_context_msg", self, "show_context_msg")
	$Player.connect("next_chat_text", self, "read_next_chat")

var flip_open = true
#func _process(delta):
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

func show_context_msg(key):
	$context_msg.text = interactables[key]

func read_next_chat():
	$Chat.try_reading_next_paragraph()

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
