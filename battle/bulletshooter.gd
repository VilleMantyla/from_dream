extends Node2D

signal bulletshooter_finished

var alive_bullets = []

var active_pattern

func _ready():
	set_process(false)
	active_pattern = $maggot_bullet_pattern
#	for bullet in get_children():
#		bullet.connect("body_entered", self, "do_damage")

func activate():
	active_pattern.reset_pattern()
	alive_bullets = $maggot_bullet_pattern.get_children().size()
	set_process(true)

func _process(delta):
	active_pattern.run(delta)

func _on_bullet_area_area_exited(area):
	alive_bullets -= 1
	if alive_bullets == 0:
		emit_signal("bulletshooter_finished")
		set_process(false)

func do_damage(player):
	pass

#######################
## SHOOTING PATTERNS ##
#######################
