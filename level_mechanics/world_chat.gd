extends Node2D

func _ready():
	$chat.connect("chat_ended", get_parent(), "end_world_chat")
