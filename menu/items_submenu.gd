extends Node2D

var viewport_texture
#var selected_item

var item_spin_speed = 1.3

var items = []

var item_button_group

var item_selected = -1

onready var item_data = {
	Global.items.BRACELET: {
		"3D": $Viewport/item_3dmodels/riris_bracelet,
		"name": "Bracelet"
	},
	Global.items.PINKSOCK: {
		"3D": $Viewport/item_3dmodels/pink_sock,
		"name": "Pink Sock"
	}
}

func _ready():
	viewport_texture = $Viewport.get_texture()
	$item_view.texture = viewport_texture
	
	item_button_group = ButtonGroup.new()
	
	#selected_item = $Viewport/items/riris_bracelet
	
	#set_process(false)
	set_process(true)

func _process(delta):
	if item_selected > -1:
		spin_selected_item(delta)

func spin_selected_item(delta):
	var spin_step = item_spin_speed*delta
	item_data[item_selected]["3D"].global_rotation.y -= spin_step

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
	
	for model in $Viewport/item_3dmodels.get_children():
		model.hide()
	for btn in $item_list.get_children():
		btn.pressed = false

func add_new_item(item):
	items.append(item)
	var empty_slot = $item_list.get_child(items.size()-1)
	empty_slot.set_button_group(item_button_group)
	empty_slot.get_node("Label").text = item_data[item]["name"]
	empty_slot.connect("button_down", self, "select_item", [item])
	
	empty_slot.show()
	item_data[item]["3D"].hide()

func select_item(item):
	if item_selected > -1:
		item_data[item_selected]["3D"].hide()
	item_data[item]["3D"].global_rotation.y = 0
	item_data[item]["3D"].show()
	item_selected = item
	
