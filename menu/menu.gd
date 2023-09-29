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
	$items_submenu.reset_view()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_item_on_pickup(item):
	$ColorRect.hide()
	$topmenu_btn.hide()
	$GridContainer.hide()
	$vi.hide()
	
	$kanji_submenu.hide()
	$weapons.hide()
	
	$items_submenu.view_item_on_pickup(item)
	$items_submenu.show()
	
	show()

func add_new_item(item):
	items_submenu.add_new_item(item)
	reset_item_view()
	return items_submenu.item_data[item]["name"]

func reset_item_view():
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
	$weapons.hide()
	$kanji_submenu.hide()

func show_items_submenu():
	$GridContainer.hide()
	items_submenu.show()

func show_weapons_submenu():
	$GridContainer.hide()
	$weapons.show()

func show_kanji_submenu():
	$GridContainer.hide()
	$kanji_submenu.set_state($kanji_submenu.states.MENU)
	$kanji_submenu.show()

func show_kanji_puzzle():
	$ColorRect.hide()
	$topmenu_btn.hide()
	$GridContainer.hide()
	$vi.hide()
	
	$kanji_submenu.set_state($kanji_submenu.states.PUZZLE)
	$kanji_submenu.show()
