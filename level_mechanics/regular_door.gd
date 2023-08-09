extends StaticBody

var is_open = false
enum move_axes{X, Z}
export (move_axes) var move_axis

func get_door_spot(loc):
	var spot_a = $door/door_spot_a.global_transform.origin
	var spot_b = $door/door_spot_b.global_transform.origin
	
	if spot_a.distance_to(loc) < spot_b.distance_to(loc):
		return spot_a
	else:
#		if abs(y_rotation/90) == 0 or abs(y_rotation/90) == 2:
#			spot_b.z -= 0.5
#		else:
#			spot_b.x -= 0.5
		return spot_b

func get_roty(loc, rot):
	var spot_a = $door/door_spot_a.global_transform.origin
	var spot_b = $door/door_spot_b.global_transform.origin
	
	if move_axis == move_axes.X:
		if spot_a.distance_to(loc) < spot_b.distance_to(loc):
			#A-SIDE
			return deg2rad(-90)
		else:
			#B-SIDE
			return deg2rad(90)
	else:
		if spot_a.distance_to(loc) < spot_b.distance_to(loc):
			#A-SIDE
			return deg2rad(0)
		else:
			if rot.y < 0:
				return deg2rad(-180)
			else:
				return deg2rad(180)

func play_anim(s):
	$AnimationPlayer.play("open",-1,s)


func _on_closedoor_body_exited(body):
	if is_open:
		$AnimationPlayer.play("close", -1, 1.5)
		is_open = false
