extends StaticBody

export var y_rotation = 0

var is_open = false

func get_door_spot(loc):
	var spot_a = $door/door_spot_a.global_transform.origin
	var spot_b = $door/door_spot_b.global_transform.origin
	
	if spot_a.distance_to(loc) < spot_b.distance_to(loc):
		return spot_a
	else:
		if abs(y_rotation/90) == 0 or abs(y_rotation/90) == 2:
			spot_b.z -= 0.5
		else:
			spot_b.x -= 0.5
		return spot_b

func get_roty(loc):
	var spot_a = $door/door_spot_a.global_transform.origin
	var spot_b = $door/door_spot_b.global_transform.origin
	
	if spot_a.distance_to(loc) < spot_b.distance_to(loc):
		return deg2rad(y_rotation)
	else:
		return deg2rad(y_rotation*-1)

func play_anim(s):
	$AnimationPlayer.play("open",-1,s)


func _on_closedoor_body_exited(body):
	if is_open:
		$AnimationPlayer.play("close", -1, 1.5)
		is_open = false
