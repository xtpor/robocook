extends Node

const PATH = "user://credentials.json"

var username = null
var password = null
var is_login = null

func _ready():
	var f = File.new()
	if f.file_exists(PATH):
		load_data()
	else:
		print("Created a credentials store at %s" % [PATH])
		save_data()

func load_data():
	var file = File.new()
	file.open(PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	
	var res = JSON.parse(content)
	assert(res.error == OK)
	var data = res.result
	username = data.username
	password = data.password
	is_login = data.is_login
	
	return content

func save_data():
	var data = {"username": username, "password": password, "is_login": is_login}
	var content = JSON.print(data)
	
	var file = File.new()
	file.open(PATH, File.WRITE)
	file.store_string(content)
	file.close()