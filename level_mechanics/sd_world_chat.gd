extends Node2D

var show_pos
var hide_pos = Vector2(0,390)

var current_chat_key

func _ready():
	show_pos = global_position
	global_position = hide_pos
	$dialog.connect("chat_ended", get_parent(), "end_sd_world_chat")
	$dialog.connect("character_code", self, "set_character_sprite")
	
	$yes_btn.connect("pressed", self, "on_player_answer", [true])
	$no_btn.connect("pressed", self, "on_player_answer", [false])

func start_chat(chat_file, chat_key):
	set_character_sprite(get_chat().get_character_code_before_chat(chat_file, chat_key))
	show()
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
	current_chat_key = chat_key
	get_chat().start_chat(chat_file, chat_key)

func end_chat():
	hide()
	$dialog.bbcode_text = ""
	global_position = hide_pos

func get_chat():
	return $dialog

func set_character_sprite(code):
	$vi.hide()
	$tv.hide()
	#check if new character or begin of chat to
	#if false for both, launch tween side pop
	if code == 10:
		$vi.show()
		$speaker.bbcode_text = "Vi"
	elif code == 20:
		$tv.play("hurt")
		$tv.show()
		$speaker.bbcode_text = "Girl"
	elif code == 21:
		$tv.play("annoyed_question")
		$speaker.bbcode_text = "Girl"
		
		$tv.position = Vector2(1500, 888)
		var tween = create_tween()
		tween.tween_property($tv, \
		"position", Vector2(1400, 888), 0.4).set_trans(Tween.EASE_OUT)
		
		$tv.show()

func on_player_answer(ans):
	if current_chat_key == "check_0":
		if ans:
			get_parent().get_node("Menu").show_item_on_pickup(Global.items.PINKSOCK)
			read_chat("res://texts/sd_world_chat.json", "check_0a")
		else:
			get_parent().end_sd_world_chat()
	elif current_chat_key == "check_0a":
		if ans:
			get_parent().pick_up_item(Global.items.PINKSOCK)
			read_chat("res://texts/sd_world_chat.json", "check_0b")
			get_parent().get_node("trash_can").chat_key = "check_0c"
		else:
			get_parent().cancel_item_pick_up()
	elif current_chat_key == "check_2":
		if ans:
			get_parent().pick_up_item(Global.items.BRACELET)
			read_chat("res://texts/sd_world_chat.json", "check_2a")
		else:
			get_parent().cancel_item_pick_up()
	elif current_chat_key == "check_4":
		if ans:
			get_parent().pick_up_item(Global.items.ANGLEGRINDER)
			read_chat("res://texts/sd_world_chat.json", "check_4a")
			get_parent().get_node("enemy_trigger3").show()
			get_parent().get_node("enemy_trigger4").show()
			get_parent().get_node("enemy_trigger3/CollisionShape").disabled = false
			get_parent().get_node("enemy_trigger4/CollisionShape").disabled = false
			get_parent().get_node("house_build_ver2/cafeteria_chain/cut_area").\
			chat_key = "check_7"
			get_parent().get_node("house_build_ver2/extra_chain").chat_key = "check_9"
		else:
			get_parent().cancel_item_pick_up()
	elif current_chat_key == "check_5":
		if ans:
			get_parent().pick_up_item(Global.items.MEMORYCARD)
			read_chat("res://texts/sd_world_chat.json", "check_5a")
			get_parent().get_node("tv_dead").chat_key = "plot_2"
		else:
			get_parent().cancel_item_pick_up()
	elif current_chat_key == "plot_2":
		if ans:
			get_parent().get_node("tv_dead/CollisionShape").disabled = true
			get_parent().end_sd_world_chat()
			get_parent().start_cutscene(get_parent().cutscenes.TV_RESURRECT)
		else:
			get_parent().end_sd_world_chat()
	elif current_chat_key == "check_7":
		#cut cafeteria chain
		if ans:
			get_parent().get_node("house_build_ver2/cafeteria_chain/cut_area").\
			cut_chain()
		get_parent().end_sd_world_chat()
	elif current_chat_key == "check_9":
		if ans:
			get_parent().get_node("house_build_ver2/extra_chain").\
			cut_chain()
		get_parent().end_sd_world_chat()
	$yes_btn.hide()
	$no_btn.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
