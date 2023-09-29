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
	get_node("/root/Main/Menu").show_item_on_pickup(item)
	get_node("/root/Main").pick_up_area = self
	get_node("/root/Main").start_sd_chat(chat_key)

func deactivate():
	$CollisionShape.disabled = true

func reactivate():
	$model.show()
	if sparkle:
		$sparkle.show()
