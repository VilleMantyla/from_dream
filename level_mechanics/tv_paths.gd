extends Path

var tv

var first_path_curve
var start_rotation_of_the_first_path = deg2rad(157.816) #hard coded from blender for every path begin

func _ready():
	first_path_curve = Curve3D.new()

	for p in get_parent().get_node("house_entrance/path").get_children():
		first_path_curve.add_point(p.global_transform.origin)
	print("point count: " +str(first_path_curve.get_point_count()))

	set_curve(first_path_curve)

	tv = get_parent().get_node("tv_ver2")

	set_process(false)


func start_a_path():
	$PathFollow/tv_ver2/AnimationPlayer.get_animation("run2").set_loop(true)
	$PathFollow/tv_ver2/AnimationPlayer.play("run2",-1,15.0)

	var tween = create_tween()
	tween.tween_property($PathFollow/tv_ver2, "global_rotation:y", start_rotation_of_the_first_path, 0.3)#.set_trans(Tween.EASE_IN_OUT)

	set_process(true)
	

func _process(delta):
	$PathFollow.set_offset($PathFollow.get_offset()+3.5*delta)
