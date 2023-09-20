extends CollisionObject

export var chat_key = ""
export var f_path = "res://texts/01-hostel_world_chat.json"

func activate_world_chat():
	get_parent().start_world_chat(f_path, chat_key)
