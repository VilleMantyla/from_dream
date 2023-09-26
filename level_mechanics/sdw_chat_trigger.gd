extends Area

export var chat_key = ""

func check():
	get_parent().start_sd_chat(chat_key)
