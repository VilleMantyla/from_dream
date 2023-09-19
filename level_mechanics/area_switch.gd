extends Area

export var target_pos = Vector3(-112.5,0,-5.5)
export var target_rot = Vector3.ZERO

export var slide_to_pos = false

export var locked = false
export var locked_msg_key = ""

func check_lock():
	if locked:
		get_parent().start_sd_chat(locked_msg_key)
	return locked
