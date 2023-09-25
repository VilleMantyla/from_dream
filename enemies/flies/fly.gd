extends Node2D

var hp = 2
var id = null
var dead = false

export var reverse = false

func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionShape2D.disabled = val

func _ready():
	if reverse:
		var curve = $Path2D.get_curve()
		var points = curve.get_baked_points()
		points.invert()
		curve.clear_points()
		for point in points:
			curve.add_point(point)
