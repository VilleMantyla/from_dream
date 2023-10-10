extends Area

export var chat_key = ""

func check():
	get_tree().get_current_scene().start_sd_chat(chat_key)

func cut_chain():
	$CollisionShape.disabled = true
	$AnimationPlayer.play("cut_chain")

func cut_finished():
	get_parent().get_node("CollisionShape").disabled = true
	get_parent().get_parent().get_node("small_cage_collision/CollisionShape").disabled = false
