extends Node2D

func _ready():
	$RichTextLabel.start_chat("res://texts/chat.json", "begin_demo")
	$RichTextLabel.connect("chat_ended", self, "end_chat")

func _input(event):
	if event.is_action_pressed("interact"):
		$RichTextLabel.try_reading_next_paragraph()

func end_chat():
	get_tree().change_scene("res://main.tscn")
