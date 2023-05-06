extends Node2D


signal enemy_died

var part_count = 0


func _ready():
	deactivate()

func activate():
	for fly in get_children():
		fly.disable_collisionshape(false)
	part_count = get_children().size()

func deactivate():
	for fly in get_children():
		fly.disable_collisionshape(true)
