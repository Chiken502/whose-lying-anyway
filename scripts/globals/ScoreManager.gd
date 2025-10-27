extends Node


func collect_votes(): ## returns player state of winner
	var players = PlayroomControler.player_states
	
	var votes = []
	for player in players:
		var id_vote = player.getState("vote")
		if id_vote != "is judge":
			votes.append(id_vote)
	
	votes.sort()
	
	var winner := _find_most_frequent_values(votes)
	
	return _find_state_by_id(winner.pick_random())

func find_player_id(player_name : String): ## player_name : String is used to identify the player. This function will return the player id that will be used later to score. If -1 is returned then no match was found for the player name and there is an error somewhere
	var players = PlayroomControler.player_states
	
	for player in players:
		if player.getState("name") == player_name:
			return player.id
	
	return -1

func _find_state_by_id(id):
	var players = PlayroomControler.player_states
	
	for player in players:
		if id == player.id:
			return player

func _find_most_frequent_values(arr: Array) -> Array:
	var counts := {}
	var max_count := 0
	var result := []
	
	# Count occurrences
	for value in arr:
		counts[value] = counts.get(value, 0) + 1
		max_count = max(max_count, counts[value])
	
	# Collect values with max_count
	for key in counts.keys():
		if counts[key] == max_count:
			result.append(key)
			if result.size() == 2:
				break  # Only return up to 2 values
	
	return result
