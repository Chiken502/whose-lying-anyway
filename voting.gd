extends Control

@onready var ButtonContainer := $ScrollContainer/VBoxContainer/ButtonContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if PlayroomControler.Playroom.getState("judge_id"):
		var judge_id = PlayroomControler.Playroom.getState("judge_id")
		
		var me = PlayroomControler.Playroom.myPlayer()
		
		if me.id == judge_id:
			print("your a judge")
			await get_tree().process_frame
			var error = get_tree().change_scene_to_file("res://judge_chamber.tscn")
			print(error)
	
	
	var story = PlayroomControler.Playroom.getState("story")
	if story != "no story":
		print("story found")
		$ScrollContainer/VBoxContainer/Story.text = PlayroomControler.Playroom.getState("story") + PlayroomControler.Playroom.getState("starter") + "..."
	else:
		$ScrollContainer/VBoxContainer/Story.text = PlayroomControler.Playroom.getState("starter") + "..."
	
	
	for player in PlayroomControler.player_states:
		if player.getState("sentence"):
			var sentence = player.getState("sentence")
			
			var button := preload("res://vote_button.tscn").instantiate()
			ButtonContainer.add_child(button)
			
			button.title = sentence
			button.caption = player.getState("name")
			
			button.button_group = preload("res://resorces/voting.tres")
			
			if PlayroomControler.Playroom.myPlayer() == player:
				button.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var me = PlayroomControler.Playroom.myPlayer()
	var pressed_button = preload("res://resorces/voting.tres").get_pressed_button()
	var player_name = pressed_button.caption
	var player_id = ScoreManager.find_player_id(player_name)
	
	me.setState("vote", player_id)
	PlayroomControler.check_if_last("vote", "res://results.tscn")
