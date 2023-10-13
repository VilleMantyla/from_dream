extends Node

func _init(main):
	main.get_node("house_entrance/sea/AnimationPlayer").play("sea",-1,2)
	main.get_node("house_build_ver2/water/AnimationPlayer").play("water",-1,2)
	
	for gs in main.get_node("glitch_suckers").get_children():
		gs.get_node("AnimationPlayer").get_animation("s_twiggle2_alt").set_loop(true)
		gs.get_node("AnimationPlayer").play("s_twiggle2_alt",-1,1.5)
	
	var tv0 = main.get_node("tv_ver2")
	tv0.get_node("AnimationPlayer").get_animation("on_the_noose").set_loop(true)
	tv0.get_node("AnimationPlayer").play("on_the_noose",-1,2)
	tv0.get_node("AnimationPlayer").connect("animation_finished", main, "FROM_TREE")
	
	var tv3_anim_p = main.get_node("tv_3/AnimationPlayer")
	tv3_anim_p.get_animation("banging_door").set_loop(true)
	tv3_anim_p.play("banging_door",-1,2)
	tv3_anim_p.get_animation("stuck").set_loop(true)
	tv3_anim_p.connect("animation_finished", main, "BANGING_ELEVATOR")
	
	main.get_node("void2/AnimationPlayer").get_animation("holding_tv_idle").set_loop(true)
	main.get_node("void2/AnimationPlayer").play("holding_tv_idle")
	main.get_node("tv_2_floor/AnimationPlayer").get_animation("let_me_go").set_loop(true)
	main.get_node("tv_2_floor/AnimationPlayer").play("let_me_go",-1,1.5)
	
	main.get_node("enemy_trigger/CollisionShape").disabled = true
	main.get_node("enemy_trigger2/CollisionShape").disabled = true
	main.get_node("enemy_trigger").hide()
	main.get_node("enemy_trigger2").hide()
	main.get_node("enemy_trigger3/CollisionShape").disabled = true
	main.get_node("enemy_trigger4/CollisionShape").disabled = true
	main.get_node("enemy_trigger3").hide()
	main.get_node("enemy_trigger4").hide()
