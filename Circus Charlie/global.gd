extends Node

const STANDARD_VOLUME = -30
const STAGE_TWO_INDEX = 1
const STAGE_THREE_INDEX = 1
const LIFE_SCORE_LIMIT = 20000
const PLAYER_NAME = "Player"
const LION_NAME = "Lion"
const IS_ALPHA_VERSION = true
const LAST_LEVEL = 5

const KEY_CLASSIC_MODE : String = "CLASSIC_MODE"
const KEY_CHALLENGE_MODE : String = "CHALLENGE_MODE"
const KEY_ENDURANCE_MODE : String = "ENDURANCE_MODE"
const KEY_CHALLENGE_LEVEL1 : String = "CHALLENGE_LEVEL_1"
const KEY_CHALLENGE_LEVEL2 : String = "CHALLENGE_LEVEL_2"
const KEY_CHALLENGE_LEVEL3 : String = "CHALLENGE_LEVEL_3"
const KEY_CHALLENGE_LEVEL4 : String = "CHALLENGE_LEVEL_4"
const KEY_CHALLENGE_LEVEL5 : String = "CHALLENGE_LEVEL_5"
const KEY_CHALLENGE_LEVELN : String = "CHALLENGE_LEVEL_N"

const CHALLENGE_KEYS = [KEY_CHALLENGE_LEVEL1, 
		KEY_CHALLENGE_LEVEL2,
		KEY_CHALLENGE_LEVEL3,
		KEY_CHALLENGE_LEVEL4,
		KEY_CHALLENGE_LEVEL5,
		KEY_CHALLENGE_LEVELN]

enum {LEVEL_1 = 1, LEVEL_2 = 2, LEVEL_3 = 3, LEVEL_4 = 4} 
#Game modes
enum {CLASSIC_MODE = 1, FREE_MODE = 2, CHALLENGE_MODE = 3, ENDURANCE_MODE = 4}
onready var HudScene: PackedScene = preload("res://HUD/HUD.tscn")
var HudInstance: GameHUD = null

var stage_2_current_monkey_index = -1
var stage_3_current_ball_index = -1
var stage_3_first_time_lauched = false

var level_pattern : int = 0

var player_score: int = 0
var life_score_counter := 0
var hi_score: int = 0
var hiscores = {
	KEY_CLASSIC_MODE: 0,
	KEY_CHALLENGE_LEVEL1: 0,
	KEY_CHALLENGE_LEVEL2: 0,
	KEY_CHALLENGE_LEVEL3: 0,
	KEY_CHALLENGE_LEVEL4: 0,
	KEY_CHALLENGE_LEVEL5: 0,
	KEY_CHALLENGE_LEVELN: 0,
	KEY_ENDURANCE_MODE: 0
}
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
var pitch_scale : float = 1.37
onready var game_file: String = "user://score.save"
var is_debug_mode := true
var level_difficulty := 1 setget set_level_difficulty
var PlatformFactory: RampFactory
var endurance_time: float = 0

var game_mode: int = FREE_MODE
var game_win: bool = false

var unlockables = {}


func _ready() -> void:
	OS.center_window()
	load_game()


func unlock(key : String) -> void:
	unlockables[key] = true


func is_unlocked(key : String) -> bool:
	return unlockables.has(key) and unlockables[key]


func unlock_star() -> void:
	var key: String = CHALLENGE_KEYS[current_level]
	key = "STARS_" + key
	if not unlockables.has(key) or unlockables[key] < level_difficulty:
		unlockables[key] = level_difficulty
		var unlock_endurance : bool = true
		for challenge_level in CHALLENGE_KEYS:
			if not unlockables.has(challenge_level) or unlocked_stars(challenge_level) < 5:
				unlock_endurance = false
				break
		if unlock_endurance:
			unlock(KEY_ENDURANCE_MODE)


func unlocked_stars(level_key : String) -> int:
	var key : String = "STARS_" + level_key
	var stars : int = 0
	if unlockables.has(key):
		stars = unlockables[key]
	return stars


func get_HudInstance(in_level_hud: bool = true) -> GameHUD:
	HudInstance = HudScene.instance()
	HudInstance.update_score(player_score)
	HudInstance.update_hi_score(hi_score)
	if in_level_hud:
		HudInstance.update_lives(lives - 1)
		HudInstance.begin_time()
	else:
		HudInstance.update_lives(lives)
	if game_mode != CHALLENGE_MODE and current_level >= 21:
		HudInstance.set_time(4000)
	return HudInstance


func give_points(points: int) -> void:
	if game_mode != FREE_MODE:
		player_score += points
		if game_mode != ENDURANCE_MODE:
			if player_score >= life_score_counter:
				life_score_counter += LIFE_SCORE_LIMIT
				lives += 1
				HudInstance.give_life()
		HudInstance.update_score(player_score)
		if player_score > hi_score:
			update_hi_score(player_score)


