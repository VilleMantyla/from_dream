extends Node2D

signal bulletshooter_finished

var active_pattern = null

func _ready():
	pass

func set_pattern(pattern):
	active_pattern = pattern

func activate():
	active_pattern.reset_pattern()
	active_pattern.run_pattern()

#func _on_bullet_area_area_exited(area):
#	pass
#	alive_bullets -= 1
#	if alive_bullets == 0:
#		emit_signal("bulletshooter_finished")

#func _on_pattern_done():
#	emit_signal("bulletshooter_finished")

func do_damage(player):
	pass
