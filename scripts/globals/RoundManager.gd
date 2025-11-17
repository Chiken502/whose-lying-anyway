extends Node

var current_round := 1
var max_rounds := 6


func advance_rounds():
	current_round += 1
	
	if current_round <= max_rounds:
		print("Round " + str(current_round) + " out of " + str(max_rounds))
		PlayroomControler.Playroom.setState("current_round", current_round) #need to call rpc to syncs
		RPCstate.callRPC("sync_score")
		RPCstate.callRPC("change_scene", "res://scenes/text_entry_page.tscn")
	else:
		PlayroomControler.Playroom.setState("current_round", current_round) 
		RPCstate.callRPC("sync_score")
		RPCstate.callRPC("change_scene", "res://scenes/final_results.tscn")
		


func _sync_round(_arg):
	var current_round = PlayroomControler.Playroom.getState("current_round")
