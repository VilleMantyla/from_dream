extends Area

export var chat_key = "empty"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func check():
	get_parent().start_sd_chat("check_0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
