@tool
extends Button


@export var title = "Anwser":
	set(text):
		title = text
		$VBoxContainer/Label.text = text
@export var caption = "Author":
	set(text):
		caption = text
		$VBoxContainer/Label2.text = text

var player_id : String ## Used to store id for later use without having to look back and match


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_label_resized() -> void:
	custom_minimum_size.y = $VBoxContainer.get_combined_minimum_size().y
