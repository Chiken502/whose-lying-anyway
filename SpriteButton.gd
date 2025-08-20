@tool
extends Button
class_name SpriteButton

@export_tool_button("Reset") var reset = func():
	_sprite.queue_free()
	_sprite = null
	texture = null


@export var texture : Texture2D:
	set(new_texure):
		texture = new_texure
		_update_sprite()

@export var sprite_scale : Vector2 = Vector2(1, 1):
	set(new_scale):
		sprite_scale = new_scale
		_update_sprite()

var _sprite : Sprite2D

func _ready() -> void:
	if _sprite:
		_sprite.queue_free()
		_sprite = null
	
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.scale = sprite_scale
	add_child(_sprite)
	_update_sprite()
	
	if texture:
		_sprite.texture = texture
		size = (texture.get_size() * scale)
		custom_minimum_size = size


func _update_sprite() -> void:
	if not _sprite or not texture:
		return
	
	_sprite.texture = texture
	_sprite.scale = sprite_scale
	
	var size = texture.get_size() * sprite_scale
	custom_minimum_size = size
