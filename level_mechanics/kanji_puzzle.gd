extends StaticBody

export var answer = ""

func open():
	remove_from_group("kanji_puzzle")
	$AnimationPlayer.play("open",-1,0.5)
