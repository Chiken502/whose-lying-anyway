extends Panel

var is_winner = false
var is_deralment = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_winner:
		$Crown.show()
	else:
		if $Crown.visible == true:
			$Crown.hide()
	
	if is_deralment:
		$Control.show()
	else:
		if $Control.visible == true:
			$Control.hide()

func set_player_name_txt(player_name :String):
	$Name.text = player_name

func set_score_txt(score : int):
	$Score.text = str(score).pad_zeros(3)

func set_color():
	$Name.modulate = Color("6d58e1")
	$Score.modulate = Color("6d58e1")

func animate_score(to : int, over : float):
	var tween = get_tree().create_tween()
	tween.tween_property($Score, "text", str(to).pad_zeros(3), over)
