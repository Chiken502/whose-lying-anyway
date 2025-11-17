extends Control

var final_results = false

var id_to_card := {}
var wining_player

const POPULAR_VOTE_POINTS := 200
const JUDGE_FUNNIEST_POINTS := 200
const JUDGE_PLOT_TWIST_POINTS := 100
const JUDGE_CALLBACK_POINTS := 50

# USE RPC TO SYNC SCORES

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not PlayroomControler.Playroom.isHost():
		$Back.hide()
		await get_tree().create_timer(0.5).timeout

	var story = " " + PlayroomControler.Playroom.getState("story")
	$ScrollContainer/VBoxContainer/Story.text = story
	print(story)

	var players = PlayroomControler.player_states
	print("players: ", players)

	print("looping")

	id_to_card.clear()
	# Award popular vote points once on the host, before building UI
	if PlayroomControler.Playroom.isHost() and wining_player:
		for p in players:
			if p.id == wining_player.id:
				var cur = 0
				if p.getState("score"):
					cur = p.getState("score")
				var new_score = cur + POPULAR_VOTE_POINTS
				p.setState("score", new_score)
				print("[DEBUG] _ready: awarding POPULAR_VOTE_POINTS to", p.id, "old:", cur, "new:", new_score)
				break

	build_score_cards(players)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func build_score_cards(players: Array) -> void:
	var sorted_players = players.duplicate()
	sorted_players.sort_custom(_compare_players)

	var my_name = PlayroomControler.Playroom.myPlayer().getState("name")

	for player in sorted_players:
		var card = preload("res://scenes/score_card.tscn").instantiate()
		$"ScrollContainer/VBoxContainer/Score containers".add_child(card)

		var player_name = player.getState("name")
		var is_self = my_name == player_name

		card.set_player_name_txt(player_name)
		if is_self:
			card.set_color()

		var current_score = 0
		if player.getState("score"):
			current_score = player.getState("score")

		card.animate_score(current_score, 1)

		id_to_card[player.id] = card

		# mark winner visually #TODO: change this logic so it only shows most points winner
		if wining_player and player.id == wining_player.id:
			card.is_winner = true


func update_player_score_cards():
	print("UPDATING PLAYER SCORE CARDS")
	if PlayroomControler.Playroom.isHost():
		return
	
	build_score_cards(PlayroomControler.player_states)

func _compare_players(a, b) -> int:
	var sa = 0
	if a.getState("score"):
		sa = a.getState("score")
	var sb = 0
	if b.getState("score"):
		sb = b.getState("score")
	if sa == sb:
		return 0
	return -1 if sa > sb else 1
