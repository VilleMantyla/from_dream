extends Area


func cut_chain():
	$CollisionShape.disabled = true
	$AnimationPlayer.play("cut_chain")

func cut_finished():
	get_parent().get_node("CollisionShape").disabled = true
	get_parent().get_parent().get_node("small_cage_collision/CollisionShape").disabled = false
