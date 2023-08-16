extends Node2D

var hp = 2
var id = null

func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionShape2D.disabled = val
