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
	get_parent().get_node("Menu").show_item_on_pickup(item)
	get_parent().pick_up_area = self
	get_parent().start_sd_chat(chat_key, self)

func deactivate():
	$CollisionShape.disabled = true

func reactivate():
	$model.show()
	$sparkle.show()
