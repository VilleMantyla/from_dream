extends Control

var items_submenu

func _ready():
	items_submenu = $items_submenu

func hide_topmenu():
	$GridContainer.hide()

func open_menu():
	activate_topmenu()
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_menu():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func new_item(item):
	$ColorRect.hide()
	$topmenu_btn.hide()
	$GridContainer.hide()
	
	$items_submenu.show()
	$items_submenu/vi.hide()
	$items_submenu/TV.hide()
	$items_submenu/vi_chat_text.hide()
	$items_submenu/TV_chat_text.hide()
	$items_submenu/Control.hide()
	
	$items_submenu.new_item_view(item)
	
	show()

func add_new_item(item):
	pass

func activate_topmenu():
	hide_submenus()
	$GridContainer.show()

func hide_submenus():
	items_submenu.hide()

func show_items_submenu():
	hide_topmenu()
	items_submenu.show()
