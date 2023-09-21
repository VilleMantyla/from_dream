extends Node2D
signal damage_number_finished
var height = -200

func set_value_and_animate(val, start_pos):
	$container/RichTextLabel.bbcode_text = "[color=#FF0000]" + str(val) + "[/color]"
	
	var tween = create_tween()
	tween.connect("finished", self, "on_damage_number_animation_finished")
	var end_pos = Vector2(0,height)+start_pos
	tween.tween_property($container,"position",end_pos,1.2).from(start_pos)
	show()

func on_damage_number_animation_finished():
	emit_signal("damage_number_finished", self)
	hide()
