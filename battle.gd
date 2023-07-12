extends Node2D

signal leave_battle

var hp = 10
var gp = 0

var enemy

var leave_battle = false

var temp_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	$weapons.connect("player_turn_completed", self, "switch_to_enemy_turn")
	$battle_start_label/AnimationPlayer.connect("animation_finished", \
	self, "on_battle_start_label_anim_finished")
	
#	$reload_text/AnimationPlayer.connect("animation_finished", \
#	self, "on_turn_label_anim_finished")
	
	$dodge_arena/AnimationPlayer.connect("animation_finished", \
	self, "activate_vi")
	
	$bulletshooter.connect("bulletshooter_finished", \
	self, "on_bulletshooter_finished")
	
	for enemy in $Enemies.get_children():
		enemy.connect("appear_finished", self, "on_enemy_appear_anim_finished")
		enemy.connect("enemy_died", self, "end_battle")
		enemy.connect("gp_dropped", self, "on_gp_drop")
		
		enemy.hide()
	
	set_process_input(false)
	
	temp_timer = Timer.new()
	temp_timer.wait_time = 1
	temp_timer.one_shot = true
	temp_timer.connect("timeout", self, "on_noise_timeout")
	add_child(temp_timer)
	
	$noise_screen/AnimationPlayer.connect("animation_finished", self, "noise_done")

func _input(event):
	if event.is_action_pressed("interact") and leave_battle:
		leave_battle()

func start_battle(e):
	enemy = e
	show()
	set_process_input(true)
	$weapons.activate(enemy)
	#enemy.activate()
	enemy.show()
	
	$noise_screen.show()
	$battle_start_label/AnimationPlayer.play("show_up2",-1,2)
	$battle_start_label/AnimationPlayer.seek(0.6)
	temp_timer.start()

func switch_to_player_turn():
	pass

func switch_to_enemy_turn():
	$dodge_arena/AnimationPlayer.play("fade_in",-1,1.2)

func activate_vi(anim):
	if anim == "fade_in":
		$vi.activate()
		get_node("bulletshooter").activate()

func on_noise_timeout():
	$noise_screen/AnimationPlayer.play("fade_off",-1,5)

func on_enemy_appear_anim_finished():
	
	$battle_start_label/AnimationPlayer.play("idle",-1,1.5)

func on_battle_start_label_anim_finished(anim):
	if anim == "idle":
		$battle_start_label/AnimationPlayer.play("go_away",-1,2)
#	elif anim == "go_away":
#		$turn_labels/AnimationPlayer.play("player_turn")

func end_battle():
	enemy = null
	leave_battle = true
	print("battle ended")
	
	$win.show()
	$win/gp_left.text = "Left: ¥" + str(gp)
	$win/AnimationPlayer.play("silly_money_to_bank_anim",-1,0.5)

func move_money_to_bank():
	$win/gp_left.text = "Left: ¥0"
	$win/bank.text = "BANK: ¥" + str(gp)

func leave_battle():
	leave_battle = false
	$weapons.deactivate()
	set_process_input(false)
	emit_signal("leave_battle")

func on_gp_drop(val):
	gp += val
	var gp_as_string = str(gp)
	if gp_as_string.length() > 3:
		var first_comma = gp_as_string.length() - 3
		gp_as_string = gp_as_string.insert(first_comma, ",")
	
	$gp.text = "¥" + gp_as_string

func noise_done(anim):
	if anim == "fade_off":
		enemy.activate()

func on_bulletshooter_finished():
	$vi.deactivate()
	$weapons.reload()
	$dodge_arena/AnimationPlayer.play("fade_out",-1,1.2)
	$dodge_arena/dodge_box.hide()
