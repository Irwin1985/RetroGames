extends "res://Levels/level_base.gd"

#const MAX_BG_OFFSET : float = 192.0
const MIN_BG_OFFSET : float = 118.0
const MAX_BG_OFFSET : float = 214.0

var sector_count : int = 1
var sector_type : int = 0
var next_sector_type : int = 1

var lowered_background : bool = false
#var lion_scene : PackedScene = load("res://Lion/Lion.tscn")
var lion : KinematicBody2D = null
var player : KinematicBody2D = null

# Sector 0
const FLAME_POINTS = 100
const BOILER_POINTS = 200
var lion_pickup_scene : PackedScene = load("res://Endurance/LionPickUp/Lion.tscn")
var lion_podium_scene : PackedScene = load("res://Endurance/LionPodium/LionPodium.tscn")
var flame_scene : PackedScene = load("res://Items/Flame/Flame.tscn")
var boiler_scene : PackedScene = load("res://Items/Boiler/Boiler.tscn")
var last_flame = null
var next_bonus_flame : int = 0
var jumped_flames : int = 0
var jumped_boilers : int = 0

# Sector 1
var rope_scene : PackedScene = load("res://Endurance/Rope/Rope.tscn")
var high_platform_scene : PackedScene = load("res://Items/HighPlatform/HighPlatform.tscn")

# Sector 4
var swing_scene : PackedScene = load("res://Items/Swing/swing.tscn")
var trampoline_scene : PackedScene = load("res://Items/Trampoline/trampoline.tscn")


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
	
	# Prepare sector 0
	spawn_next_flame()
	spawn_boiler()
	lion.connect("land", self, "landed_safe", [], CONNECT_DEFERRED)
	
	# Transition 0-1
	$Transition/HighPlatform.extend_tower(16)
	$Transition/HighPlatform2.remove_win_area()


func _on_Intro_finished():
	$Sounds/LevelSound.play()


# warning-ignore: unused_argument
func _process(delta: float)-> void:
	var player_offset_pos : float = (max(200, min(350, player.position.y)) - 200) * 96 / 150
	if lowered_background and $ParallaxBackground/ParallaxLayer/Background.offset.y < MAX_BG_OFFSET:
		$ParallaxBackground/ParallaxLayer/Background.offset.y = MAX_BG_OFFSET - player_offset_pos
	elif not lowered_background and $ParallaxBackground/ParallaxLayer/Background.offset.y > MIN_BG_OFFSET:
		$ParallaxBackground/ParallaxLayer/Background.offset.y = MAX_BG_OFFSET - player_offset_pos

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
	var flame_distance : float = randf() * 232
	if flame_distance < 64:
		flame_distance = 12
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
	while boiler_pos <= $Limits/SectorEnd.position.x:
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


func _on_TransitionPodium_body_entered():
	var player_position : Vector2 = lion.position + Vector2.UP * 35
	var static_lion = lion_pickup_scene.instance()
	static_lion.remove_ride()
	static_lion.position = player_position + Vector2.DOWN * 35
	$Player.call_deferred("remove_child", lion)
	$Player.call_deferred("add_child", player)
	$Environment.call_deferred("add_child", static_lion)
	player.set_position(player_position)


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
		
		sector_type = next_sector_type
		# Next sector: 0-5 not repeating the actual one
		next_sector_type = randi() % 5
		if next_sector_type >= sector_type:
			next_sector_type += 1
			
		move_next_sector_transition()


func move_next_sector_transition():
	
	var next_stop : float = 1024 + 512
	# Move sector and camera limits
	$Limits.position.x = $Limits/SectorEnd.position.x - 356
	player.get_node("Camera2D").limit_left = $Limits/SectorEnd.position.x - 356
	lion.get_node("Camera2D").limit_left = $Limits/SectorEnd.position.x - 356
	$Limits/SectorEnd.position.x += next_stop
	
	# Move objects to previous sector
	for object in $Environment.get_children():
		$Environment.call_deferred("remove_child", object)
		$PreviousSector.call_deferred("add_child", object)

	# Add new sector objects
	for object in $NextSector.get_children():
		$NextSector.call_deferred("remove_child", object)
		$Environment.call_deferred("add_child", object)

	# Add distance signs
	
	# Add next sector dynamic objects
	
	# Change background accordingly
	if sector_type == 1 or sector_type == 4:
		lowered_background = true
	else:
		lowered_background = false


func _on_TransitionCheckpoint_body_entered(body):
	if body.name == "Player" or body.name == "Lion":

		# Free previous sector objects
		for object in $PreviousSector.get_children():
			object.call_deferred("queue_free")

		# Free previous transition objects
		for object in $Transition.get_children():
			object.call_deferred("queue_free")
		
		# Create next transition
		if sector_type == 0:
			var podium = lion_podium_scene.instance()
			podium.position.x = $Limits/SectorEnd.position.x + 64
			podium.connect("LionOnTop", self, "_on_TransitionPodium_body_entered", [], CONNECT_DEFERRED)
			$Transition.call_deferred("add_child", podium)
		if next_sector_type == 1:
			var trampoline = trampoline_scene.instance()
			var swing = swing_scene.instance()
			var tower = high_platform_scene.instance()
			var platform = high_platform_scene.instance()
			trampoline.position.x = $Limits/SectorEnd.position.x + 192
			swing.position.x = trampoline.position.x + 64
			tower.position.x = swing.position.x
			tower.position.y = 60
			tower.extend_tower(16)
			platform.position.x = swing.position.x
			platform.position.y = 284
			platform.remove_win_area()
			$Transition.call_deferred("add_child", trampoline)
			$Transition.call_deferred("add_child", swing)
			$Transition.call_deferred("add_child", tower)
			$Transition.call_deferred("add_child", platform)
		
		# Add next sector static objects
		if next_sector_type == 1:
			var rope = rope_scene.instance()
			rope.position.x = $Limits/SectorEnd.position.x + 256
			$NextSector.call_deferred("add_child", rope)
			rope = rope_scene.instance()
			rope.position.x = $Limits/SectorEnd.position.x + 768
			$NextSector.call_deferred("add_child", rope)
			rope = rope_scene.instance()
			rope.position.x = $Limits/SectorEnd.position.x + 768 + 512
			$NextSector.call_deferred("add_child", rope)
		
		# Move transition Checkpoint
		$Limits/TransitionCheckpoint.position.x = $Limits/SectorEnd.position.x + 1024

