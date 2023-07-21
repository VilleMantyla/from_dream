extends Node2D


var viewport_texture

var item_spin_speed = 1.3
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_texture = $Viewport.get_texture()
	$item_view.texture = viewport_texture
	
	$fade/AnimationPlayer.connect("animation_finished", self, "activate_menu")
	
	set_process(false)

func open_menu():
	$fade/AnimationPlayer.play("fade_out",-1,3)

func activate_menu(anim):
	if anim == "fade_out":
		set_process(true)
	elif anim == "fade_in":
		set_process(false)
		hide()
		$Viewport/items.global_rotation.y = 0
		

func close_menu():
	$fade/AnimationPlayer.play("fade_in",-1,3)


func _process(delta):
	spin_items(delta)

func spin_items(delta):
	var spin_step = item_spin_speed*delta
	$Viewport/items.global_rotation.y -= spin_step
	print($Viewport/items.global_rotation.y)
