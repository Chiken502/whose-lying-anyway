extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$QRPanel.hide()
	if not PlayroomControler.getRoomCode() is String:
		await get_tree().create_timer(1).timeout
		$VBoxContainer/VBoxContainer/Panel/Label.text = add_spaces_between_chars(str(PlayroomControler.getRoomCode()))
		load_existing_titles()
		if not PlayroomControler.Playroom.isHost():
			$start.hide()
	
	if not PlayroomControler.Playroom.isHost():
		$start.hide()
	else:
		PlayroomControler.Playroom.setState("story", "no story")
	
	$VBoxContainer/VBoxContainer/Panel/Label.text = add_spaces_between_chars(str(PlayroomControler.getRoomCode()))
	
	PlayroomControler.player_joined.connect(player_update)
	PlayroomControler.player_left.connect(player_update)
	PlayroomControler.player_left.connect(func():
		if PlayroomControler.Playroom.isHost():
			$start.show()
		)
	PlayroomControler.player_changed_avatar.connect(player_update)
	
	await get_tree().create_timer(0.5).timeout
	var url = JavaScriptBridge.eval("window.location.href")
	$QRPanel/QRcontrol.load_qr(url)
	$QRPanel/copy.text = PlayroomControler.getRoomCode()
	
	if $VBoxContainer/VBoxContainer/TextureRect/ScrollContainer/VBoxContainer.get_children() == []:
		load_existing_titles()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_spaces_between_chars(input: String) -> String:
	var result := ""
	for i in input.length():
		result += input[i]
		if i < input.length() - 1:
			result += "  "  # Two spaces
	return result

func show_start_button():
	if not PlayroomControler.Playroom.isHost():
		$start.show()
		print("Player quit, start showing, hopefully")


func player_update():
	print("Player_update")
	var Vbox = $VBoxContainer/VBoxContainer/TextureRect/ScrollContainer/VBoxContainer.get_children()
	for children in Vbox:
		children.queue_free()
	load_existing_titles()

func load_existing_titles():
	print("loading")
	var Vbox = $VBoxContainer/VBoxContainer/TextureRect/ScrollContainer/VBoxContainer
	var current_players_titles = Vbox.get_children()
	for player in PlayroomControler.player_states:
		var title = preload("res://scenes/lobby_title.tscn").instantiate()
		
		Vbox.add_child(title)
		
		if not player.getState("name"):
			await get_tree().create_timer(0.5).timeout
		
		if not player.getState("avatar_idx"):
			await get_tree().create_timer(0.5).timeout
		
		var player_name = player.getState("name")
		var avatar_idx = player.getState("avatar_idx")
		var avatar = title.avatar_list[avatar_idx]
		
		title.player_name = player_name
		title.avatar = avatar
		
		title.player_state = player
		
		if PlayroomControler.Playroom.myPlayer().getState("name") == player_name:
			title.set_player_color()
		
		title.update()


func _on_confirmation_dialog_confirmed() -> void:
	print("trying to quit")
	PlayroomControler.quit()


func _on_close_pressed() -> void:
	$ConfirmationDialog.show()

# ============ QRCODE PANEL ============ #
func _on_qrcode_pressed() -> void:
	$QRPanel.show()
	$"QRPanel/close qrpanel".disabled = false


func _on_close_qrpanel_pressed() -> void:
	$QRPanel.hide()
	$"QRPanel/close qrpanel".disabled = true

# ============ END OF QRCODE ============ #
func _on_customize_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/customise.tscn")


func _on_start_pressed() -> void:
	var pack_idx = randi_range(0, Starters.story_starters.size())
	print(pack_idx)
	var key = Starters.story_starters.keys()[pack_idx]
	var starter = Starters.story_starters[key][randi_range(0, 4)]
	print(starter)
	PlayroomControler.Playroom.setState("starter", starter)
	RPCstate.callRPC("start_game")
