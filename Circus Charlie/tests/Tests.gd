extends Node2D


func _ready():
	pass


func create_animated_sprite():
	# -------------------------------------------------------------------- #
	# StaticBody2D (Ramp)
	# -------------------------------------------------------------------- #
	var Ramp: StaticBody2D = StaticBody2D.new()
	Ramp.name = "Ramp"
	
	var ScriptRef: Reference = load("res://Items/Ramp/Ramp.gd")
	Ramp.set_script(ScriptRef)
	
	# -------------------------------------------------------------------- #
	# AnimatedSprite (AnimatedSprite)
	# -------------------------------------------------------------------- #
	var AnimSprite: AnimatedSprite = AnimatedSprite.new()
	AnimSprite.name = "AnimatedSprite"
	var SprFrames: SpriteFrames = SpriteFrames.new()
	
	SprFrames.add_animation("idle")
	SprFrames.add_frame("idle", load("res://assets/ramp_open.png"))
	SprFrames.add_frame("idle", load("res://assets/ramp_closed.png"))
	SprFrames.add_frame("idle", load("res://assets/ramp_open.png"))
	SprFrames.set_animation_loop("idle", false)
	SprFrames.set_animation_speed("idle", 12)
	
	SprFrames.add_animation("bounce")
	SprFrames.add_frame("bounce", load("res://assets/ramp_open.png"))
	SprFrames.add_frame("bounce", load("res://assets/ramp_closed.png"))
	SprFrames.add_frame("bounce", load("res://assets/ramp_open.png"))
	SprFrames.set_animation_loop("bounce", false)
	SprFrames.set_animation_speed("bounce", 12)
	
	AnimSprite.frames = SprFrames
	AnimSprite.speed_scale = 2
	AnimSprite.scale = Vector2(2, 2)
	AnimSprite.animation = "idle"
	Ramp.add_child(AnimSprite)

	# -------------------------------------------------------------------- #
	# Area2D (PlayerBounce)
	# -------------------------------------------------------------------- #
	var PlayerBounce: Area2D = Area2D.new()
	PlayerBounce.name = "PlayerBounce"
	var PlayerBounceCollisionShape: CollisionShape2D = CollisionShape2D.new()
	var PlayerBounceShape: RectangleShape2D = RectangleShape2D.new()
	PlayerBounceShape.extents = Vector2(48, 2)
	PlayerBounceCollisionShape.shape = PlayerBounceShape
	PlayerBounce.add_child(PlayerBounceCollisionShape)
	PlayerBounce.connect("body_entered", Ramp, "_on_Area2D_body_entered", [], CONNECT_DEFERRED)
	PlayerBounce.connect("body_exited", Ramp, "_on_Area2D_body_exited", [], CONNECT_DEFERRED)
	PlayerBounce.position = Vector2(-0.058, -18.814)
	Ramp.add_child(PlayerBounce)
	
	# -------------------------------------------------------------------- #
	# AudioStreamPlayer (RampSound)
	# -------------------------------------------------------------------- #
	var RampSound: AudioStreamPlayer = AudioStreamPlayer.new()
	RampSound.stream = load("res://assets/sfx/spring.wav")
	Ramp.add_child(RampSound)

	# -------------------------------------------------------------------- #
	# Area2D (PlayerHurt)
	# -------------------------------------------------------------------- #
	var PlayerHurt: Area2D = Area2D.new()
	PlayerHurt.name = "PlayerHurt"
	var PlayerHurtCollisionShape: CollisionShape2D = CollisionShape2D.new()
	var PlayerHurtShape: RectangleShape2D = RectangleShape2D.new()
	PlayerHurtShape.extents = Vector2(3, 12)
	PlayerHurtCollisionShape.shape = PlayerHurtShape
	PlayerHurt.add_child(PlayerHurtCollisionShape)
	PlayerHurt.connect("body_entered", Ramp, "_on_PlayerHurt_body_entered", [], CONNECT_DEFERRED)
	PlayerHurt.position = Vector2(-52, 0)
	Ramp.add_child(PlayerHurt)

	# -------------------------------------------------------------------- #
	# Area2D (PlayerDown)
	# -------------------------------------------------------------------- #
	var PlayerDown: Area2D = Area2D.new()
	PlayerDown.name = "PlayerDown"
	var PlayerDownCollisionShape: CollisionShape2D = CollisionShape2D.new()
	var PlayerDownShape: RectangleShape2D = RectangleShape2D.new()
	PlayerDownShape.extents = Vector2(48, 3)
	PlayerDownCollisionShape.shape = PlayerDownShape
	PlayerDown.add_child(PlayerDownCollisionShape)
	PlayerDown.connect("body_entered", Ramp, "_on_PlayerDown_body_entered", [], CONNECT_DEFERRED)
	PlayerDown.position = Vector2(0, 12)
	Ramp.add_child(PlayerDown)

	# -------------------------------------------------------------------- #
	# VisibilityNotifier2D (VisibilityNotifier2D)
	# -------------------------------------------------------------------- #
	var VisiNoti2D: VisibilityNotifier2D = VisibilityNotifier2D.new()
	VisiNoti2D.connect("screen_exited", Ramp, "_on_VisibilityNotifier2D_screen_exited", [], CONNECT_DEFERRED)
	Ramp.add_child(VisiNoti2D)

	Ramp.position = Vector2(100, 100)
	add_child(Ramp)

func _on_CreatePlatform_pressed():
	create_animated_sprite()


func _on_AnimatePlatform_pressed():
	pass