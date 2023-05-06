extends "res://enemies/enemy.gd"

var speed = 300
var centipede_pfs = []


# Called when the node enters the scene tree for the first time.
func _ready():
	deactivate()
	for c in get_children():
		centipede_pfs.append([c.get_node("Path2D/PathFollow2D"), c.get_node("Path2D/PathFollow2D2")])

func _process(delta):
	for c in centipede_pfs:
		c[0].set_offset(c[0].get_offset()+speed*delta)
		c[1].set_offset(c[1].get_offset()+speed*delta)

func take_damage(parts, dmg):
	for part in parts:
		damage_to_part(part, dmg)

#func activate():
#	var temp = get_children()
#	temp.remove(0)
#	for m in temp:
#		m.disable_collisionshape(false)

func deactivate():
	for c in get_children():
		c.disable_collisionshape(true)

func damage_to_part(part, dmg):
	print(str(part) + " took dmg: " + str(dmg) + " and it's hp's now: " + str(part.hp))
	part.hp -= dmg
	if part.hp <= 0:
		part.hide()
