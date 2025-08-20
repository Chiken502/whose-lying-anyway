extends Control

var player_name : String = ""
var avatar : Texture2D
var avatar_list := [
	preload("res://art/avatars/avatars_crab.png"),
	preload("res://art/avatars/avatars_elephant.png"),
	preload("res://art/avatars/avatars_Loin.png"),
	preload("res://art/avatars/avatars_octopus.png"),
	preload("res://art/avatars/avatars_parot.png"),
	preload("res://art/avatars/avatars_penguin.png"),
	preload("res://art/avatars/avatars_puffin.png"),
	preload("res://art/avatars/avatars_seal.png"),
	preload("res://art/avatars/avatars_starfish.png")
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
