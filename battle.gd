extends Node2D

signal leave_battle

var hp = 10
var gp = 0

var enemy

var leave_battle = false

var enemy_appear_timer

func _ready():
	$weapons.connect("player_turn_completed", self, "switch_to_enemy_turn")
	
	$dodge_arena/AnimationPlayer.connect("animation_finished", \
	self, "activate_vi")
	
	$bulletshooter.connect("bulletshooter_finished", \
	self, "on_bulletshooter_finished")
	
	for e in $Enemies.get_children():
		e.connect("enemy_died", self, "end_battle")
		e.connect("gp_dropped", self, "on_gp_drop")
		
		e.hide()
	
	set_process_input(false)
	
	$noise_screen/AnimationPlayer.connect("animation_finished", self, "noise_done")
	
	enemy_appear_timer = Timer.new()
	enemy_appear_timer.wait_time = 1000
	enemy_appear_timer.one_shot = true
	enemy_appear_timer.connect("timeout", self, "enemy_appear_finished")
	add_child(enemy_appear_timer)

func _input(event):
	if event.is_action_pressed("interact") and leave_battle:
		leave_battle()

#battle start animation (show noise and signal found sprite):
#first show 50% of animation, wait for (enemy_appear_timer) enemy to appear
#then show the rest of animation (battle_start_100%)

func start_battle(e):
	enemy = e
	$bulletshooter.set_pattern(e.bullet_pattern)
	show()
	set_process_input(true)
	$weapons.activate(enemy)
	enemy.show()
	
	$noise_screen/AnimationPlayer.play("battle_start_50%")

func noise_done(anim):
	if anim == "battle_start_50%":
		enemy_appear_timer.wait_time = enemy.appear_and_prepare()
		enemy_appear_timer.start()
	elif anim == "battle_start_100%":
		pass

func enemy_appear_finished():
	$noise_screen/AnimationPlayer.play("battle_start_100%")

func switch_to_player_turn():
	pass

func switch_to_enemy_turn():
	$dodge_arena/AnimationPlayer.play("fade_in",-1,1.2)

func activate_vi(anim):
	if anim == "fade_in":
		$vi.activate()
		get_node("bulletshooter").activate()


func on_gp_drop(val):
	gp += val
	var gp_as_string = str(gp)
	if gp_as_string.length() > 3:
		var first_comma = gp_as_string.length() - 3
		gp_as_string = gp_as_string.insert(first_comma, ",")
	
	$gp.text = "¥" + gp_as_string

func on_bulletshooter_finished():
	$vi.deactivate()
	$weapons.reload()
	$dodge_arena/AnimationPlayer.play("fade_out",-1,1.2)
	$dodge_arena/dodge_box.hide()

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
