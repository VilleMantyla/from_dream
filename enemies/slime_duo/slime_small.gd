extends Node2D

var max_hp = 1
var hp = max_hp

var original_local_pos

var id = null
var big_slime

func _ready():
	original_local_pos = position
	big_slime = get_parent().get_parent()

func disable_collisionshape(val):
	$Area2D/CollisionShape2D.disabled = val

func get_big_slime():
	return big_slime
