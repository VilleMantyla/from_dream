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

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in $Enemies.get_children():
		enemy.connect("appear_finished", self, "clear_pop_message")
		enemy.connect("enemy_died", self, "end_battle")
		enemy.connect("attack", self, "hurt_player")
		enemy.connect("attack_message", self, "show_message")
		enemy.connect("clear_message", self, "set_message_to_be_cleared")
		enemy.connect("gp", self, "add_gp")
		
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
	enemy.activate()
	enemy.show()
	var msg = EnemyStuff.fetc_message(enemy.name, EnemyStuff.types.BEGIN)
	show_pop_message(msg)
	$hp.bbcode_text = "HP: " + str(hp)

func show_pop_message(message):
	$pop_msg/message.bbcode_text = message
	$AnimationPlayer.play("message_pop",-1,2.5)
	#msg_timer.start()

func clear_pop_message():
	$AnimationPlayer.play("message_off",-1,4.5)

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

func add_gp(val):
	gp += val
	$gp.text = "GP: " + str(gp)
	
	if gp == 10:
		$weapons/AnimationPlayer.play("switch_in",-1,1.85)
		get_node("ColorRect").show()
