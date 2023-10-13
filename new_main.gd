extends Node

var active_chat = null

var in_menu = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("menu") and !$menu_interact/AnimationPlayer.is_playing():
		if !in_menu:
			$menu_interact/AnimationPlayer.play("open_menu")
		elif in_menu:
			$menu_interact/AnimationPlayer.play("close_menu")
	if $Player.chatting:
		if Input.is_action_just_pressed("interact"):
			active_chat.try_reading_next_paragraph()

func start_sd_chat(key):
	active_chat = $sd_world_chat.start_chat("res://texts/sd_world_chat.json",\
	key)
	$Player.activate(false)
	$Player.chatting = true

func end_sd_world_chat():
	$sd_world_chat.end_chat()
	
	if !check_for_cutscene_after_chat():
		$Player.activate(true)

func check_for_cutscene_after_chat():
	return false
