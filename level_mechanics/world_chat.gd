extends Node2D

var show_pos
var hide_pos = Vector2(0,390)

var current_chat_key

func _ready():
	show_pos = global_position
	global_position = hide_pos
	$dialog.connect("chat_ended", self, "end_chat")
	
	$yes_btn.connect("pressed", self, "on_player_answer", [true])
	$no_btn.connect("pressed", self, "on_player_answer", [false])

func start_chat(chat_file, chat_key):
	show()
	current_chat_key = chat_key
	var tween = create_tween()
	tween.connect("finished", self, "read_chat", [chat_file, chat_key])
	tween.tween_property(self, "global_position:y", show_pos.y, 0.6).set_trans(Tween.EASE_OUT)
	
	return get_chat()

func show_text(t):
	get_chat().text = t
	global_position = hide_pos
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", show_pos.y, 0.3).set_trans(Tween.EASE_OUT)

func read_chat(chat_file, chat_key):
	get_chat().start_chat(chat_file, chat_key)

func end_chat():
	hide()
	global_position = hide_pos

func get_chat():
	return $dialog

func on_player_answer(ans):
	if current_chat_key == "check_0":
		if ans:
			get_parent().pick_up_item(Global.items.PINKSOCK, null, "item_1")
		else:
			pass
	$yes_btn.hide()
	$no_btn.hide()
