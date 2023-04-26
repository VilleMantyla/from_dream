extends Spatial

#in editor, put btm_floor node on the bottom floor,
#floor_point on the next floor (and duplicate more points if needed) and
#climb_offset for climbing offset from the ladder
#top_max should be the top most floor_point's height (y coordinate)

var btm_max
export (NodePath) var top_max

var second_floor_height
var second_floor_exit_pos
#exit_dir btm (0,0) (middle)
#exit_dir right (1,0)
#exit_dir left (-1,0)
#exit_dir front (0,1)
export var second_floor_exit_dir = Vector2(1,0)

export var floors = 2

var climb_offset


func _ready():
	btm_max = $btm_floor.get_global_transform().origin.y
	top_max = get_node(top_max).get_global_transform().origin.y
	
	second_floor_height = $floor_point.get_global_transform().origin.y
	second_floor_exit_pos = $floor_point.get_global_transform().origin
	
	climb_offset = $climb_offset.get_global_transform().origin

func get_next_exit_pos(feet, eyes , exit_range):
	if feet <= btm_max + exit_range:
		#bottom
		print("ladder says player in bottom range")
		return [Vector3(climb_offset.x, eyes, climb_offset.z), Vector2(0,0)]
	elif eyes >= second_floor_height - exit_range and eyes <= second_floor_height + exit_range:
		#second floor
		return [second_floor_exit_pos, second_floor_exit_dir]
	else:
		print("ladder says no next floor")
		return null

func get_enter_height(floor_number, feet, eyes):
	if floor_number == 0:
		return eyes
	elif floor_number == 1 and floors == 2:
		return feet - 0.25
	else:
		print("ERROR with getting ladder enter height")
