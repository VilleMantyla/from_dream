extends Node2D

var viewport_texture
var selected_item

var item_spin_speed = 1.3

var items = []

onready var item_data = {
	Global.items.BRACELET: {
		"3D": $Viewport/item_3dmodels/riris_bracelet,
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

func view_item_on_pickup(item):
	$vi.hide()
	$tv.hide()
	$items_chat.hide()
	$item_list_bg.hide()
	$item_view_bg.hide()
	$item_list.hide()
	
	$item_view.show()
	item_data[item]["3D"].show()

func reset_view():
	$item_list_bg.show()
	$item_view_bg.show()
	$item_list.show()
	#$item_view.hide()
	#item_data[item]["3D"].hide()
	

func add_new_item(item):
	items.append(item)
	var empty_slot = $item_list.get_child(items.size()-1)
	empty_slot.get_node("Label").text = item_data[item]["name"]
	empty_slot.show()
