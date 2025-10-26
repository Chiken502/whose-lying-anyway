extends Control

var final_results = false

var id_to_card := {}

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
	
	var wining_player = ScoreManager.collect_votes()
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

	var index = 0
	print("looping")

	id_to_card.clear()

	# Work on a copy so we don't mutate the authoritative list order
	var sorted_players = players.duplicate()
	# Sort players by score descending so highest score shows first
	sorted_players.sort_custom(Callable(self, "_compare_players"))
	
	var my_name = PlayroomControler.Playroom.myPlayer().getState("name")

	for player in sorted_players:
		var card = preload("res://score_card.tscn").instantiate()
		print("index :", index)

		index += 1
		$"ScrollContainer/VBoxContainer/Score containers".add_child(card)

		var player_name = player.getState("name")
		print("currently on player: ", player_name)
		var is_self = my_name == player_name

		card.set_player_name_txt(player_name)
		if is_self:
			print("is self")
			card.set_color()

		var current_score = 0
		if player.getState("score"):
			current_score = player.getState("score")
		print("score set: ", current_score)

		card.set_score_txt(current_score)
		print("card score set")

		id_to_card[player.id] = card

		if wining_player and player.id == wining_player.id:
			var new_score = current_score
			if PlayroomControler.Playroom.isHost():
				new_score += POPULAR_VOTE_POINTS
			# Only the host should change authoritative score state
			if PlayroomControler.Playroom.isHost():
				player.setState("score", new_score)
			# Animate to the new score on every client
			card.animate_score(new_score, 1.0)
			card.is_winner = true

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

	# Ensure the initial display reflects sorted order
	_resort_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _award_points(players: Array, cards: Dictionary, target_id: String, points: int) -> void:
	for pl in players:
		if pl.id == target_id:
			var cur = 0
			if pl.getState("score"):
				cur = pl.getState("score")
			var new_s = cur + points
			# Only host should change authoritative state
			if PlayroomControler.Playroom.isHost():
				pl.setState("score", new_s)
				RPCstate.callRPC("score_updated", pl)
				# Update host display immediately
				update_player_score(pl)
			if cards.has(target_id):
				cards[target_id].animate_score(new_s, 0.9)
			return


func update_player_score(player_state) -> void: 
	# Called by RPC to reflect authoritative score changes on all clients
	if not player_state:
		return
	var pid = player_state.id
	var score = 0
	if player_state.getState("score"):
		score = player_state.getState("score")
	if id_to_card.has(pid):
		id_to_card[pid].set_score_txt(score)
		id_to_card[pid].animate_score(score, 0.4)


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


func _resort_display() -> void:
	var container = $"ScrollContainer/VBoxContainer/Score containers"
	var entries := []
	for pid in id_to_card.keys():
		var card = id_to_card[pid]
		var sc = 0
		# Try to read authoritative score from player state
		for ps in PlayroomControler.player_states:
			if ps.id == pid:
				if ps.getState("score"):
					sc = ps.getState("score")
				break
		entries.append({"id": pid, "score": sc, "card": card})

	entries.sort_custom(Callable(self, "_compare_entries"))
	entries.reverse()

	# Reorder children in the container to match sorted entries
	var children = container.get_children()
	# Remove all child nodes from container (they remain instanced)
	for child in children:
		container.remove_child(child)

	for e in entries:
		container.add_child(e.card)


func _compare_entries(a, b) -> int:
	if a.score == b.score:
		return 0
	return -1 if a.score > b.score else 1


func _on_continue_pressed() -> void:
	
	for pl in PlayroomControler.player_states:
		pl.setState("sentence", "")
		pl.setState("vote", "")
	
	var starter = Starters.sentance_starter.pick_random()
	
	PlayroomControler.Playroom.setState("story", $ScrollContainer/VBoxContainer/sentance.text)
	PlayroomControler.Playroom.setState("starter", starter)
	
	RPCstate.callRPC("change_scene", "res://text_entry_page.tscn")
