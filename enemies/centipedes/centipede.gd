extends Node2D

export var hp = 2
export var shield = 0
var enemy_name = "centipede"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionShape2D.disabled = val
	$Path2D/PathFollow2D2/Area2D/CollisionShape2D.disabled = val
