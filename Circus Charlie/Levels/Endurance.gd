extends "res://Levels/level_base.gd"

#const MAX_BG_OFFSET : float = 192.0
const MIN_BG_OFFSET : float = 118.0
const MAX_BG_OFFSET : float = 214.0

var sector_count : int = 1
var sector_type : int = 0
var next_sector_type : int = 1

var lowered_background : bool = false
var lion : KinematicBody2D = null
var player : Player = null

# Sector 0
const FLAME_POINTS = 100
const BOILER_POINTS = 200
var lion_pickup_scene : PackedScene = load("res://Endurance/LionPickUp/Lion.tscn")
var transition_podium_scene : PackedScene = load("res://Endurance/Podium/Podium.tscn")
var flame_scene : PackedScene = load("res://Items/Flame/Flame.tscn")
var boiler_scene : PackedScene = load("res://Items/Boiler/Boiler.tscn")
var last_flame = null
var next_bonus_flame : int = 0
var jumped_flames : int = 0
var jumped_boilers : int = 0

# Sector 1
var rope_scene : PackedScene = load("res://Endurance/Rope/Rope.tscn")
var high_platform_scene : PackedScene = load("res://Items/HighPlatform/HighPlatform.tscn")
var monkey_scene : PackedScene = load("res://Monkey/MonkeyBase.tscn")
var start_swing : Swing = null
var last_monkey : Area2D = null

# Sector 2
var ball_scene : PackedScene = load("res://Items/Ball.tscn")

# Sector 4
var swing_scene : PackedScene = load("res://Items/Swing/swing.tscn")
var trampoline_scene : PackedScene = load("res://Items/Trampoline/trampoline.tscn")

# Sector 5
var big_trampoline_scene : PackedScene = load("res://Items/BigTrampoline/bigtrampoline.tscn")
var fire_eater_scene : PackedScene = load("res://Items/FireEater/FireEater.tscn")
var juggler_scene : PackedScene = load("res://Items/Juggler/Juggler.tscn")

func _ready():
	seed(sector_count)
	$Sounds/Intro.play()
	
	if $Environment/LionPickUp.connect("pick_up", self, "lion_pick_up", [$Environment/LionPickUp], CONNECT_DEFERRED) != OK:
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
	spawn_boiler($Limits/SectorEnd.position.x, false)
# warning-ignore: return_value_discarded
	lion.connect("land", self, "landed_safe", [], CONNECT_DEFERRED)


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

func add_lion_transition_in() -> void:
	var lion_pickup_item = lion_pickup_scene.instance()
	lion_pickup_item.position.x = $Limits/SectorEnd.position.x + 160
	lion_pickup_item.position.y = 398
	if lion_pickup_item.connect("pick_up", self, "lion_pick_up", [lion_pickup_item], CONNECT_DEFERRED) != OK:
		print("Error connecting Lion Pickup")
	$Transition.call_deferred("add_child", lion_pickup_item)


func lion_pick_up(pickup_item):
	pickup_item.call_deferred("queue_free")
	var player_position : Vector2 = player.position + Vector2.DOWN * 40
	$Player.call_deferred("remove_child", player)
	$Player.call_deferred("add_child", lion)
	lion.set_position(player_position)
	spawn_next_flame()


func spawn_next_flame():
	var flame_distance : float = randf() * 232
	if flame_distance < 64:
		flame_distance = 12
	var pos : Vector2
	var flame_type : int = randi() % 6
	
	if last_flame == null:
		pos = Vector2(max(player.position.x, lion.position.x) + 480, 184)
	else:
		pos = last_flame.position + Vector2.RIGHT * flame_distance * 2
	
	if pos.x > ($Limits/SectorEnd.position.x + 175):
		last_flame = null
		return
	
	var flame : FlameRing = flame_scene.instance()
	
	flame.position = pos
	if flame_type < 5:
		flame.start("big")
	else:
		flame.start("bonus")
	
# warning-ignore: return_value_discarded
	flame.connect("hurt", lion, "hurt")
# warning-ignore: return_value_discarded
	flame.connect("appear", self, "_on_Flame_appear")
# warning-ignore: return_value_discarded
	flame.connect("disappear", self, "_on_Flame_disappear")
# warning-ignore: return_value_discarded
	flame.connect("bonus", self, "show_points_on_player")
# warning-ignore: return_value_discarded
	flame.connect("jump_through", self, "jump_flame", [], CONNECT_DEFERRED)
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


func spawn_boiler(sector_length : float, start_at_sector_end : bool = true) -> void:
	var boiler_pos : float
	var end_pos : float
	if start_at_sector_end:
		boiler_pos = $Limits/SectorEnd.position.x + 768
		end_pos = $Limits/SectorEnd.position.x + sector_length
	else:
		boiler_pos = $Limits/LeftWall.position.x + 512
		end_pos = sector_length
	while boiler_pos <= end_pos:
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


