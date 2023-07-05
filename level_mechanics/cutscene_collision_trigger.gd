extends Area

export (Global.cutscenes) var cutscene_name


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "call_start_cutscene")
	#self.connect("body_entered", get_parent(), "start_cutscene", [cutscene_name])
	#emit_signal("body_entered", get_parent(), start_cutscene,[cutscene_name])
	pass # Replace with function body.

func call_start_cutscene(body):
	get_parent().start_cutscene(cutscene_name)
