extends Node2D
#simple 3 bullet pattern, randomized

var bullets
var dodge_box_width = 400

var speed = 700
var spx = [960,827,1093,895,1026]

func _ready():
	bullets = get_children()

func run(delta):
	for bullet in get_children():
		bullet.position += Vector2(0,1)*speed*delta

func reset_pattern():
	randomize_bullet_positions()
	for bullet in get_children():
		bullet.show()

func randomize_bullet_positions():
	print("kojraa mahdottomat patternit")
	spx.shuffle()
	
	bullets[0].position = Vector2(spx[0], -200)
	bullets[1].position = Vector2(spx[1], -400)
	bullets[2].position = Vector2(spx[2], -600)
	bullets[3].position = Vector2(spx[3], -800)
	bullets[4].position = Vector2(spx[4], -1000)
	
#	bullets[0].position = Vector2(960, -200)
#	bullets[1].position = Vector2(827, -400)
#	bullets[2].position = Vector2(1093, -600)
#	bullets[3].position = Vector2(895, -800)
#	bullets[4].position = Vector2(1026, -1000)
	
	
	
