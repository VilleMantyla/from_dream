extends Node2D

signal enemy_died
signal gp_dropped

export (NodePath) var bullet_pattern

var wait_before_slide = 0.01
var slide_dist = 200
var slide_dirs = [Vector2(0,-1), Vector2(0.707, -0.707), Vector2(1,0),\
Vector2(0.707, 0.707), Vector2(0,1),Vector2(-0.707, 0.707),\
Vector2(-1,0), Vector2(-0.707, -0.707)]

#slide shape(s)
#enum slide_spahes {EIGHT}
#var slide_dict = {
#	slide_spahes.EIGHT : [1,3,5,7,7,5,3,1]
#}
var slide_eight = [1,3,5,7,7,5,3,1]
var slide_eight2 = [5,7,1,3,3,1,7,5]
#var shape_i = 0
#var shape_max_i = -1
#var slide_path = null

var rng
var appear_time = 1.0

var slimes = []
enum slime_ids {BIG, SMALL}
var part_count = -1

func _ready():
	bullet_pattern = get_node(bullet_pattern)
	
	slimes =  [$slime, $slime2]
	slimes[0].slide_shape = slide_eight
	slimes[1].slide_shape = slide_eight2
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for slime in slimes:
		slime.id = slime_ids.BIG
		for small_slime in slime.get_node("small_slimes").get_children():
			small_slime.id = slime_ids.SMALL
	
	deactivate_and_reset()
	
	set_process(false)

func _process(delta):
	if Input.is_action_just_pressed("debug_btn_1"):
		break_to_small_slimes(slimes[0])

func appear_and_prepare():
	var appear = get_child(0).get_node("big_slime/AnimationPlayer")
	appear.connect("animation_finished", self, "on_part_animation_finished")
	for slime in slimes:
		slime.get_node("big_slime/AnimationPlayer").play("appear", -1, 1/appear_time)
		slime.disable_collisionshape(false)
	
	return appear_time

func on_part_animation_finished(anim):
	activate()
	if anim == "appear":
		var empty_node = Node2D.new()
		var empty_tween = create_tween()
		#empty_tween.connect("finished",self,"activate")
		empty_tween.tween_property(empty_node, "position", Vector2.ZERO,1)

func activate():
	for slime in slimes:
		slide(slime)

func deactivate_and_reset():
	part_count = 0
	for slime in slimes:
		slime.disable_collisionshape(true)
		slime.show()
		for small_slime in slime.get_node("small_slimes").get_children():
			small_slime.disable_collisionshape(true)
			part_count += 1
			small_slime.hide()

func slide(slime):
	
#	#var random_i = rng.randi_range(0, slide_dirs.size()-1)
#	var slide_dir = slide_dirs[slide_path[shape_i]]
#	if shape_i == shape_max_i:
#		shape_i = 0
#	else:
#		shape_i += 1
	var big_slime = slime.get_node("big_slime")
	var slide_dir = slide_dirs[slime.next_dir()]
	var new_pos = slide_dir*slide_dist+big_slime.global_position
	
	var slide_tween = create_tween()
	slide_tween.connect("finished", self , "slide", [slime])
	slide_tween.tween_property(big_slime, "global_position", new_pos, 0.5).set_trans(Tween.EASE_IN_OUT)

#func wait_to_slide(slide_data):
#	var timer_tween = create_tween()
#	var empty_node2d = Node2D.new()
#	timer_tween.connect("finished", self , "slide", [slide_data])
#	timer_tween.tween_property(empty_node2d, "position", Vector2.ZERO, wait_before_slide)

func break_to_small_slimes(slime):
	slime.disable_collisionshape(true)
	var big_slime = slime.get_node("big_slime")
	big_slime.hide()
	var center_pos = big_slime.global_position
	var i = 1
	for small_slime in slime.get_node("small_slimes").get_children():
		small_slime.global_position = center_pos+slide_dirs[i] * 30
		#var new_pos = small_slime.global_position+slide_dirs[i] * 150
		#var slide_tween = create_tween()
		#slide_tween.tween_property(small_slime, "global_position", new_pos, 0.5).set_trans(Tween.EASE_IN_OUT)
		small_slime.show()
		small_slime.disable_collisionshape(false)
		small_slime.velocity = slide_dirs[i]*390
		small_slime.set_physics_process(true)
		i += 2
#	var timer_tween = create_tween()
#	var empty_node2d = Node2D.new()
#	timer_tween.connect("finished", self , "join_to_big_slime", [slime])
#	timer_tween.tween_property(empty_node2d, "position", Vector2.ZERO, 0.5)

#func join_to_big_slime(slime):
#	var big_slime = slime.get_node("big_slime")
#	var center_pos = big_slime.global_position
#	var slide_tween
#	for small_slime in slime.get_node("small_slimes").get_children():
#		slide_tween = create_tween()
#		slide_tween.tween_property(small_slime, "global_position", center_pos, 0.5)#.set_trans(Tween.EASE_IN_OUT)
#	slide_tween.connect("finished", self , "join_finished", [slime])
#
#func join_finished(slime):
#	var big_slime = slime.get_node("big_slime")
#	big_slime.show()
#	for small_slime in slime.get_node("small_slimes").get_children():
#		small_slime.hide()
#	stop_sliding = false
#	slide()

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

func damage_to_part(part, dmg):
	part.hp -= dmg
	
	if part.id == slime_ids.BIG:
		if part.hp <= 0:
			break_to_small_slimes(part)
	
	if part.id == slime_ids.SMALL:
		if part.hp <= 0:
			part.disable_collisionshape(true)
			part.hide()
			part_count -= 1
			emit_signal("gp_dropped", 1)
#	if part.hp <= 0:
#		part.hide()
#		part.disable_collisionshape(true)
#		part_count -= 1
#	else:
#		part.get_node("AnimationPlayer").play("damaged")
#
	if part_count == 0:
		emit_signal("enemy_died")
