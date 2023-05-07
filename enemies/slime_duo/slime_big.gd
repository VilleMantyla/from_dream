extends Node2D

var hp = 10

func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionShape2D.disabled = val
