extends Node2D

signal bulletshooter_finished

var alive_bullets = []

func _ready():
	set_process(false)

func activate():
	alive_bullets = get_children().size()
	for bullet in get_children():
		bullet.global_position = bullet.origanal_pos
	set_process(true)

func _process(delta):
	for bullet in get_children():
		bullet.position += Vector2(0,1)*11

func _on_bullet_area_area_exited(area):
	alive_bullets -= 1
	if alive_bullets == 0:
		emit_signal("bulletshooter_finished")
		set_process(false)
