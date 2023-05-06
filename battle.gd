extends Node2D

var hp = 10
var mp

var active_enemy

var messages
var msg_timer
var msg_time = 2

var enemy_msgs = {
	"maggots" : {
		"begin" : "a pile of maggots appeared",
		"attack" : "they wriggle unpleasantly",
		"end" : "maggots run away"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in $Enemies.get_children():
		enemy.connect("enemy_died", self, "end_battle")
	
	messages = $msg_box/messages
	msg_timer = Timer.new()
	msg_timer.wait_time = msg_time
	msg_timer.one_shot = true
	msg_timer.connect("timeout",self,"set_off_msg")
	add_child(msg_timer)

func _input(event):
	if event.is_action_pressed("interact"):
		#messages.bbcode_text = enemy_msgs.maggots.attack
		pass

func start_battle(enemy):
	show()
	$weapons.activate(enemy)
	enemy.activate()
	active_enemy = enemy
	show_message()
	$hp.bbcode_text = "HP: " + str(hp)

func show_message():
	messages.bbcode_text = enemy_msgs.maggots.begin
	$AnimationPlayer.play("message_pop",-1,2.5)
	msg_timer.start()

func set_off_msg():
	$AnimationPlayer.play("message_off",-1,3.5)

func end_battle():
	active_enemy = null
	messages.bbcode_text = enemy_msgs.maggots.end
	$AnimationPlayer.play("message_pop",-1,2.5)
	print("battle ended")

func set_message():
	pass
