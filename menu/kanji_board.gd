extends Node2D

signal answer_submitted
signal closed

onready var kanji_btn_tscn = preload("res://menu/kanji_btn.tscn")

enum states{MENU, PUZZLE}
var state = -1

var answer = []

func _ready():
	pass

func set_state(new_state):
	if new_state == states.MENU:
		$answer_bg.hide()
		$answer.hide()
		$submit.hide()
		$clear.hide()
		$answer_mode_bg.hide()
		$hint.hide()
		$close.hide()
	elif new_state == states.PUZZLE:
		$answer_bg.show()
		$answer.show()
		$submit.show()
		$clear.show()
		$hint.show()
		$answer_mode_bg.show()
		$close.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	state = new_state

func add_new_kanji(kanji, translation):
	var new_kanji_btn = kanji_btn_tscn.instance()
	new_kanji_btn.connect("pressed", self, "kanji_selected", [new_kanji_btn])
	$GridContainer.add_child(new_kanji_btn)
	new_kanji_btn.get_node("kanji").text = kanji
	new_kanji_btn.get_node("translation").text = translation

func kanji_selected(kanji_btn):
	if state == states.PUZZLE:
		if answer.size() < 3:
			answer.append(kanji_btn.get_node("kanji").text)
			$answer.get_child(answer.size()-1).text = answer.back()

func submit_answer():
	var ans = ""
	for c in answer:
		ans += c
	emit_signal("answer_submitted", ans)
	clear_answer()

func clear_answer():
	for kanji in $answer.get_children():
		kanji.text = ""
	answer = []

func close():
	emit_signal("closed")
	clear_answer()
