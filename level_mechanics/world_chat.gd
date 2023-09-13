extends Node2D

var show_pos
var hide_pos = Vector2(0,390)

func _ready():
	show_pos = global_position
	global_position = hide_pos
	$dialog.connect("chat_ended", self, "end_chat")

func start_chat(chat_file, chat_key):
	show()
	var tween = create_tween()
	tween.connect("finished", self, "read_chat", [chat_file, chat_key])
	tween.tween_property(self, "global_position:y", show_pos.y, 0.6).set_trans(Tween.EASE_OUT)
	
	return get_chat()

func read_chat(chat_file, chat_key):
	get_chat().start_chat(chat_file, chat_key)

func end_chat():
	hide()
	global_position = hide_pos

func get_chat():
	return $dialog
