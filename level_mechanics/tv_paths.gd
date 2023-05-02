extends Path

var tv

var first_path_curve
var start_rotation_of_the_first_path = deg2rad(157.816) #hard coded from blender for every path begin


# Called when the node enters the scene tree for the first time.
func _ready():
	first_path_curve = Curve3D.new()
#	var start_p = get_parent().get_node("forest/metarig").global_transform.origin
#	start_p.y = 0

	for p in get_parent().get_node("forest/points").get_children():
		first_path_curve.add_point(p.global_transform.origin)
	print("point count: " +str(first_path_curve.get_point_count()))
	
	set_curve(first_path_curve)
	
	tv = get_parent().get_node("tv_ver2")
	
	set_process(false)
#
#	print(get_curve().get_baked_points())
#	pass # Replace with function body.


func start_a_path():
	$PathFollow/tv_ver2/AnimationPlayer.get_animation("run2").set_loop(true)
	$PathFollow/tv_ver2/AnimationPlayer.play("run2",-1,15.0)

	var tween = create_tween()
	tween.tween_property($PathFollow/tv_ver2, "global_rotation:y", start_rotation_of_the_first_path, 0.3)#.set_trans(Tween.EASE_IN_OUT)

	set_process(true)
	

func _process(delta):
	$PathFollow.set_offset($PathFollow.get_offset()+3.5*delta)
	#c[0].set_offset(c[0].get_offset()+speed*delta)
#	pass
