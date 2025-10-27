extends Control

@onready var http_node : HTTPRequest = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_qr(url:String):
	http_node.request("https://api.qrserver.com/v1/create-qr-code/?data=" + url + "&size=250x250")
	

func _on_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var img = Image.new()
		var err = img.load_png_from_buffer(body)
		if err == OK:
			var tex = ImageTexture.create_from_image(img)
			$TextureRect.texture = tex
		else:
			push_error("Failed to load PNG from buffer")
	else:
		push_error("HTTP error: %s" % response_code)
