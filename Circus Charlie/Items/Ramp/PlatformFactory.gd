extends Node2D
class_name RampFactory

const ANIMATION_NAME: String = "bounce"
const OFFSET: int = 8

var edge_textures = ["res://assets/ramp_open.png", "res://assets/ramp_closed.png", "res://assets/ramp_open.png"]
var union_textures = ["res://assets/ramp_union_open.png", "res://assets/ramp_union_closed.png", "res://assets/ramp_union_open.png"]


func create_platform(platform_number: int = 0) -> StaticBody2D:
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
	platform_number += 2
	for pos in platform_number:
		var AnimSprite: AnimatedSprite = AnimatedSprite.new()
		AnimSprite.add_to_group("animation")
		var SprFrames: SpriteFrames = SpriteFrames.new()
		var position_x = 0
		SprFrames.add_animation(ANIMATION_NAME)
		if pos == 0: #Opening Sprite
			for texture in edge_textures:
				SprFrames.add_frame(ANIMATION_NAME, load(texture))
		elif pos == platform_number - 1:
			for texture in edge_textures:
				SprFrames.add_frame(ANIMATION_NAME, load(texture))
		else:
			for texture in union_textures:
				SprFrames.add_frame(ANIMATION_NAME, load(texture))

		SprFrames.set_animation_loop(ANIMATION_NAME, false)
		SprFrames.set_animation_speed(ANIMATION_NAME, 12)
		position_x = 0 if pos == 0 else pos * 16
		AnimSprite.position.x = position_x
		AnimSprite.frames = SprFrames
		AnimSprite.speed_scale = 2
		AnimSprite.scale = Vector2(2, 2)
		AnimSprite.animation = ANIMATION_NAME
	
		Ramp.add_child(AnimSprite)

	# -------------------------------------------------------------------- #
	# Area2D (PlayerBounce)
	# -------------------------------------------------------------------- #
	var PlayerBounce: Area2D = Area2D.new()
	PlayerBounce.name = "PlayerBounce"
	var PlayerBounceCollisionShape: CollisionShape2D = CollisionShape2D.new()
	var PlayerBounceShape: RectangleShape2D = RectangleShape2D.new()
	PlayerBounceShape.extents = Vector2((platform_number * 16) / 2, 3)
	PlayerBounceCollisionShape.shape = PlayerBounceShape
	PlayerBounce.add_child(PlayerBounceCollisionShape)
	PlayerBounce.connect("body_entered", Ramp, "_on_Area2D_body_entered", [], CONNECT_DEFERRED)
	PlayerBounce.connect("body_exited", Ramp, "_on_Area2D_body_exited", [], CONNECT_DEFERRED)
	PlayerBounce.position = Vector2((platform_number * 8) - OFFSET, -20)
	Ramp.add_child(PlayerBounce)

	# -------------------------------------------------------------------- #
	# Area2D (PlayerHurt)
	# -------------------------------------------------------------------- #
	var PlayerHurt: Area2D = Area2D.new()
	PlayerHurt.name = "PlayerHurt"
	var PlayerHurtCollisionShape: CollisionShape2D = CollisionShape2D.new()
	var PlayerHurtShape: RectangleShape2D = RectangleShape2D.new()
	PlayerHurtShape.extents = Vector2(3, 10)
	PlayerHurtCollisionShape.shape = PlayerHurtShape
	PlayerHurt.add_child(PlayerHurtCollisionShape)
	PlayerHurt.connect("body_entered", Ramp, "_on_PlayerHurt_body_entered", [], CONNECT_DEFERRED)
	PlayerHurt.position = Vector2(-12, 0)
	Ramp.add_child(PlayerHurt)

	# -------------------------------------------------------------------- #
	# Area2D (PlayerDown)
	# -------------------------------------------------------------------- #
	var PlayerDown: Area2D = Area2D.new()
	PlayerDown.name = "PlayerDown"
	var PlayerDownCollisionShape: CollisionShape2D = CollisionShape2D.new()
	PlayerDownCollisionShape.position.x = 0
	var PlayerDownShape: RectangleShape2D = RectangleShape2D.new()
	PlayerDownShape.extents = Vector2((platform_number * 16) / 2, 3)
	PlayerDownCollisionShape.shape = PlayerDownShape
	PlayerDown.add_child(PlayerDownCollisionShape)
	PlayerDown.connect("body_entered", Ramp, "_on_PlayerDown_body_entered", [], CONNECT_DEFERRED)
	PlayerDown.position = Vector2((platform_number * 8) - OFFSET, 12)
	Ramp.add_child(PlayerDown)

	# -------------------------------------------------------------------- #
	# VisibilityNotifier2D (VisibilityNotifier2D)
	# -------------------------------------------------------------------- #
	var VisiNoti2D: VisibilityNotifier2D = VisibilityNotifier2D.new()
	VisiNoti2D.connect("screen_exited", Ramp, "_on_VisibilityNotifier2D_screen_exited", [], CONNECT_DEFERRED)
	Ramp.add_child(VisiNoti2D)

	# -------------------------------------------------------------------- #
	# AudioStreamPlayer (RampSound)
	# -------------------------------------------------------------------- #
	var RampSound: AudioStreamPlayer = AudioStreamPlayer.new()
	RampSound.name = "RampSound"
	RampSound.stream = load("res://assets/sfx/spring.wav")
	Ramp.add_child(RampSound)

	return Ramp