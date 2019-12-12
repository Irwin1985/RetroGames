extends Node

const STANDARD_VOLUME = -15

var player_score = 0
var hi_score = 0
var lives = 3
var game_over = false
var json_obj = {}
var stage = ["res://Levels/level1.tscn", "res://Levels/level2.tscn"]
var current_level = -1
var play_first_sound = false
var can_pause = false
var check_point = 0
var level_change_timer = Timer.new()
onready var game_file = "user://score.save"


func _ready():
	OS.center_window()
	load_game()
	level_change_timer.connect("timeout", self, "change_level", [], CONNECT_DEFERRED)
	level_change_timer.wait_time = 1
	add_child(level_change_timer)


func check_update_hi_score():
	if player_score > hi_score:
		hi_score = player_score
		save_game()


func save_game():
	var save_game = File.new()
	save_game.open(game_file, File.WRITE)
	json_obj["score"] = hi_score
	save_game.store_string(to_json(json_obj))
	save_game.close()


func load_game():
	var load_game = File.new()
	if !load_game.file_exists(game_file):
		save_game()
	load_game.open(game_file, File.READ)
	json_obj = parse_json(load_game.get_as_text())
	hi_score = json_obj["score"]
	load_game.close()


func transition_to_level(level : int)->void:
	level_change_timer.start()


func change_level():
	level_change_timer.stop()
	get_tree().change_scene(stage[1])


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