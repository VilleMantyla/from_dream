extends Node2D

var id = null
var hp = 4
var dead = false

func disable_collisionshape(val):
	$Path2D/PathFollow2D/big_slime/Area2D/CollisionShape2D.disabled = val
	$Path2D/PathFollow2D/big_slime/CollisionShape2D.disabled = val

#var slide_shape
#var shape_index = 0
#
#func next_dir():
#	var dir = slide_shape[shape_index]
#	if shape_index == slide_shape.size()-1:
#		shape_index = 0
#	else:
#		shape_index += 1
#	return dir
