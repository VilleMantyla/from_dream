extends RichTextLabel

signal end_chat

var timer_enabled = false
var timer_wait = 1.3

var wait
var write
var question
var end

enum {WAIT, WRITE, QUESTION, END}
var state_name

var state

var letter

var fallback_dialog_key = "dialog"

var first_text = false

var timer

func _ready():
	set_process(false)
	
	bbcode_enabled = true
	
	wait = Wait.new(self)
	write = Write.new(self)
	question = Question.new(self)
	end = End.new(self)

func _process(delta):
	state.update(delta)

func start_chat(chat_path, dialog_key):
	letter = read_json_file(chat_path)
	set_process(true)
	first_text = true
	wait.set_dialog_key(dialog_key)
	state = wait.enter()

func try_reading_next_paragraph():
	print("state is " + str(state_name))
	if state_name == WAIT:
		state.read_frame()
	if state_name == QUESTION:
		state.show_answers()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_character_sprites():
	pass

class Wait:
	var parent
	
	var page = 0
	
	var timer_max = null
	var timer_val = timer_max
	
	var dialog_key
	
	func set_dialog_key(key):
		dialog_key = key
		page = 0
	
	func _init(p):
		parent = p
		timer_max = parent.timer_wait
	
	func enter():
		parent.state_name = parent.WAIT
		timer_val = timer_max
		return self
	
	func update(delta):
		if parent.first_text:
			parent.first_text = false
			read_frame()
		elif parent.timer_enabled:
			timer_val -= delta
			if timer_val <= 0:
				read_frame()
			
#		if Input.is_action_just_pressed("space"):
#			parent.first_text = false
#			read_frame()
#		if read:
#			read = false
#			read_frame()
		pass
	
	func read_frame():
		# Read next frame from current dialog
		var frame
		if page < parent.letter[dialog_key].size():
			if parent.letter[dialog_key][page].has("textframe"):
				frame = parent.letter[dialog_key][page]["textframe"]
				frame = parent.TextFrame.new(frame)
			elif parent.letter[dialog_key][page].has("questionframe"):
				frame = parent.letter[dialog_key][page]["questionframe"]
				frame = parent.QuestionFrame.new(frame)
			page += 1
			parent.state = parent.write.enter(frame)
		else:
			page = 0
			parent.state = parent.end.enter()

class Write:
	var parent
	
	var frame
	var frame_bbcode_clean
	var visible_chars
	var char_cumulative
	
	var current_sentence_speed
	var current_sentence_sound
	
	var time_to_next_char = 0.0
	
	func _init(p):
		parent = p
	
	func enter(f):
		parent.state_name = parent.WRITE
		set_frame(f)
		return self
	
	func set_frame(f):
		frame = f
		frame_bbcode_clean = parent.clean_BBCode(f.getSentences()).replace("\n","")
		visible_chars = 0
		char_cumulative = 0
		#parent.set_bbcode(f.getSentences())
		parent.bbcode_text = f.getSentences()
		#parent.set_visible_characters(0)
		parent.visible_characters = 0
	
	func setNewSentence():
		var sentece_speed_sound = frame.nextSentence()
		char_cumulative += parent.clean_BBCode(sentece_speed_sound["text"]).replace("\n","").length()
		current_sentence_speed = 1.0/sentece_speed_sound["speed"]
		current_sentence_sound = sentece_speed_sound["sound"]
		time_to_next_char = current_sentence_speed
		
		if sentece_speed_sound.has("character"):
			parent.get_parent().get_node(sentece_speed_sound["character"]).show()
	
	func showChar():
		var character = frame_bbcode_clean[visible_chars]
		visible_chars += 1
		if(character == ' '):
			#No break between words -> jump to next char
			visible_chars += 1
		if(character == ','):
			time_to_next_char = time_to_next_char*3
		if(visible_chars == frame_bbcode_clean.length()):
			#last char
			pass
		elif(character == '.' && frame_bbcode_clean[visible_chars] != '.'):
			#pause on dot only when it's not last and not part of dot sting "....."
			time_to_next_char = time_to_next_char*3
		#parent.set_visible_characters(visible_chars)
		parent.visible_characters = visible_chars
		#parent.samplePlayer.play(current_sentence_sound)
	
	func update(delta):
		if visible_chars < char_cumulative:
			#Print characters
			if time_to_next_char <= 0.0:
				time_to_next_char = current_sentence_speed
				showChar()
			time_to_next_char -= delta
		elif !frame.getFrameDone():
			#Next sentence
			parent.hide_character_sprites()
			setNewSentence()
		else:
			#Frame Done
			#Is this a question frame?
			if "answers" in frame:
				parent.state = parent.question.enter(frame)
			else:
				parent.state = parent.wait.enter()

class Question:
	var parent
	var frame
	
	func _init(p):
		parent = p
		return self
	
	func enter(f):
		parent.state_name = parent.QUESTION
		frame = f
		return self
	
	func readyAnswers():
		for i in frame.answers.size():
			parent.get_parent().get_node("Answers").get_node("Answer" + str(i)).text = frame.answers[i]
			parent.get_parent().get_node("Answers").get_node("Answer" + str(i)).show()

	func show_answers():
		readyAnswers()
	
	func update(delta):
		pass
	
	#question answered
	func end(result_index):
		var new_key = frame.results[result_index]
		parent.wait.set_dialog_key(new_key)
		parent.first_text = true
		parent.state = parent.wait.enter()

class End:
	var parent
	var frame
	
	func _init(p):
		parent = p
		return self
	
	func enter():
		parent.state_name = parent.END
		parent.visible_characters = 0
		parent.emit_signal("end_chat")
		return self
	
	func update(delta):
		pass

class TextFrame:
	# "text", "speed", "sound"
	var sentence_data
	var sentence_index = 0
	var frameDone = false
	
	func _init(frame):
		set_new_frame(frame)
	
	func set_new_frame(frame):
		sentence_data = []
		for data in frame:
			sentence_data.append(data)
	
	func nextSentence():
		if !frameDone:
			var result = sentence_data[sentence_index]
			sentence_index += 1
			if sentence_index >= sentence_data.size():
				frameDone = true
			return result
		else:
			return -1
	
	func getSentences():
		var result = ""
		for sentence in sentence_data:
			result += sentence["text"]
		return result
	
	func getFrameDone():
		return frameDone

#QuestionFrame class, defined in JSON format.
class QuestionFrame extends TextFrame:
	var answers = []
	var results = []
	
	func _init(frame).(frame):
		pass
	
	func set_new_frame(frame):
		sentence_data = []
		print(frame)
		for data in frame:
			if data.has("text"):
				sentence_data.append(data)
			else:
				answers = data["answers"]
				results = data["results"]

static func read_json_file(filename):
	var file = File.new()
	if file.open(filename, File.READ) != OK:
		print("Error opening file: " + filename)
		return
	var text = file.get_as_text()
	file.close()
	
	var json_parse = JSON.parse(text)
	if json_parse.error != OK:
		print("Error: ", json_parse.error)
		print("Error Line: ", json_parse.error_line)
		print("Error String: ", json_parse.error_string)
		return
	
	return json_parse.result

static func clean_BBCode(bbcode):
	var first = bbcode.find("[")
	var last
	var remove
	while first != -1:
		first = bbcode.find("[")
		last = bbcode.find("]")
		remove = bbcode.substr(first, last-first+1)
		bbcode = bbcode.replace(remove, "")
	return bbcode

func _on_answer(i):
	state.end(i)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for ans in get_parent().get_node("Answers").get_children():
		ans.hide()
