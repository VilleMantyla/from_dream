extends Node2D

var hp_max = 12
var hp = hp_max

var id = null

var state = null

var oozing_poison = false
var poisoning_timer

var broken_timer
signal broken_timeout

func _ready():
	broken_timer = Timer.new()
	broken_timer.wait_time = 3
	broken_timer.one_shot = true
	broken_timer.connect("timeout", self, "on_broken_timeout")
	add_child(broken_timer)
	
	poisoning_timer = Timer.new()
	poisoning_timer.wait_time = 0.5
	poisoning_timer.one_shot = true
	poisoning_timer.connect("timeout", get_parent(), "ooze_poison", [self])
	add_child(poisoning_timer)

func disable_collisionshape(val):
	$Path2D/PathFollow2D/Area2D/CollisionPolygon2D.disabled = val

func get_small_slimes():
	return $small_slimes

func on_broken_timeout():
	emit_signal("broken_timeout", self)

func all_small_slimes_dead():
	for small_slime in $small_slimes.get_children():
		if small_slime.hp > 0:
			return false
	return true
