extends Node


func _ready() -> void:
	PlayroomControler.player_left.connect(_on_player_disconnect)

func _on_player_disconnect(state):
	var notif = preload("res://scenes/notification.tscn").instantiate()
	add_child(notif)
	
	notif.position = Vector2(5, 5)
	
	var player_name = state.getState("name")
	
	notif.set_text(player_name + " was disconected")
	
	print("notification created!")
