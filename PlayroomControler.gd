extends Node2D

signal room_not_existing
 
#Fetch Playroom
var Playroom = JavaScriptBridge.get_interface("Playroom")

var player_states := []

var joining = false
 
# Keep a reference to the callback so it doesn't get garbage collected
var jsBridgeReferences = []
func bridgeToJS(cb):
	var jsCallback = JavaScriptBridge.create_callback(cb)
	jsBridgeReferences.push_back(jsCallback)
	return jsCallback
 
func host():
	var initOptions = JavaScriptBridge.create_object("Object");
	
	initOptions.skipLobby = true
	
	Playroom.insertCoin(initOptions, bridgeToJS(onInsertCoin));
	get_tree().change_scene_to_file("res://lobby.tscn")
 
func join_game(code : String):
	var initOptions = JavaScriptBridge.create_object("Object");
	
	initOptions.skipLobby = true
	initOptions.roomCode = code
	
	joining = true
	
	Playroom.insertCoin(initOptions, bridgeToJS(onInsertCoin));


func quit():
	print("quiting")
	var js_code = "history.replaceState(null, '', window.location.pathname + window.location.search);"
	JavaScriptBridge.eval(js_code)
	
	JavaScriptBridge.eval("location.reload();")


func _ready():
	JavaScriptBridge.eval("")
	
	
	var url : String= JavaScriptBridge.eval("window.location.href")
	if url.contains("#r=R"): # Is an invite link
		var Rcode :String = JavaScriptBridge.eval("
const hash = window.location.hash;
const params = new URLSearchParams(hash.slice(1)); // Remove the '#' before parsing
params.get('r');
", )
		var RoomCode = Rcode.erase(0)
		join_game(RoomCode)

 
# Called when the host has started the game
func onInsertCoin(args):
	print("Coin Inserted!")
	Playroom.onPlayerJoin(bridgeToJS(onPlayerJoin))
	
	if joining:
		if not Playroom.isHost():
			get_tree().change_scene_to_file("res://lobby.tscn")
			print("existing game")
		else:
			print("not a valid code")
			
			var new_code = getRoomCode()
			if new_code:
				var js_code = "history.replaceState(null, '', window.location.pathname + window.location.search);"
				var error = JavaScriptBridge.eval(js_code)
				if error:
					print("error: ", error)
				
				await Playroom.me().kick()
				
				room_not_existing.emit()
 
# Called when a new player joins the game
func onPlayerJoin(args):
	var state = args[0]
	player_states.append(state)
	print("new player joined: ", state.id)
	
	# Listen to onQuit event
	state.onQuit(bridgeToJS(onPlayerQuit))
 
func onPlayerQuit(args):
	var state = args[0];
	player_states.erase(state)
	print("player quit: ", state.id)

func getRoomCode():
	return Playroom.getRoomCode()
