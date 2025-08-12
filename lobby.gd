extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	print("lobby", PlayroomControler.Playroom.isHost())
	$Label2.text = "Code: " + str(PlayroomControler.getRoomCode())



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
