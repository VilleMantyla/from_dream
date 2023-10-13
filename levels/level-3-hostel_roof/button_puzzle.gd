extends Node

var input = []

func set_new_input(code):
	if input.size() == 3:
		input.pop_front()
	input.append(code)
	
	if input.size() == 3:
		if input[0] == 0 and input[1] == 1 and input[2] == 2:
			open_door()

func open_door():
	get_parent().get_node("hostel_roof_model/locked_bars/AnimationPlayer").play("open",-1,2)
