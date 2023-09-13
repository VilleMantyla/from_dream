extends Area

export (Global.items) var item_name


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body

func pick_up():
	$model.hide()
	get_parent().pick_up_item(item_name)
