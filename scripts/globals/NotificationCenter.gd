extends Node


func _ready() -> void:
	PlayroomControler.player_left.connect(_on_player_disconnect)

func _on_player_disconnect(state):
	var notification = preload("res://scenes/notification.tscn").instantiate()
	add_child(notification)
	
	notification.position = Vector2(5, 5)
	
	var player_name = state.getState("name")
	
	notification.set_text(player_name + " was disconected")
	
	print("notification created!")
