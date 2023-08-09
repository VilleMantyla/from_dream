extends StaticBody

func cut_chain():
	$AnimationPlayer.play("cut_chain")

func disable_collision_shape():
	$CollisionShape.disabled = true
