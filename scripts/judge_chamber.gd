extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("current scene judege chamber")
	
	
	var players = PlayroomControler.player_states
	var index = 0
	
	for player in players:
		print("loading player: ", player.id)
		var option_card = preload("res://scenes/vote_button.tscn").instantiate()
		print("loading sentence")
		option_card.title = player.getState("sentence")
		print("sentence found")
		option_card.player_id = player.id
		option_card.caption = "Option %s" % str(index + 1)
		index += 1
		
		print("checking player")
		if PlayroomControler.Playroom.myPlayer() == player:
			option_card.caption = "Yours"
		
		print("myPlayer found and checked")
		
		$ScrollContainer/VBoxContainer/ButtonContainer.add_child(option_card)
		option_card.disabled = true
		print("child added")
	

	for option in $ScrollContainer/VBoxContainer/ButtonContainer.get_children():
		for dropdown in $ScrollContainer/VBoxContainer/OptionContainer.get_children():
			if option.caption != "Yours":
				dropdown.add_item(option.caption)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var me = PlayroomControler.Playroom.myPlayer()
	
	var OptionContainer = $ScrollContainer/VBoxContainer/OptionContainer
	var funniest = $ScrollContainer/VBoxContainer/OptionContainer/OptionButton.selected
	var plot_twist = $ScrollContainer/VBoxContainer/OptionContainer/OptionButton2.selected
	var callback = $ScrollContainer/VBoxContainer/OptionContainer/OptionButton3.selected
	
	var funniest_id = "" # when state is saved like this it is returned as null
	var plot_twist_id = ""
	var callback_id = ""
	
	if funniest != 0:
		funniest_id = $ScrollContainer/VBoxContainer/ButtonContainer.get_children()[funniest - 1].player_id
	
	if plot_twist != 0:
		plot_twist_id = $ScrollContainer/VBoxContainer/ButtonContainer.get_children()[plot_twist - 1].player_id
	
	if callback != 0:
		callback_id =  $ScrollContainer/VBoxContainer/ButtonContainer.get_children()[callback - 1].player_id
	
	# Store judge picks as separate state keys because arrays are not reliably supported by the API.
	me.setState("vote", "is judge")
	me.setState("judge_funniest", funniest_id)
	me.setState("judge_plot_twist", plot_twist_id)
	me.setState("judge_callback", callback_id)

	print("jc picks: funniest=", funniest_id, " plot_twist=", plot_twist_id, " callback=", callback_id)
	print("jc id", me.id)
	print("jc gets: ", me.getState("judge_funniest"), me.getState("judge_plot_twist"), me.getState("judge_callback"))

	PlayroomControler.check_if_last("vote", "res://scenes/results.tscn")
