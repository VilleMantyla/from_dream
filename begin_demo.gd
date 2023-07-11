extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.start_chat("res://texts/chat.json", "begin_demo")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		$RichTextLabel.try_reading_next_paragraph()
