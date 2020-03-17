extends "res://Levels/level_base.gd"

#const MAX_BG_OFFSET : float = 192.0
const MIN_BG_OFFSET : float = 118.0
const MAX_BG_OFFSET : float = 214.0

var bg_offset_change : bool = false
var lion_scene : PackedScene = load("res://Lion/Lion.tscn")
var lion : KinematicBody2D = null
var player : KinematicBody2D = null


func _ready():
	$Sounds/Intro.play()
	$Environment/LionPickUp.connect("pick_up", self, "lion_pick_up")
	lion = $Player/Lion
	player = $Player/Player
	
	lion.get_node("Camera2D").limit_top = 0
	lion.get_node("Camera2D").limit_left = 0
	lion.get_node("Camera2D").limit_bottom = 250
	player.get_node("Camera2D").limit_top = 0
	player.get_node("Camera2D").limit_left = 0
	player.get_node("Camera2D").limit_bottom = 250
#	player.get_node("CollisionShape2D").shape.extents = Vector2(15, 9)

	$Player.remove_child(lion)
	
	$Environment/Flame.connect("hurt", lion, "hurt")



func _on_Intro_finished():
	$Sounds/LevelSound.play()


func _process(delta: float)-> void:
	if bg_offset_change:
		var player_offset_pos : float = (max(200, min(350, $Player.position.y)) - 200) * 96 / 150
		$ParallaxBackground/ParallaxLayer/Background.offset.y = MAX_BG_OFFSET - player_offset_pos
	pass


func lion_pick_up():
	$Environment/LionPickUp.call_deferred("queue_free")
	var player_position : Vector2 = player.position + Vector2.DOWN * 35
	$Player.call_deferred("remove_child", player)
	$Player.call_deferred("add_child", lion)
	lion.set_position(player_position)
	pass


func stop_items():
	pass


func _on_HurtDetector_body_entered(body):
	if body.name == "Player":
		player.hurt()


func _on_Player_lose():
	stop_items()
	$Sounds/Intro.disconnect("finished", self, "_on_Intro_finished")
	$Sounds/Intro.stop()
	hud.stop_endurance()
	lose()


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_SectorEnd_body_entered(body):
	if body.name == "Player" or body.name == "Lion":
		var next_stop : float = 1024 + 512
		var next_sector_type : int = randi() % 6
		
		$Limits.position.x = $Environment/SectorEnd.position.x - 356
		player.get_node("Camera2D").limit_left = $Environment/SectorEnd.position.x - 356
		lion.get_node("Camera2D").limit_left = $Environment/SectorEnd.position.x - 356
		$Environment/SectorEnd.position.x += next_stop


