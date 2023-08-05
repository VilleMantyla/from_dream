extends Node2D


var viewport_texture
var selected_item

var item_spin_speed = 1.3

func _ready():
	viewport_texture = $Viewport.get_texture()
	$item_view.texture = viewport_texture
	
	selected_item = $Viewport/items/riris_bracelet
	set_process(false)

func activate_menu(val):
	if val:
		set_process(true)
	else:
		set_process(false)
		selected_item.global_rotation.y = 0
		

func activate_menu_with_new_item(new_item):
	vi_text_new_item(new_item)

func vi_text_new_item(new_item):
	$vi_chat_text.text = "Will uyou pick up the " + item_names[new_item] + "?"

func _process(delta):
	spin_selected_item(delta)

func spin_selected_item(delta):
	var spin_step = item_spin_speed*delta
	selected_item.global_rotation.y -= spin_step
	print(selected_item.global_rotation.y)


#################################################################
## TEXTS ##
#################################################################
var item_names = {
	Global.items.BRACELET : "Bracelet",
	Global.items.ANGLEGRINDER : "Angle Grinder"
}
