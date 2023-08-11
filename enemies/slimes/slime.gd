extends Node2D

var id = null
var hp = 2

func disable_collisionshape(val):
	$big_slime/CollisionShape2D.disabled = val
