extends "res://Levels/level_base.gd"

#const MAX_BG_OFFSET : float = 192.0
const MIN_BG_OFFSET : float = 118.0
const MAX_BG_OFFSET : float = 214.0

var sector_count : int = 1
var sector_type : int = 0
var next_sector_type : int = 1

var bg_offset_change : bool = true
#var lion_scene : PackedScene = load("res://Lion/Lion.tscn")
var lion : KinematicBody2D = null
var player : KinematicBody2D = null

# Sector 0
const FLAME_POINTS = 100
const BOILER_POINTS = 200
var lion_pickup_scene : PackedScene = load("res://Endurance/LionPickUp/Lion.tscn")
var flame_scene : PackedScene = load("res://Items/Flame/Flame.tscn")
var boiler_scene : PackedScene = load("res://Items/Boiler/Boiler.tscn")
var last_flame = null
var next_bonus_flame : int = 0
var jumped_flames : int = 0
var jumped_boilers : int = 0

func _ready():
	seed(sector_count)
	$Sounds/Intro.play()
	
	if $Environment/LionPickUp.connect("pick_up", self, "lion_pick_up", [], CONNECT_DEFERRED) != OK:
		print("Error connecting Lion Pickup")
	lion = $Player/Lion
	player = $Player/Player
	
	lion.get_node("Camera2D").limit_top = 0
	lion.get_node("Camera2D").limit_left = 0
	lion.get_node("Camera2D").limit_bottom = 250
	lion.get_node("Camera2D").position.x = 120
	player.get_node("Camera2D").limit_top = 0
	player.get_node("Camera2D").limit_left = 0
	player.get_node("Camera2D").limit_bottom = 250
	player.get_node("Camera2D").position.x = 120
#	player.get_node("CollisionShape2D").shape.extents = Vector2(15, 9)

	$Player.remove_child(lion)
	
	spawn_next_flame()
	spawn_boiler()
	lion.connect("land", self, "landed_safe")
	
	if $Environment/Flame.connect("hurt", lion, "hurt", [], CONNECT_DEFERRED) != OK:
		print("Error connecting Flame Hurt")


func _on_Intro_finished():
	$Sounds/LevelSound.play()


# warning-ignore: unused_argument
func _process(delta: float)-> void:
	if bg_offset_change:
		var player_offset_pos : float = (max(200, min(350, player.position.y)) - 200) * 96 / 150
		$ParallaxBackground/ParallaxLayer/Background.offset.y = MAX_BG_OFFSET - player_offset_pos
	pass

##################################################
# Sector 0 methods
##################################################

func lion_pick_up():
	$Environment/LionPickUp.call_deferred("queue_free")
	var player_position : Vector2 = player.position + Vector2.DOWN * 35
	$Player.call_deferred("remove_child", player)
	$Player.call_deferred("add_child", lion)
	lion.set_position(player_position)


func spawn_next_flame():
	var flame : FlameRing = flame_scene.instance()
	var flame_distance : float = randf() * 244 + 12
	print (str(flame_distance))
	var pos : Vector2
	var flame_type : int = randi() % 6
	
	if last_flame == null:
		pos = Vector2(max(player.position.x, lion.position.x) + 480, 184)
	else:
		pos = last_flame.position + Vector2.RIGHT * flame_distance * 2
	
	flame.position = pos
	if flame_type < 5:
		flame.start("big")
	else:
		flame.start("bonus")
	
	flame.connect("hurt", lion, "hurt")
	flame.connect("appear", self, "_on_Flame_appear")
	flame.connect("disappear", self, "_on_Flame_disappear")
	flame.connect("bonus", self, "show_points_on_player")
	flame.connect("jump_through", self, "jump_flame")
	$Environment.call_deferred("add_child", flame)
	
	last_flame = flame


func _on_Flame_appear(flame : FlameRing)->void:
	if sector_type == 0 and flame == last_flame:
		spawn_next_flame()


func _on_Flame_disappear(flame : FlameRing)->void:
	if flame.position.x < lion.position.x:
		flame.call_deferred("queue_free")


func jump_flame()->void:
	jumped_flames += 1


func spawn_boiler():
	var boiler_pos : float = $Limits/LeftWall.position.x + 512
	while boiler_pos < $Limits/SectorEnd.position.x:
		var b = boiler_scene.instance()
		b.position = Vector2(boiler_pos, 379)
		b.connect("hurt", lion, "hurt")
		b.connect("bonus", self, "show_points_on_player")
		b.connect("jump_over", self, "jump_boiler")
		$Environment.add_child(b)
		boiler_pos += 512


func jump_boiler()->void:
	jumped_boilers += 1


func landed_safe()->void:
	if jumped_boilers == 1 and jumped_flames == 2:
		global.give_points(500)
		show_points_on_player(500, false)
	else:
		global.give_points(jumped_boilers * BOILER_POINTS + jumped_flames * FLAME_POINTS)
	jumped_boilers = 0
	jumped_flames = 0


func _on_TransitionPodium_body_entered(body):
	print("Transition Podium: " + body.name)
	if body.name == "Lion":
		var player_position : Vector2 = lion.position + Vector2.UP * 35
		var static_lion = lion_pickup_scene.instance()
		static_lion.remove_ride()
		static_lion.position = player_position + Vector2.DOWN * 35
		$Player.call_deferred("remove_child", lion)
		$Player.call_deferred("add_child", player)
		$Environment.call_deferred("add_child", static_lion)
		player.set_position(player_position)
	pass # Replace with function body.


func show_points_on_player(points: int, play_sound:bool = true):
	var player_pos : Vector2 = lion.get_global_transform_with_canvas().get_origin()
	player_pos.y -= 70
	hud.show_bonus_points(player_pos, points, not play_sound)


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
		# Start new seed
		sector_count += 1
		seed(sector_count)
		
		var next_stop : float = 1024 + 512
		sector_type = next_sector_type
		# Next sector: 0-5 not repeating the actual one
		next_sector_type = randi() % 5
		if next_sector_type >= sector_type:
			next_sector_type += 1
		
		# Move sector and camera limits
		$Limits.position.x = $Limits/SectorEnd.position.x - 356
		player.get_node("Camera2D").limit_left = $Limits/SectorEnd.position.x - 356
		lion.get_node("Camera2D").limit_left = $Limits/SectorEnd.position.x - 356
		$Limits/SectorEnd.position.x += next_stop
		
		# Free previous sector objects
		for object in $Environment.get_children():
			object.call_deferred("queue_free")
		
		# Add new sector objects
		for object in $NextSector.get_children():
			$NextSector.call_deferred("remove_child", object)
			$Environment.call_deferred("add_child", object)

		# Add distance signs
		
		# Add next sector transition
		bg_offset_change = true

