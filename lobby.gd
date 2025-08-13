extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$QRPanel.hide()
	await get_tree().create_timer(1).timeout
	print("lobby: is host: ", PlayroomControler.Playroom.isHost())
	$VBoxContainer/VBoxContainer/TextureRect2/Label2.text = add_spaces_between_chars(str(PlayroomControler.getRoomCode()))
	await get_tree().create_timer(0.5).timeout
	var url = JavaScriptBridge.eval("window.location.href")
	print(url)
	$QRPanel/QRcontrol.load_qr(url)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_spaces_between_chars(input: String) -> String:
	var result := ""
	for i in input.length():
		result += input[i]
		if i < input.length() - 1:
			result += "  "  # Two spaces
	return result


func _on_confirmation_dialog_confirmed() -> void:
	print("trying to quit")
	PlayroomControler.quit()


func _on_close_pressed() -> void:
	$ConfirmationDialog.show()

# ============ QRCODE PANEL ============ #
func _on_qrcode_pressed() -> void:
	$QRPanel.show()
	$"QRPanel/close qrpanel".disabled = false
	$QRPanel/copy.disabled = false


func _on_close_qrpanel_pressed() -> void:
	$QRPanel.hide()
	$"QRPanel/close qrpanel".disabled = true
	$QRPanel/copy.disabled = true


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(JavaScriptBridge.eval("window.location.href"))