func update_hi_score(score: int) -> void:
	if game_mode != FREE_MODE:
		hi_score = score
		HudInstance.update_hi_score(hi_score)


func set_checkpoint(value: int) -> void:
	check_point = value


func check_update_hi_score():
	if player_score > hi_score and game_mode != FREE_MODE:
		hi_score = player_score
	if game_mode == CLASSIC_MODE:
		hiscores[KEY_CLASSIC_MODE] = hi_score
	elif game_mode == CHALLENGE_MODE:
		hiscores[CHALLENGE_KEYS[current_level]] = hi_score
	elif game_mode == ENDURANCE_MODE:
		hiscores[KEY_ENDURANCE_MODE] = hi_score


func load_game():
	var load_game = File.new()
	if !load_game.file_exists(game_file):
		save_game()
	load_game.open(game_file, File.READ)
	json_obj = parse_json(load_game.get_as_text())
	hiscores[KEY_CLASSIC_MODE] = json_obj["score"]
	if json_obj.has("unlockables"):
		unlockables = json_obj["unlockables"]
	if json_obj.has("hiscores"):
		hiscores = json_obj["hiscores"]
	load_game.close()


func save_game():
	var save_game = File.new()
	save_game.open(game_file, File.WRITE)
	json_obj["hiscores"] = hiscores
	json_obj["score"] = hiscores[KEY_CLASSIC_MODE]
	json_obj["unlockables"] = unlockables
	save_game.store_string(to_json(json_obj))
	save_game.close()


func start_classic_mode(level : int)-> void:
	game_mode = CLASSIC_MODE
	hi_score = hiscores[KEY_CLASSIC_MODE]
	restart_game(level)


func start_free_mode(level : int)->void:
	game_mode = FREE_MODE
	restart_game(level)


func start_challenge_mode(level : int)->void:
	game_mode = CHALLENGE_MODE
	hi_score = hiscores[CHALLENGE_KEYS[level]]
	level_difficulty = 1
	restart_game(level)
	
	
func start_endurance_mode()->void:
	game_mode = ENDURANCE_MODE
	hi_score = hiscores[KEY_ENDURANCE_MODE]
	player_score = 0
	endurance_time = 0
	is_game_over = false
	game_win = false
	can_pause = false
	load_game()
	play_first_sound = false
	get_tree().call_deferred("change_scene", "res://Levels/ScenePreviewer.tscn")


func restart_game(first_level: int = 0):
	player_score = 0
	life_score_counter = LIFE_SCORE_LIMIT
	lives = 4
	is_game_over = false
	game_win = false
	current_level = first_level
	can_pause = false
	load_game()
	play_first_sound = false
	start_level()


func start_next_level() -> void:
	if game_mode == CHALLENGE_MODE:
		unlock_star()
		if level_difficulty == 5:
			game_win = true
			check_update_hi_score()
			global.save_game()
		set_level_difficulty(level_difficulty + 1)
	else:
		current_level += 1
	start_level()


func start_level() -> void:
	check_point = 0
	level_pattern = 0
	current_check_point_path = ""
	match current_level % LAST_LEVEL:
		STAGE_TWO_INDEX:
			stage_2_current_monkey_index = 0
		STAGE_THREE_INDEX:
			stage_3_first_time_lauched = true
			stage_3_current_ball_index = 0
	if game_mode != CHALLENGE_MODE:
# warning-ignore: integer_division
		set_level_difficulty(current_level / LAST_LEVEL + 1)
	get_tree().call_deferred("change_scene", "res://Levels/ScenePreviewer.tscn")


func show_level()->void:
	if game_mode == CHALLENGE_MODE:
		get_tree().call_deferred("change_scene", stage[current_level])
	elif game_mode == ENDURANCE_MODE:
		get_tree().call_deferred("change_scene", "res://Levels/Endurance.tscn")
	else:
		get_tree().call_deferred("change_scene", \
			stage[current_level % LAST_LEVEL])


func lose_life():
	if game_mode == ENDURANCE_MODE:
		game_over()
	elif game_mode != FREE_MODE:
		global.lives -= 1
		if global.lives <= 0:
			game_over()


func game_over():
	check_update_hi_score()
	save_game()
	is_game_over = true
	can_pause = false
	play_first_sound = true


func rand_bool():
	randomize()
	return bool(randi() % 2)


func set_current_check_point_path(value):
	current_check_point_path = value


func set_level_difficulty(new_value):
	if game_mode == CHALLENGE_MODE:
		level_difficulty = int(min(5, new_value))
	else:
		level_difficulty = int(min(4, new_value))
	check_point = 0
	current_check_point_path = ""


func create_platform(platform_number: int = 0) -> StaticBody2D:
	PlatformFactory = RampFactory.new()
	return PlatformFactory.create_platform(platform_number)
