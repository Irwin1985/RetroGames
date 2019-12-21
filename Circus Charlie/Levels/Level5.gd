extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var trampolines : PackedScene = preload("res://Items/Trampoline/trampoline.tscn")
	var swings : PackedScene = preload("res://Items/Swing/swing.tscn")
	for i in range (10):
		var new_trampoline = trampolines.instance()
		new_trampoline.position = Vector2((i + 1) * 256, 396)
		$EnvironmentObjects.add_child(new_trampoline)
	for i in range (10):
		var new_swing = swings.instance()
		new_swing.position = Vector2(i * 256 + 160, 120)
		if i > 0:
			new_swing.set_speed(randf() + 0.5) # 0.5-1.5
		$EnvironmentObjects.add_child(new_swing)

func _on_Detector_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player":
		body.hurt()
