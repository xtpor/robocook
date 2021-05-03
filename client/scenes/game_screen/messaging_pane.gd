extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_chat_window_selected():
	$Buttons.visible = false
	$ChatWindow.visible = true


func _on_emoji_window_selected():
	$Buttons.visible = false
	$EmojiWindow.visible = true


func _on_hide_button_pressed():
	$ChatWindow.visible = false
	$EmojiWindow.visible = false
	$Buttons.visible = true


func _on_clear_chat_pressed():
	$ChatWindow/Message.text = ""


func _on_send_message_pressed():
	var msg = $ChatWindow/Message.text
	$ChatWindow/Message.text = ""
	driver.remote_cast("send_text", [msg])
	_on_hide_button_pressed()


func _on_send_emoji_pressed(value):
	driver.remote_cast("send_emoji", [value])
	_on_hide_button_pressed()
