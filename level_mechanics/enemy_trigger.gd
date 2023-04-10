extends Area

export (NodePath) var enemy
export (String) var chat
export var follow_on = false
export var skip_fight = false

var idle
var follow
var state

var target

var follow_speed = 3.7

func _ready():
	idle = Idle.new(self)
	follow = Follow.new(self)
	follow.speed = follow_speed
	
	state = idle

func remove():
	$CollisionShape.disabled = true
	set_process(false)
	queue_free()

func _process(delta):
	state.update(delta)

func _on_Eyes_body_entered(body):
	target = body
	if follow_on:
		state = follow


class Idle:
	var parent
	
	var shake = false
	#var speed = 100.0
	var offset_step = 0.1
	
	var original_pos
	
	func _init(p):
		parent = p
		original_pos = parent.global_transform.origin
	
	func update(delta):
		parent.global_transform.origin = original_pos
		if shake:
			var r_temp = rand_range(0.0, 1.0)*PI*2.0
			var random_dir = Vector3(cos(r_temp), 0.0, sin(r_temp))
			var random_offset = parent.global_transform.origin+random_dir*offset_step
			parent.get_node("CollisionShape/body").global_transform.origin = random_offset
		

class Follow:
	var parent
	
	var speed = null
	
	func _init(p):
		parent = p
	
	func update(delta):
		var target_pos = parent.target.global_transform.origin
		var pos = parent.global_transform.origin
		var dir = target_pos - pos
		dir.y = 0.0
		dir = dir.normalized()
		
		parent.translate(delta*speed*dir)
		
		var temp = target_pos
		parent.get_node("CollisionShape").look_at(temp, Vector3.UP)
		parent.get_node("CollisionShape").rotation.x = 0
		parent.get_node("CollisionShape").rotation.z = 0


func _on_enemy_trigger_body_entered(body):
	$CollisionShape.disabled = true
	if skip_fight:
		enemy = null
	else:
		enemy = get_node(enemy)
	get_parent().interact_with_world_object(global_transform.origin, chat, true, enemy)
	#remove()
