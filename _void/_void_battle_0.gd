extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.connect("animation_finished", self, "on_animation_finished")
	$RichTextLabel.connect("chat_ended", get_parent(), "end_alt_chat")

func start():
	$AnimationPlayer.play("begin",-1,1)

func on_animation_finished(anim):
	$RichTextLabel.start_chat("res://texts/01-hostel_world_chat.json", "9_chat")
