extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayroomControler.room_not_existing.connect(_room_not_existing)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _room_not_existing():
	$Label.text = "Not A Valid Room Code"
	$Button.disabled = false

func _on_button_pressed() -> void:
	$Button.disabled = true
	PlayroomControler.join_game($LineEdit.text)
