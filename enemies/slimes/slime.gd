extends Node2D

var id = null
var hp = 1

func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionShape2D.disabled = val