func add_lion_transition_out() -> void:
	var podium = transition_podium_scene.instance()
	podium.position.x = $Limits/SectorEnd.position.x + 64
	podium.connect("LionOnTop", self, "_on_TransitionPodium_body_entered", [], CONNECT_DEFERRED)
	$Transition.call_deferred("add_child", podium)


func _on_TransitionPodium_body_entered() -> void:
	var player_position : Vector2 = lion.position + Vector2.UP * 35
	var static_lion = lion_pickup_scene.instance()
	static_lion.remove_ride()
	static_lion.position = player_position + Vector2.DOWN * 35
	$Player.call_deferred("remove_child", lion)
	$Player.call_deferred("add_child", player)
	$Environment.call_deferred("add_child", static_lion)
	player.set_position(player_position)


##################################################
# Sector 1 methods
##################################################

func add_monkey_transition_in() -> void:
	var trampoline = trampoline_scene.instance()
	var swing = swing_scene.instance()
	var tower = high_platform_scene.instance()
	var platform = high_platform_scene.instance()
	trampoline.position.x = $Limits/SectorEnd.position.x + 192
	swing.position.x = trampoline.position.x + 64
	swing.connect("first_grab", self, "start_monkeys")
	start_swing = swing
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


func add_monkey_environment(next_stop: float) -> void:
	var rope = rope_scene.instance()
	rope.position.x = $Limits/SectorEnd.position.x + 768
	$Environment.call_deferred("add_child", rope)
	rope = rope_scene.instance()
	rope.position.x = $Limits/SectorEnd.position.x + 768 + 512
	$Environment.call_deferred("add_child", rope)
	
	var fireeater = fire_eater_scene.instance()
	fireeater.position.x = $Limits/SectorEnd.position.x + 768 + 512
	$Environment.call_deferred("add_child", fireeater)
	
	var platform = high_platform_scene.instance()
	platform.position.x = $Limits/SectorEnd.position.x + next_stop
	platform.position.y = 252
	platform.position.y = 284
	platform.extend_tower(2)
	platform.remove_win_area()
	$Environment.call_deferred("add_child", platform)


func start_monkeys() -> void:
	add_monkey(Vector2(start_swing.position.x + 512, 218))


func add_monkey(position: Vector2):
	if position.x <= $Limits/SectorEnd.position.x:
		var monkey = monkey_scene.instance()
		monkey.position = position
		monkey.move = true
	#	monkey.connect("body_entered", self, "_on_monkey_body_entered", [], CONNECT_DEFERRED)
		monkey.connect("screen_entered", self, "_on_monkey_screen_entered", [], CONNECT_DEFERRED)
		monkey.connect("screen_exited", self, "_on_monkey_screen_exited", [], CONNECT_DEFERRED)
	#	monkey.connect("cyan_monkey_showed", self, "_on_MonkeyInstance_monkey_showed")
	#	monkey.connect("bonus_earned", self, "_on_MonkeyInstance_bonus_earned")
		$Environment.add_child(monkey)
		last_monkey = monkey


func _on_monkey_screen_entered(monkey) -> void:
	if monkey == last_monkey:
		var posx : float = randf() * 456
		if posx < 32:
			posx = 32
		elif posx < 64:
			posx = 64
		add_monkey(Vector2(monkey.position.x + posx, 218))


func _on_monkey_screen_exited(monkey) -> void:
	if monkey.position.x < player.position.x:
		monkey.call_deferred("queue_free")

##################################################
# Sector 2 methods - Balls
##################################################

func add_ball_transition_in() -> void:
	var ball = ball_scene.instance()
	ball.position.x = $Limits/SectorEnd.position.x + 160
	ball.position.y = 400
	ball.set_can_move_itself(false)
#	ball.connect("first_bounce", self, "change_gravity", [20], CONNECT_DEFERRED)
	$Transition.call_deferred("add_child", ball)

##################################################
# Sector 3 methods - Horse
##################################################

func add_horse_transition_in() -> void:
	pass

##################################################
# Sector 4 methods - Swings
##################################################

func add_swing_transition_in() -> void:
	pass

##################################################
# Sector 5 methods - Trampolines
##################################################

func add_trampoline_transition_in() -> void:
	var trampoline = big_trampoline_scene.instance()
	trampoline.position.x = $Limits/SectorEnd.position.x + 160
	trampoline.connect("first_bounce", self, "change_gravity", [20], CONNECT_DEFERRED)
	$Transition.call_deferred("add_child", trampoline)


