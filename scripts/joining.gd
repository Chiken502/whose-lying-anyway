extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayroomControler.room_not_existing.connect(_room_not_existing)
	#var is_ios = JavaScriptBridge.eval("
  #(function() {
	#return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  #})()
#`);")
	var is_ios = JavaScriptBridge.eval("(function() { return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent); })()");
	$OnscreenKeyboard.auto_show = is_ios


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _room_not_existing():
	$VBoxContainer/Control/Label.text = "Not A Valid Room Code"
	$VBoxContainer/Button.disabled = false

func _on_button_pressed() -> void:
	$VBoxContainer/Button.disabled = true
	PlayroomControler.join_game($VBoxContainer/Control/LineEdit.text)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
