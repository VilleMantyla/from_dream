extends "res://enemies/enemy.gd"

var speed = 300
var centipede_pfs = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for c in get_children():
		centipede_pfs.append([c.get_node("Path2D/PathFollow2D"), c.get_node("Path2D/PathFollow2D2")])

func _process(delta):
	for c in centipede_pfs:
		c[0].set_offset(c[0].get_offset()+speed*delta)
		c[1].set_offset(c[1].get_offset()+speed*delta)
