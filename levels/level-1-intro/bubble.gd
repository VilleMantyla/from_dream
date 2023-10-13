extends Node2D


var center = Vector2(600,600)
var radius = 100
var point_count = 32
var color = Color.aqua

var speed = 100
var radious_org = radius

# Called when the node enters the scene tree for the first time.
func _ready():
	update()

func _process(delta):
	
	var step = speed*delta
	
	if radius == 0:
		radius = radious_org
	elif radius - step > 0:
		radius -= step
	else:
		radius = 0
	update()

func _draw():
	draw_arc(center, radius, 0, TAU, point_count, color)
	draw_arc(center, radius-1, 0, TAU, point_count, color)
	draw_arc(center, radius-2, 0, TAU, point_count, color)

