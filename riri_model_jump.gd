extends MeshInstance



func _on_Area_body_entered(body):
	$AnimationPlayer.play("jump",-1,0.3)
	print("jump")
