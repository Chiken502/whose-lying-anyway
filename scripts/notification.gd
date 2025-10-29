extends Panel


func set_text(text):
	$Label.text = text

func _on_timer_timeout() -> void:
	print("notification timer timeout")
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "position", Vector2(0, -75), 1)
	await tween.finished
	print("tween finished")
	queue_free()
