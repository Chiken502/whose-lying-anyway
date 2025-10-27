extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var story = PlayroomControler.Playroom.getState("story")
	var starter = PlayroomControler.Playroom.getState("starter")
	if story != "no story":
		$Label.text = story + " " + starter + "..."
	else:
		$Label.text = starter + "..."
	
	var is_ios = JavaScriptBridge.eval("(function() { return /webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent); })()");
	$OnscreenKeyboard.auto_show = is_ios

func check_sentences(text : String): 
	var js_code = "JSON.stringify(nlp('%s').sentences().out('array'))" % text
	var sentences : Array = JSON.parse_string(JavaScriptBridge.eval(js_code))
	return sentences.size()



func _on_button_pressed() -> void: # add logic for formating
	var sentence : String = $TextEdit.text
	sentence.lstrip(" ")
	sentence.rstrip(" ")
	var sentence_amounts = check_sentences(sentence)
	
	if not (sentence.ends_with(".") or sentence.ends_with("!") or sentence.ends_with("?") or sentence.ends_with('."')):
		print("adding period")
		sentence += "."
	
	if sentence_amounts == 1:
		var me = PlayroomControler.Playroom.myPlayer()
		me.setState("sentence",sentence)
		PlayroomControler.check_if_last("sentence", "res://scenes/voting.tscn")
	elif sentence_amounts == 0:
		$Button/Label.show()
		$Button/Label.text = "You must have one sentance at least"
	else:
		$Button/Label.show()
		$Button/Label.text = "Needs to be EXACTLY one sentance"
