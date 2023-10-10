extends StaticBody

export var chat_key = ""

func check():
	get_tree().get_current_scene().start_sd_chat(chat_key)

func cut_chain():
	$AnimationPlayer.play("cut_chain")

func disable_collision_shape():
	$CollisionShape.disabled = true
