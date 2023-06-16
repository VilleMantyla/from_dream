extends Node2D

export var hp = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func disable_collisionshape(val):
	$Area2D/CollisionShape2D.disabled = val
