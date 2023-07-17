extends Node2D


var speed = 400

var flies = []


# Called when the node enters the scene tree for the first time.
func _ready():
	flies.append($fly_bullet)
	flies.append($fly_bullet2)


func _process(delta):
	for fly in flies:
		var pf = fly.get_node("PathFollow2D")
		pf.set_offset(pf.get_offset()+speed*delta)
