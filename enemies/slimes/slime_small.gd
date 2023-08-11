extends KinematicBody2D

var id = null
var hp = 1

func disable_collisionshape(val):
	$CollisionShape2D.disabled = val

func get_target():
	return self

var velocity = Vector2(0,0)

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.normal)
