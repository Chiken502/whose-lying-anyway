extends Control

var org_player_name : String
var org_player_avatar_idx : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var is_ios = JavaScriptBridge.eval("(function() { return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent); })()");
	$OnscreenKeyboard.auto_show = is_ios
	
	var player = PlayroomControler.Playroom.me()
	org_player_name = player.getState("name")
	org_player_avatar_idx = player.getState("avatar_idx")
	
	$VBoxContainer/Control2/LineEdit.text = org_player_name
	
	var avatar_buttons = $VBoxContainer/GridContainer.get_children()
	avatar_buttons[org_player_avatar_idx].button_pressed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	if check_for_save_needed():
		$ConfirmationDialog.show()
	else:
		get_tree().change_scene_to_file("res://lobby.tscn")


func _on_save_pressed() -> void:
	save()


func _on_confirmation_dialog_confirmed() -> void:
	get_tree().change_scene_to_file("res://lobby.tscn")

func check_for_save_needed() -> bool:
	var avatar_idx = get_new_avatar_idx()
	var player_name = $VBoxContainer/Control2/LineEdit.text
	
	if avatar_idx != org_player_avatar_idx:
		return true
	elif player_name != org_player_name:
		return true
	
	return false

func get_new_avatar_idx() -> int:
	var index := -1
	var grid = $VBoxContainer/GridContainer
	var button_arr = grid.get_children()
	for i in range(button_arr.size()):
		var button = button_arr[i]
		if button.button_pressed:
			index = i
			break
	
	return index

func save():
	var player = PlayroomControler.Playroom.me()
	player.setState("name", $VBoxContainer/Control2/LineEdit.text)
	player.setState("avatar_idx", get_new_avatar_idx())
	RPCstate.callRPC("customize_reload")
	get_tree().change_scene_to_file("res://lobby.tscn")
