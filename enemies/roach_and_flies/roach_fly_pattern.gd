extends Node2D

var speed = 400
var delay_between_flies = 1.0
const run_time = 6.5 #seconds till this pattern is finished

var flies = []
var run_time_count = run_time

enum sides {UP,RIGHT,DOWN,LEFT}
var roaches #[up,right,down,left]
var bullet_pool
var active_bullets = []
var shoot_points = [[sides.UP, 850],[sides.UP, 1070],[sides.DOWN, 850],[sides.DOWN, 1070],\
[sides.RIGHT, 400],[sides.RIGHT, 680],[sides.LEFT, 400],[sides.LEFT, 680]]

var peek = -20

func _ready():
	flies.append($fly_bullet)
	flies.append($fly_bullet2)
	bullet_pool = $roach_shooter/bullets.get_children()
	roaches = $roach_shooter/roaches.get_children()
	deactivate_and_reset()

func disable_colliders(val):
	for fly in flies:
		fly.get_node("PathFollow2D/Area2D/CollisionShape2D").disabled = val

func deactivate_and_reset():
	set_process(false)
	disable_colliders(true)
	for i in flies.size():
		var pf = flies[i].get_node("PathFollow2D")
		pf.set_offset(0)
		flies[i].delay = i*delay_between_flies
	run_time_count = run_time
	active_bullets = []
	bullet_pool = $roach_shooter/bullets.get_children()

func run_pattern():
	disable_colliders(false)
	set_process(true)
	random_peek_shoot()

func _process(delta):
	for fly in flies:
		if fly.delay <= 0:
			var pf = fly.get_node("PathFollow2D")
			pf.set_offset(pf.get_offset()+speed*delta)
		else:
			fly.delay -= delta
	
	if active_bullets.size() > 0:
		var live_bullets = []
		var dead_bullets = []
		for bullet in active_bullets:
			bullet.global_position += bullet.dir*bullet.speed
			bullet.alive -= delta
			if bullet.alive > 0:
				live_bullets.append(bullet)
			else:
				dead_bullets.append()
		active_bullets = live_bullets
		for b in dead_bullets:
			bullet_pool.append(b)
	
	if run_time_count <= 0:
		get_parent().emit_signal("bulletshooter_finished")
		deactivate_and_reset()

	run_time_count -= delta

func random_peek_shoot():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_point = rng.randi_range(0,shoot_points.size()-1)
	var side = shoot_points[random_point][0]
	var pos = shoot_points[random_point][1]
	roach_peek(side, pos)

func roach_peek(side, pos):
	var roach = roaches[side]
	var begin_pos
	var new_pos
	var dir
	if side == sides.UP:
		begin_pos = Vector2(pos, -200)
		new_pos = Vector2(pos, 0) + Vector2(0, peek)
		dir = Vector2.DOWN
	elif side == sides.DOWN:
		begin_pos = Vector2(pos, 1080+200)
		new_pos = Vector2(pos, 1080) - Vector2(0, peek)
		dir = Vector2.UP
	elif side == sides.RIGHT:
		begin_pos = Vector2(1920+200, pos)
		new_pos = Vector2(1920, pos) - Vector2(0, peek)
		dir = Vector2.LEFT
	else:
		begin_pos = Vector2(-200, pos)
		new_pos = Vector2(0, pos) + Vector2(0, peek)
		dir = Vector2.RIGHT
	roach.global_position = begin_pos
	
	var peek_tween = create_tween()
	peek_tween.connect("finished", self, "roach_peek_finished", [roach, begin_pos, dir])
	peek_tween.tween_property(roach, "global_position", new_pos, 1.0)

func roach_peek_finished(roach, pos, dir):
	shoot_bullet(dir, roach.global_position)
	var peek_tween = create_tween()
	peek_tween.tween_property(roach, "global_position", pos, 1.0)

func shoot_bullet(dir, pos):
	var bullet = get_new_bullet()
	bullet.dir = dir
	bullet.global_position = pos
	bullet.global_rotation = dir.angle()+Vector2.UP.angle()
	active_bullets.append(bullet)

func get_new_bullet():
	var bullet = bullet_pool.pop_front()
	bullet.resurrect()
	return bullet
