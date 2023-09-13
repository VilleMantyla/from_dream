extends Node2D

var viewport_texture
var selected_item

var item_spin_speed = 1.3

onready var item_data = {
	Global.items.BRACELET: {
		"3D": $Viewport/items/riris_bracelet,
		"name": "Bracelet"
	}
}

func _ready():
	viewport_texture = $Viewport.get_texture()
	$item_view.texture = viewport_texture
	
	#selected_item = $Viewport/items/riris_bracelet
	
	set_process(false)

func activate_menu(val):
	if val:
		#set_process(true)
		pass
	else:
		set_process(false)
		selected_item.global_rotation.y = 0

func _process(delta):
	spin_selected_item(delta)

func spin_selected_item(delta):
	var spin_step = item_spin_speed*delta
	selected_item.global_rotation.y -= spin_step
	print(selected_item.global_rotation.y)

func new_item_view(item):
	item_data[item]["3D"].show()
