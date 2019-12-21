extends Node2D

const total_swings : int = 10

func _ready():
	randomize()
	$Player.position.x += 0
	$Player.position.y -= 150
	var trampolines : PackedScene = preload("res://Items/Trampoline/trampoline.tscn")
	var swings : PackedScene = preload("res://Items/Swing/swing.tscn")
	for i in range (total_swings):
		# Add Trampolines
		if i < total_swings - 1: # Don't add the last one
			var new_trampoline = trampolines.instance()
			new_trampoline.position = Vector2((i + 1) * 256, 396)
			$EnvironmentObjects.add_child(new_trampoline)
		# Add Swings
		var new_swing = swings.instance()
		new_swing.position = Vector2(i * 256 + 160, 120)
		if i > 0:
			new_swing.set_speed(randf() + 0.5) # 0.5-1.5
		if i % 2 != 0:
			new_swing.reset_swing_position()
		$EnvironmentObjects.add_child(new_swing)

func _on_Detector_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player":
		body.hurt()
