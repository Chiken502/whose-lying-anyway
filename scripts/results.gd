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
		$continue.hide()
		await get_tree().create_timer(0.5).timeout
	
	wining_player = ScoreManager.collect_votes()
	if wining_player:
		print("winning player id:", wining_player.id)
		$ScrollContainer/VBoxContainer/winner.text = wining_player.getState("name") + " won with..."
	else:
		print("no popular winner")
		$ScrollContainer/VBoxContainer/winner.text = "No popular winner"

	var story = " " + PlayroomControler.Playroom.getState("starter") + " " + (wining_player.getState("sentence") if wining_player else "")
	$ScrollContainer/VBoxContainer/sentance.text = story
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

	# Handle judge picks if present. Expected format set by judge_chamber.gd:
	# [judge_id, funniest_id, plot_twist_id, callback_id]
	var judge_id = PlayroomControler.Playroom.getState("judge_id")

	# Read judge picks stored as separate keys on the judge's state. Fall back to legacy "judge_votes" array if present.
	var funniest_id = null
	var plot_twist_id = null
	var callback_id = null

	for p in players:
		if p.id == judge_id:
			# Prefer discrete keys
			if p.getState("judge_funniest"):
				funniest_id = p.getState("judge_funniest")
			if p.getState("judge_plot_twist"):
				plot_twist_id = p.getState("judge_plot_twist")
			if p.getState("judge_callback"):
				callback_id = p.getState("judge_callback")

			# Backwards-compatible: some older clients stored an array under "judge_votes"
			if (funniest_id == null or plot_twist_id == null or callback_id == null) and p.getState("judge_votes"):
				var arr = p.getState("judge_votes")
				if arr and arr.size() >= 4:
					funniest_id = funniest_id if funniest_id != null else arr[1]
					plot_twist_id = plot_twist_id if plot_twist_id != null else arr[2]
					callback_id = callback_id if callback_id != null else arr[3]
			break

	print("judge id:", judge_id, " picks: funniest=", funniest_id, " plot_twist=", plot_twist_id, " callback=", callback_id)

	if PlayroomControler.Playroom.isHost():
		if funniest_id:
			_award_points(players, id_to_card, funniest_id, JUDGE_FUNNIEST_POINTS)
		if plot_twist_id:
			_award_points(players, id_to_card, plot_twist_id, JUDGE_PLOT_TWIST_POINTS)
		if callback_id:
			_award_points(players, id_to_card, callback_id, JUDGE_CALLBACK_POINTS)
		
		RPCstate.callRPC("score_updated")
		print("RPC score_updated called")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func build_score_cards(players: Array) -> void:
	var sorted_players = players.duplicate()
	sorted_players.sort_custom(Callable(self, "_compare_players"))

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

		card.set_score_txt(current_score)

		id_to_card[player.id] = card

		# mark winner visually
		if wining_player and player.id == wining_player.id:
			card.is_winner = true


func _award_points(players: Array, cards: Dictionary, target_id: String, points: int) -> void:
	for pl in players:
		if pl.id == target_id:
			var cur = 0
			if pl.getState("score"):
				cur = pl.getState("score")
			var new_s = cur + points
			# Only host should change authoritative state
			if PlayroomControler.Playroom.isHost():
				print("[DEBUG] _award_points: awarding", points, "to", pl.id, "old:", cur, "new:", new_s)
				pl.setState("score", new_s)
			if cards.has(target_id):
				cards[target_id].animate_score(new_s, 0.9)
			return

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



func _on_continue_pressed() -> void:
	
	for pl in PlayroomControler.player_states:
		pl.setState("sentence", "")
		pl.setState("vote", "")
	
	var starter = Starters.sentance_starter.pick_random()
	
	var story :String = PlayroomControler.Playroom.getState("story")
	if story == "no story":
		story = ""
	
	story += $ScrollContainer/VBoxContainer/sentance.text
	
	PlayroomControler.Playroom.setState("story", story)
	PlayroomControler.Playroom.setState("starter", starter)
	
	RPCstate.callRPC("change_scene", "res://scenes/text_entry_page.tscn")


# TODO: add animation for scores on all clients
