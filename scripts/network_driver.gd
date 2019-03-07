extends Node

signal connection_established()
signal connection_error(reason)
signal connection_closed()
signal event_received(name, data)

var NetworkCall = preload("./network_call.gd")

var socket
var peer
var _callid = 1
var _ongoing_calls = {}

func connect_to_url(url):
	socket.connect_to_url(url)

func remote_cast(name, data):
	send(["cast", name, data])
	
func remote_call(name, data):
	var id = str(_callid)
	_callid += 1
	send(["call", id, name, data])
	
	var call = NetworkCall.new()
	_ongoing_calls[id] = call
	return call

func _ready():
	socket = WebSocketClient.new()
	socket.connect("connection_established", self, "_on_connection_established")
	socket.connect("connection_closed", self, "_on_connection_closed")
	socket.connect("connection_error", self, "_on_connection_error")
	socket.connect("data_received", self, "_on_data_received")
	
	peer = socket.get_peer(1)
	peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)

func _process(_delta):
	if socket.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
		socket.poll()

func _on_connection_established(_protocol):
	print("[WebSocket] connection opened")
	send(["handshake", 1])

func _on_connection_closed(_was_clean):
	print("[WebSocket] connection closed")
	emit_signal("connection_closed")

func _on_connection_error():
	emit_signal("connection_error", "connection_error")

func _on_data_received():
	var packet = peer.get_packet().get_string_from_utf8()
	print("[WebSocket] receive %s" % [packet])
	
	match _decode(packet):
		["handshake", var result]:
			if result == "ok":
				emit_signal("connection_established")
			else:
				emit_signal("connection_error", "handshake_failure")

		["reply", var id, var result]:
			var call = _ongoing_calls[id]
			_ongoing_calls.erase(id)
			call.call_returned(result)
		
		["event", var name, var data]:
			emit_signal("event_received", name, data)

		_:
			print("Error: received unknown message")
			assert(false)

func send(msg):
	var text = _encode(msg)
	print("[WebSocket] send %s" % [text])
	peer.put_packet(text.to_utf8())

func _encode(value):
	return JSON.print(value)

func _decode(bytes):
	var res = JSON.parse(bytes)
	assert(res.error == OK)
	return res.result