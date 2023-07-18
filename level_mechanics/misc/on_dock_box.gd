extends Area

func _on_on_box_body_entered(body):
	get_parent().get_node("dock_box_climb/CollisionShape").disabled = true
	get_parent().get_node("dock_box_climb2/CollisionShape").disabled = true

func _on_on_box_body_exited(body):
	get_parent().get_node("dock_box_climb/CollisionShape").disabled = false
	get_parent().get_node("dock_box_climb2/CollisionShape").disabled = false
