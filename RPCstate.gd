extends Node

func registerRPC(player, key: String, handler: Callable, debug := false) -> void: #registers an 'rpc', to activate the handler function, use callRPC.
	var rpc_key = "RPC:" + key
	
	print("Registering ", rpc_key)
	
	var callback = func(value):
		handler.call(value)
		if debug:
			print("recived")
		
		player.setState(rpc_key, null, true)
		
		# Recurse: wait for next change
		registerRPC(player, key, handler)
	
	# Attach a JS callback for waitForPlayerState
	PlayroomControler.Playroom.waitForPlayerState(player, rpc_key, PlayroomControler.bridgeToJS(callback))


func callRPC(key: String, debug := false): #calls an rpc. only works if one is registered already.
	var rpc_key = "RPC:" + key
	if debug:
		print("Sending to ", rpc_key)
	var player = PlayroomControler.Playroom.myPlayer()
	player.setState(rpc_key, true, true)
	print("Sent to ", player.id)
