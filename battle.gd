extends Node2D

signal leave_battle

enum statuses{NORMAL, POISONING, POISONED}
var status

var hp = 10
var gp = 0

var enemy

var leave_battle = false

#var messages
var msg_timer
var msg_time_normal = 1.5
var msg_time_attack = 1

var poison_dmg_timer

var temp_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	$weapons.connect("player_turn_completed", self, "switch_to_enemy_turn")
	$battle_start_label/AnimationPlayer.connect("animation_finished", \
	self, "on_battle_start_label_anim_finished")
	
	$turn_labels/AnimationPlayer.connect("animation_finished", \
	self, "on_turn_label_anim_finished")
	
	$black_arena/AnimationPlayer.connect("animation_finished", \
	self, "activate_tamagotchi")
	
	$bulletshooter.connect("bulletshooter_finished", \
	self, "on_bulletshooter_finished")
	
	for enemy in $Enemies.get_children():
		enemy.connect("appear_finished", self, "on_enemy_appear_anim_finished")
		enemy.connect("enemy_died", self, "end_battle")
		enemy.connect("attack", self, "hurt_player")
		enemy.connect("attack_message", self, "show_message")
		enemy.connect("clear_message", self, "set_message_to_be_cleared")
		enemy.connect("gp_dropped", self, "on_gp_drop")
		
		enemy.hide()
	
	$AnimationPlayer.connect("animation_finished", self, "on_animation_finished")
	
	#messages = $msg_box/messages
	msg_timer = Timer.new()
	msg_timer.wait_time = msg_time_normal
	msg_timer.one_shot = true
	msg_timer.connect("timeout",self,"clear_message")
	add_child(msg_timer)
	
	poison_dmg_timer = Timer.new()
	poison_dmg_timer.wait_time = 1
	poison_dmg_timer.one_shot = false
	poison_dmg_timer.connect("timeout",self,"hurt_player",[EnemyStuff.attack_types.NORMAL, 1])
	add_child(poison_dmg_timer)
	
	set_process_input(false)
	
	temp_timer = Timer.new()
	temp_timer.wait_time = 1
	temp_timer.one_shot = true
	temp_timer.connect("timeout", self, "on_noise_timeout")
	add_child(temp_timer)
	
	$noise_screen/AnimationPlayer.connect("animation_finished", self, "noise_done")
	#$poison_bg/AnimationPlayer.get_animation("poisoning").set_loop(true)

func _input(event):
	if event.is_action_pressed("interact") and leave_battle:
		leave_battle()

func _process(delta):
	check_statuses(delta)

func start_battle(e):
	enemy = e
	show()
	set_process_input(true)
	$weapons.activate(enemy)
	#enemy.activate()
	enemy.show()
	var msg = EnemyStuff.fetc_message(enemy.name, EnemyStuff.types.BEGIN)
	show_pop_message(msg)
	#$hp.bbcode_text = "HP: " + str(hp)
	
	$noise_screen.show()
	$battle_start_label/AnimationPlayer.play("show_up2",-1,2)
	$battle_start_label/AnimationPlayer.seek(0.6)
	temp_timer.start()

func switch_to_player_turn():
	pass

func switch_to_enemy_turn():
	$black_arena/AnimationPlayer.play("fade_in",-1,1.2)
	#$turn_labels/AnimationPlayer.play("enemy_turn",-1,2)
	#$black_arena/AnimationPlayer.play("fade_in",-1,2)

func activate_tamagotchi(anim):
	if anim == "fade_in":
		get_node("tamagotchi").activate()
		get_node("bulletshooter").activate()

func on_noise_timeout():
	$noise_screen/AnimationPlayer.play("fade_off",-1,5)

func on_enemy_appear_anim_finished():
	$AnimationPlayer.play("message_off",-1,4.5)
	
	$battle_start_label/AnimationPlayer.play("idle",-1,1.5)

func on_battle_start_label_anim_finished(anim):
	if anim == "idle":
		$battle_start_label/AnimationPlayer.play("go_away",-1,2)
#	elif anim == "go_away":
#		$turn_labels/AnimationPlayer.play("player_turn")

func show_player_turn_label():
	$turn_labels/AnimationPlayer.play("player_turn",-1,1)

#func show_enemy_turn_label():
#	#$turn_labels/AnimationPlayer.play("enemy_turn",-1,0.9)
#	pass

func on_turn_label_anim_finished(anim):
	pass
#	if anim == "player_turn":
#		print("activate gun and show sight (maybe a flashing animation for it too)")
	if anim == "enemy_turn":
		pass
		#$black_arena/AnimationPlayer.play("fade_in",-1,1.5)
#		get_node("tamagotchi").activate()
#		get_node("dodge_arena").show()
#		get_node("bulletshooter").activate()

func show_pop_message(message):
	$pop_msg/message.bbcode_text = message
	$AnimationPlayer.play("message_pop",-1,2.5)
	$pop_msg.hide()
	#msg_timer.start()

func show_message(message):
	$message_box/message.bbcode_text = message
	$message_box.show()

func clear_message():
	$message_box.hide()

func set_message_to_be_cleared():
	msg_timer.start()

func end_battle():
	#active_enemy.hide()
	var msg = EnemyStuff.fetc_message(enemy.name, EnemyStuff.types.END)
	show_pop_message(msg)
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

func set_message():
	pass

func hurt_player(attack_type, dmg):
	if attack_type == EnemyStuff.attack_types.NORMAL:
		hp -= dmg
		$hp.bbcode_text = "HP: " + str(hp)
		show_message("you took " + str(dmg) + " damage")
		set_message_to_be_cleared()
		
		$damage_to_player.show()
		$damage_to_player/AnimationPlayer.play("damage", -1, 1)
	elif attack_type == EnemyStuff.attack_types.POISON:
		try_poisoning(dmg)

func try_poisoning(val):
	if status != statuses.POISONING or status != statuses.POISONED:
		status = statuses.POISONING
		#$poison_bg/AnimationPlayer.play("poisoning")
		return true

func remove_poisoning():
	status = statuses.NORMAL
	poison_dmg_timer.stop()

func check_statuses(delta):
	if status == statuses.POISONING:
		$poison_meter.value += 0.25
	elif status == statuses.NORMAL:
		$poison_meter.value -= 0.35
		
	
	if $poison_meter.value == 100 and status != statuses.POISONED:
		status = statuses.POISONED
		poison_dmg_timer.start()

func on_animation_finished(anim):
	pass

func on_gp_drop(val):
	gp += val
	var gp_as_string = str(gp)
	if gp_as_string.length() > 3:
		var first_comma = gp_as_string.length() - 3
		gp_as_string = gp_as_string.insert(first_comma, ",")
	
	$gp.text = "¥" + gp_as_string
#	if gp >= 1000 and gp < 10000:
#		$gp.text = "¥" + str(gp).insert(1,",")
#	elif gp >= 10000 and gp < 100000:
#		$gp.text = "¥" + str(gp).insert(2,",")
#	else:
#		$gp.text = "¥" + str(gp)

func noise_done(anim):
	if anim == "fade_off":
		enemy.activate()

func on_bulletshooter_finished():
	#show_player_turn_label()
	$tamagotchi.deactivate()
	$weapons.reload()
	$black_arena/AnimationPlayer.play("fade_out",-1,1.2)
	$dodge_arena.hide()