func add_trampoline_environment(next_stop: float) -> void:
	var trampoline
	var xpos : float = 160
	while xpos < next_stop:
		trampoline = big_trampoline_scene.instance()
		trampoline.position.x = $Limits/SectorEnd.position.x + xpos
		$Environment.call_deferred("add_child", trampoline)
		
# Jugglers and Fire Eaters
		if xpos > 200:
			# warning-ignore:integer_division
			var char_posx : int = xpos + 85
#			if char_posx > (checkpoint_pos + 512):
			# warning-ignore:narrowing_conversion
			var diff_weight : int = pow(2, global.level_difficulty)
			var random: int = randi() % (1 + diff_weight * 2)
			if random > 0 and random <= diff_weight:
				var new_fire_eater: Node2D = fire_eater_scene.instance()
				new_fire_eater.position = Vector2($Limits/SectorEnd.position.x + char_posx, 388)
				$Environment.add_child(new_fire_eater)
			elif random > diff_weight:
				var new_juggler: Node2D = juggler_scene.instance()
				new_juggler.position = Vector2($Limits/SectorEnd.position.x + char_posx, 388)
				$Environment.add_child(new_juggler)
		xpos += 512 / 3


func change_gravity(gravity : int) -> void:
	player.gravity = gravity


func show_points_on_player(points: int, play_sound:bool = true):
	var player_pos : Vector2 = lion.get_global_transform_with_canvas().get_origin()
	player_pos.y -= 70
	hud.show_bonus_points(player_pos, points, not play_sound)


func stop_items():
	pass


func _on_HurtDetector_body_entered(body):
	if body.name == global.PLAYER_NAME:
		player.hurt()


func _on_Player_lose():
	stop_items()
	$Sounds/Intro.disconnect("finished", self, "_on_Intro_finished")
	$Sounds/Intro.stop()
	hud.stop_endurance()
	lose()


func _on_GameOverSound_finished():
	GameOverSound_finished()


func _on_TransitionCheckpoint_body_entered(body):
	if body.name == "Player" or body.name == "Lion":

		# Free previous sector objects
		for object in $PreviousSector.get_children():
			object.call_deferred("queue_free")

		# Free previous transition objects
		for object in $Transition.get_children():
			object.call_deferred("queue_free")
		player.take_swing(null)
		
		# Create next transition
		if sector_type == 0 or \
			sector_type == 2 or \
			sector_type == 3 or \
			sector_type == 5:
			add_lion_transition_out()
			
		if next_sector_type == 0:
			add_lion_transition_in()
		elif next_sector_type == 1:
			add_monkey_transition_in()
		elif next_sector_type == 2:
			add_ball_transition_in()
		elif next_sector_type == 3:
			add_horse_transition_in()
		elif next_sector_type == 4:
			add_swing_transition_in()
		elif next_sector_type == 5:
			add_trampoline_transition_in()
		
		# Add next sector static objects
		if next_sector_type == 1:
			var rope = rope_scene.instance()
			rope.position.x = $Limits/SectorEnd.position.x + 256
			$NextSector.call_deferred("add_child", rope)
		
		# Move transition Checkpoint
		$Limits/TransitionCheckpoint.position.x = $Limits/SectorEnd.position.x + 1024


func _on_SectorEnd_body_entered(body):
	if body.name == global.PLAYER_NAME or body.name == global.LION_NAME:
		# Start new seed
		sector_count += 1
		seed(sector_count)
		
		sector_type = next_sector_type
		# Next sector: 0-5 not repeating the actual one
		next_sector_type = randi() % 5
		if next_sector_type >= sector_type:
			next_sector_type += 1
			
		print(next_sector_type)
		move_next_sector_transition()


func move_next_sector_transition():
	
	var next_stop : float = 1024 + 512 + 256
	# Move sector and camera limits
	$Limits/LeftWall.position.x = $Limits/SectorEnd.position.x - 356
	player.get_node("Camera2D").limit_left = $Limits/SectorEnd.position.x - 356
	lion.get_node("Camera2D").limit_left = $Limits/SectorEnd.position.x - 356
	
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
	if sector_type == 0:
		spawn_boiler(next_stop)
	elif sector_type == 1:
		add_monkey_environment(next_stop)
	elif sector_type == 5:
		add_trampoline_environment(next_stop)
		
	# Change background accordingly
	if sector_type == 1 or sector_type == 4:
		lowered_background = true
	else:
		lowered_background = false

	$Limits/HurtDetector.position.x = $Limits/SectorEnd.position.x
	$Limits/Ground.position.x = $Limits/SectorEnd.position.x
	$Limits/SectorEnd.position.x += next_stop

