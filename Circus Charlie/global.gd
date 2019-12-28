extends Node

const STANDARD_VOLUME = -15

onready var hud_scene : PackedScene = preload("res://HUD/HUD.tscn")
var hud : GameHUD = null

var player_score: int = 0
var hi_score: int = 0
var lives: int = 4
var is_game_over: bool = false
var json_obj = {}
var stage = ["res://Levels/Level1.tscn", \
			"res://Levels/Level2.tscn", \
			"res://Levels/LevelN.tscn", \
			"res://Levels/LevelN.tscn", \
			"res://Levels/Level5.tscn", \
			"res://Levels/LevelN.tscn"]
var current_level: int = -1
var play_first_sound: bool = false
var can_pause: bool = false
var check_point: int = 0
onready var game_file: String = "user://score.save"


func _ready()->void:
	OS.center_window()
	load_game()
	
func get_hud(in_level_hud : bool = true)->GameHUD:
	hud = hud_scene.instance()
	hud.update_score(player_score)
	hud.update_hi_score(hi_score)
	if in_level_hud:
		hud.update_lives(lives - 1)
		hud.begin_time()
	else:
		hud.update_lives(lives)
	return hud
	
func give_points(points : int)->void:
	player_score += points
	hud.update_score(player_score)
	if player_score > hi_score:
		update_hi_score(player_score)
		
func update_hi_score(score : int)->void:
	hi_score = score
	hud.update_hi_score(hi_score)
	
func set_checkpoint(value : int)->void:
	check_point = value

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

func start_next_level()->void:
	current_level += 1
#	play_first_sound = true
	get_tree().call_deferred("change_scene", \
			"res://Levels/ScenePreviewer.tscn")

func lose_life():
	global.lives -= 1
	if global.lives <= 0:
		game_over()
	
func game_over():
	check_update_hi_score()
	is_game_over = true
	can_pause = false
	play_first_sound = true
	
func restart_game():
	player_score = 0
	hi_score = 0
	lives = 4
	is_game_over = false
	current_level = -1
	can_pause = false
	check_point = 0
	load_game()
	play_first_sound = false
	