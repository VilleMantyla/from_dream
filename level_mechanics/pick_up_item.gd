extends Area

export (Global.items) var item
export var chat_key = ""
export var sparkle = false

func _ready():
	if sparkle:
		$sparkle/AnimationPlayer.play("scale")

func pick_up():
	$model.hide()
	$sparkle.hide()
	get_parent().pick_up_item(item, self, chat_key)

func deactivate():
	$CollisionShape.disabled = true
