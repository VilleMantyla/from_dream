extends Control

var items_submenu

func _ready():
	items_submenu = $items_submenu

func open_menu():
	activate_topmenu()
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_menu():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_item_on_pickup(item):
	$ColorRect.hide()
	$topmenu_btn.hide()
	$GridContainer.hide()
	$vi.hide()
	
	$items_submenu.view_item_on_pickup(item)
	$items_submenu.show()
	
	show()

func add_new_item(item):
	items_submenu.add_new_item(item)
	reset_view()
	return items_submenu.item_data[item]["name"]

func reset_view():
	$ColorRect.show()
	$topmenu_btn.show()
	$GridContainer.show()
	$vi.show()
	
	$items_submenu.reset_view()

func activate_topmenu():
	hide_submenus()
	$GridContainer.show()

func hide_submenus():
	items_submenu.hide()

func show_items_submenu():
	$GridContainer.hide()
	items_submenu.show()
