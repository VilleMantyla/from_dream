extends Node

signal focus_finished

func _ready():
	connect("focus_finished", self, "riri_jump")
	$fade_black/AnimationPlayer.connect("animation_finished",self,"on_fade")
	
	$fade_black/AnimationPlayer.play("fade_out",-1,0.6)

func _on_riri_jump_body_entered(body):
	focus_on_point($riri2.global_transform.origin)

func riri_jump():
	$riri_jump/AnimationPlayer.play("jump",-1,0.4)

func _on_jump_after_body_entered(body):
	$fade_black/AnimationPlayer.play("fade_in",-1,0.5)

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

func on_fade(anim):
	if anim == "fade_in":
		get_tree().change_scene("res://levels/intro/vi_greeting.tscn")
	elif anim == "fade_out":
		pass

func play_riri_escape():
	$AudioStreamPlayer.play()
