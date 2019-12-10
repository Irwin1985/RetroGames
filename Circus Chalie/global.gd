extends Node
var player_score = 0
var hi_score = 0
var lives = 3
var game_over = false
var json_obj = {}
var stage = ["res://Levels/level1.tscn"]
var current_level = -1
var play_first_sound = false
var can_pause = false
var check_point = 0

func _ready():
	OS.center_window()
	OS.set_clipboard(OS.get_user_data_dir())
	load_game()
	
func check_update_hi_score():
	if player_score > hi_score:
		hi_score = player_score
		save_game()
	
func save_game():
	var save_game = File.new()
	save_game.open("user://score.save", File.WRITE)
	json_obj["score"] = hi_score
	save_game.store_string(to_json(json_obj))
	save_game.close()

func load_game():
	var load_game = File.new()
	if !load_game.file_exists("user://score.save"):
		save_game()
	load_game.open("user://score.save", File.READ)
	json_obj = parse_json(load_game.get_as_text())
	hi_score = json_obj["score"]
	load_game.close()

func game_over():
	check_update_hi_score()
	player_score = 0
	hi_score = 0
	lives = 3
	game_over = false
	current_level = -1
	play_first_sound = false
	can_pause = false
	check_point = 0
	load_game()