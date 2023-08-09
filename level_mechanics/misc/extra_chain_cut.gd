extends StaticBody

func cut_chain():
	$CollisionShape.disabled = true
	$AnimationPlayer.play("cut_chain")
