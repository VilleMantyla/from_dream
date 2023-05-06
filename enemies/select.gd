extends Area2D

export (NodePath) var scene_root

func _ready():
	scene_root = get_node(scene_root)

func get_target():
	return scene_root
