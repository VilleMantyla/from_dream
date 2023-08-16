extends Area2D

var dir = Vector2(0,0)
var speed = 6
var alive_org = 10
var alive = alive_org

func resurrect():
	alive = alive_org
