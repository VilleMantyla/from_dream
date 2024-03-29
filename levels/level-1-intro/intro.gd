extends Node

signal focus_finished

func _ready():
	connect("focus_finished", self, "riri_jump")
	$noise/AnimationPlayer.connect("animation_finished",self,"noise_fade")
	$AudioStreamPlayer.connect("finished",self,"riri_run_audio_finished")
	
	$Player.activate(false)
	
	$fade_black/AnimationPlayer.play("fade_out",-1,0.6)
	$riri/AnimationPlayer.play("idle_on_cliff",-1,3)

func _on_riri_jump_body_entered(body):
	focus_on_point($riri.global_transform.origin)
	$bars/AnimationPlayer.play("bars_in")
	$Player.activate(false)

func riri_jump():
	$riri/AnimationPlayer.play("walk_off_clif+",-1,3)

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
	c_tween.tween_property($Player/rotation_helper, "global_transform:basis:y",\
	new_basis_for_helper.y, 0.95).set_trans(Tween.EASE_IN_OUT)
	var v_tween = create_tween()
	v_tween.connect("finished", self, "focus_finished")
	v_tween.tween_property($Player, "global_rotation", new_player_rot, 0.95).\
	set_trans(Tween.EASE_IN_OUT)

func focus_finished():
	emit_signal("focus_finished")

func play_riri_escape():
	$AudioStreamPlayer.play()

func riri_run_audio_finished():
	$bars/AnimationPlayer.play("bars_away",-1,3)
	$Player.activate(true)

func riri_jumped():
	$bars/AnimationPlayer.play("bars_away",-1,3)
	$Player.activate(true)

func _on_prompt_jump_q_body_entered(body):
	$question_prompt.show()
	$yes.show()
	$no.show()
	$Player.activate(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_yes_pressed():
	var tween = create_tween()
	var new_pos = $Player.global_transform.origin
	new_pos += Vector3(-1.7,0,-1.7)
	tween.tween_property($Player, "global_transform:origin", new_pos, 0.6).\
	set_trans(Tween.EASE_IN)
	$question_prompt.hide()
	$yes.hide()
	$no.hide()
	$Player.activate(true)

func _on_no_pressed():
	var tween = create_tween()
	var new_pos = $Player.global_transform.origin
	new_pos += Vector3(0.9,0,0.9)
	tween.tween_property($Player, "global_transform:origin", new_pos, 1)
	$question_prompt.hide()
	$yes.hide()
	$no.hide()
	$Player.activate(true)

func jumped_after_riri(body):
	$noise/AnimationPlayer.play("fade_in")

func noise_fade(anim):
	if anim == "fade_in":
		get_tree().change_scene("res://main.tscn")
