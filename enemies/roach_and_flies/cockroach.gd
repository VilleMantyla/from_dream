extends Node2D

var hp = 20
var shield = 5
var id = null

func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionPolygon2D.disabled = val
