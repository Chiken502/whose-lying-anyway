extends Node

var registeredKeys := [] ##Keys of all regestered RPCs
var _no_value = "RPC:N0 V41U3 61V3N" # in l33t


func registerRPC(player, key: String, handler: Callable, debug := false) -> void: ##registers an 'rpc', to activate the handler function, use callRPC.
	var rpc_key = "RPC:" + key
	registeredKeys.append(rpc_key)
	
	if debug:
		print("Registering ", rpc_key)
	
	var callback = func(args):
		
		handler.call(args)
		
		if debug:
			print("recived :", key)
		
		player.setState(rpc_key, null, true)
		
		# Recurse: wait for next change
		registerRPC(player, key, handler)
	
	# Attach a JS callback for waitForPlayerState
	PlayroomControler.Playroom.waitForPlayerState(player, rpc_key, PlayroomControler.bridgeToJS(callback))


func callRPC(key: String, value : Variant = null, debug := false): ##calls an rpc. only works if one is registered already.
	var rpc_key = "RPC:" + key
	
	if registeredKeys.find(rpc_key) == -1:
		push_warning("RPC key: %s not registered" % key)
		return
	
	if value == _no_value:
		push_error("RPC Value: %s is used for debug, please use another value" % _no_value)
		return
	
	if debug:
		print("Sending to ", rpc_key)
	
	var player = PlayroomControler.Playroom.myPlayer()
	if value != null:
		player.setState(rpc_key, value, true)
	else:
		player.setState(rpc_key, _no_value, true)
