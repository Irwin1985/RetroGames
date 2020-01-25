extends Node

const STANDARD_VOLUME = -10
const STAGE_TWO_INDEX = 1
const STAGE_THREE_INDEX = 1
const LIFE_SCORE_LIMIT = 20000
const PLAYER_NAME = "Player"
const LION_NAME = "Lion"
const IS_ALPHA_VERSION = true
const LAST_LEVEL = 5
enum {LEVEL_1 = 1, LEVEL_2 = 2, LEVEL_3 = 3, LEVEL_4 = 4}
onready var HudScene: PackedScene = preload("res://HUD/HUD.tscn")
var HudInstance: GameHUD = null

var level_change_timer = Timer.new()
var stage_2_current_monkey_index = -1
var stage_2_first_time_lauched = false
var stage_3_current_ball_index = -1
var stage_3_first_time_lauched = false

var level_pattern : int = 0

var player_score: int = 0
var life_score_counter := 0
var hi_score: int = 0
var lives: int = 4
var is_game_over: bool = false
var json_obj = {}
var stage = ["res://Levels/Level1.tscn", \
			"res://Levels/Level2.tscn", \
			"res://Levels/Level3.tscn", \
			"res://Levels/Level4.tscn", \
			"res://Levels/Level5.tscn", \
			"res://Levels/LevelN.tscn"]
var current_level: int = -1
var play_first_sound: bool = false
var can_pause: bool = false
var check_point: int = 0
var current_check_point_path := "" setget set_current_check_point_path
var pitch_scale = 1.37
onready var game_file: String = "user://score.save"
var is_debug_mode := true
var level_difficulty := 1 setget set_level_difficulty
var PlatformFactory: RampFactory


func _ready() -> void:
	OS.center_window()
	load_game()


func get_HudInstance(in_level_hud: bool = true) -> GameHUD:
	HudInstance = HudScene.instance()
	HudInstance.update_score(player_score)
	HudInstance.update_hi_score(hi_score)
	if in_level_hud:
		HudInstance.update_lives(lives - 1)
		HudInstance.begin_time()
	else:
		HudInstance.update_lives(lives)
	return HudInstance


func give_points(points: int) -> void:
	player_score += points
	life_score_counter += points
	HudInstance.update_score(player_score)
	if player_score > hi_score:
		update_hi_score(player_score)


func update_hi_score(score: int) -> void:
	hi_score = score
	HudInstance.update_hi_score(hi_score)


func set_checkpoint(value: int) -> void:
	check_point = value


func check_update_hi_score():
	if player_score > hi_score:
		hi_score = player_score
		save_game()


func load_game():
	var load_game = File.new()
	if !load_game.file_exists(game_file):
		save_game()
	load_game.open(game_file, File.READ)
	json_obj = parse_json(load_game.get_as_text())
	hi_score = json_obj["score"]
	load_game.close()


func save_game():
	var save_game = File.new()
	save_game.open(game_file, File.WRITE)
	json_obj["score"] = hi_score
	save_game.store_string(to_json(json_obj))
	save_game.close()


func start_next_level() -> void:
	current_level += 1
	check_point = 0
	level_pattern = 0
	current_check_point_path = ""
	match current_level:
		STAGE_TWO_INDEX:
			stage_2_first_time_lauched = true
			stage_2_current_monkey_index = 0
		STAGE_THREE_INDEX:
			stage_3_first_time_lauched = true
			stage_3_current_ball_index = 0
		LAST_LEVEL:
			level_difficulty += 1
	
	get_tree().call_deferred("change_scene", "res://Levels/ScenePreviewer.tscn")


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
	life_score_counter = 0
	hi_score = 0
	lives = 4
	is_game_over = false
	current_level = -1
	can_pause = false
	check_point = 0
	current_check_point_path = ""
	load_game()
	play_first_sound = false


func rand_bool():
	randomize()
	return bool(randi() % 2)


func set_current_check_point_path(value):
	current_check_point_path = value


func set_level_difficulty(new_value):
	level_difficulty = new_value
	current_level = -1
	check_point = 0
	current_check_point_path = ""


func create_platform(platform_number: int = 0) -> StaticBody2D:
	PlatformFactory = RampFactory.new()
	return PlatformFactory.create_platform(platform_number)