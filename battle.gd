extends Node2D

signal leave_battle

var hp = 10
var mp

var enemy

var leave_battle = false

#var messages
var msg_timer
var msg_time_normal = 1.5
var msg_time_attack = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in $Enemies.get_children():
		enemy.connect("appear_finished", self, "clear_pop_message")
		enemy.connect("enemy_died", self, "end_battle")
		enemy.connect("attack", self, "hurt_player")
		enemy.connect("attack_message", self, "show_message")
		enemy.connect("clear_message", self, "set_message_to_be_cleared")
	
	#messages = $msg_box/messages
	msg_timer = Timer.new()
	msg_timer.wait_time = msg_time_normal
	msg_timer.one_shot = true
	msg_timer.connect("timeout",self,"clear_message")
	add_child(msg_timer)
	
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("interact") and leave_battle:
		leave_battle()

func start_battle(e):
	enemy = e
	show()
	set_process_input(true)
	$weapons.activate(enemy)
	enemy.activate()
	enemy.show()
	var msg = EnemyMessages.fetc_message(enemy.name, EnemyMessages.types.BEGIN)
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
	var msg = EnemyMessages.fetc_message(enemy.name, EnemyMessages.types.END)
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

func hurt_player(dmg):
	hp -= dmg
	$hp.bbcode_text = "HP: " + str(hp)
	show_message("you took " + str(dmg) + " damage")
	set_message_to_be_cleared()
