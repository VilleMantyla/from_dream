extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	var line = Line2D.new()
#	line.add_point(Vector2(1072,127))
#	line.add_point(Vector2(843,606))
	pass # Replace with function body.


func _draw():
	var line = Line2D.new()
	line.add_point(Vector2(1072,127))
	line.add_point(Vector2(1072,827))
	add_child(line)
	
	draw_line(Vector2(1072,127), Vector2(843,606), Color.white, 8)

