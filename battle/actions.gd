extends Node2D

func activate_hand_grenade():
	$hand_grenade.disabled = false
	$hand_grenade/normal.bbcode_text = "Grenade \n[color=#008000]¥ 1 000[/color]"

func _on_hand_grenade_button_down():
	get_parent().add_gp(-1000)
	get_parent().enemy.damage_to_all(1)

func disable_hand_grenade():
	$hand_grenade.disabled = true
	$hand_grenade/normal.bbcode_text = "Grenade \n[color=#FF0000]¥ 1 000[/color]"
