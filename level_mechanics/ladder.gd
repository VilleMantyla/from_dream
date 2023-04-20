extends Area

var btm_max
var top_max

var second_floor
var second_floor_landing_pos

var climb_offset

func _ready():
	btm_max = $btm_floor.get_global_transform().origin.y
	top_max = $floor_point.get_global_transform().origin.y
	
	second_floor = top_max
	second_floor_landing_pos = $floor_point.get_global_transform().origin
	
	climb_offset = $climb_offset.get_global_transform().origin

func get_next_floor_point(height):
	if height == second_floor:
		return second_floor_landing_pos
	else:
		return false
