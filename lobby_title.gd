extends Control

var player_name : String = ""
var avatar : Texture2D
var avatar_list := [
	preload("res://art/avatars/avatar_1.png"),
	preload("res://art/avatars/avatar_2.png"),
	preload("res://art/avatars/avatar_3.png"),
	preload("res://art/avatars/avatar_4.png"),
	preload("res://art/avatars/avatar_5.png"),
	preload("res://art/avatars/avatar_6.png"),
]

var player_state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update():
	$Label.text = player_name
	$TextureRect.texture = avatar
