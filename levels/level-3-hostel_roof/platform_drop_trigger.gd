extends Area

var drop_platform

func _ready():
	drop_platform = get_parent().get_node("hostel_roof_model/drop_platform")
	set_process(false)

func drop_platform(body):
	set_process(true)

func _process(delta):
	drop_platform.global_transform.origin.y -= delta*6
