extends Node2D


var viewport_texture
var selected_item

var item_spin_speed = 1.3
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_texture = $Viewport.get_texture()
	$item_view.texture = viewport_texture
	
	#$fade/AnimationPlayer.connect("animation_finished", self, "activate_menu")
	
	selected_item = $Viewport/items/riris_bracelet
	set_process(false)

#func open_menu():
#	$fade/AnimationPlayer.play("fade_out",-1,3)

func activate_menu(val):
	if val:
		set_process(true)
	else:
		set_process(false)
		#hide()
		selected_item.global_rotation.y = 0
		

#func close_menu():
#	$fade/AnimationPlayer.play("fade_in",-1,3)


func _process(delta):
	spin_selected_item(delta)

func spin_selected_item(delta):
	var spin_step = item_spin_speed*delta
	selected_item.global_rotation.y -= spin_step
	print(selected_item.global_rotation.y)
