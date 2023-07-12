extends Node2D

var left_line
var right_line
var top_line
var bottom_line

var line_thickness = 3

func _ready():
	set_process(false)
	
	left_line = Line2D.new()
	add_child(left_line)
	right_line = Line2D.new()
	add_child(right_line)
	top_line = Line2D.new()
	add_child(top_line)
	bottom_line = Line2D.new()
	add_child(bottom_line)
	
	left_line.width = line_thickness
	right_line.width = line_thickness
	top_line.width = line_thickness
	bottom_line.width = line_thickness
	
	largen_box()

func largen_box():
	left_line.add_point(Vector2(960,540))
	left_line.add_point(Vector2(960,541))
	
	right_line.add_point(Vector2(961,540))
	right_line.add_point(Vector2(961,541))
	
	top_line.add_point(Vector2(960,540))
	top_line.add_point(Vector2(961,540))
	
	bottom_line.add_point(Vector2(960,541))
	bottom_line.add_point(Vector2(961,541))
	
	set_process(true)

func _process(delta):
	var left_top = left_line.get_point_position(0)
	var left_bottom = left_line.get_point_position(1)
	
	left_line.set_point_position(0,Vector2(left_top.x-1,left_top.y - 1))
	left_line.set_point_position(1,Vector2(left_bottom.x-1,left_bottom.y + 1))
	
	var right_top = right_line.get_point_position(0)
	var right_bottom = right_line.get_point_position(1)
	
	right_line.set_point_position(0,Vector2(right_top.x+1,right_top.y - 1))
	right_line.set_point_position(1,Vector2(right_bottom.x+1,right_bottom.y + 1))
	
	var top_line_left = top_line.get_point_position(0)
	var top_line_right = top_line.get_point_position(1)
	
	top_line.set_point_position(0,Vector2(top_line_left.x-1,top_line_left.y - 1))
	top_line.set_point_position(1,Vector2(top_line_right.x+1,top_line_right.y - 1))
	
	var bottom_line_left = bottom_line.get_point_position(0)
	var bottom_line_right = bottom_line.get_point_position(1)
	
	bottom_line.set_point_position(0,Vector2(bottom_line_left.x-1,bottom_line_left.y+1))
	bottom_line.set_point_position(1,Vector2(bottom_line_right.x+1,bottom_line_right.y+1))
