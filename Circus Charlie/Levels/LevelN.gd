extends Node2D

func _ready():
	randomize()
	var trampolines : PackedScene = preload("res://Items/BigTrampoline/bigtrampoline.tscn")
	var jugglers : PackedScene = preload("res://Items/Juggler/Juggler.tscn")
	var fire_eaters : PackedScene = preload("res://Items/FireEater/FireEater.tscn")
	var next_bonus : int = 4
	for i in range (21):
		var new_trampoline = trampolines.instance()
# warning-ignore:integer_division
		new_trampoline.position = Vector2(i * 512 / 3 + 100, 370)
		$Environment.add_child(new_trampoline)
		if i == next_bonus:
			new_trampoline.put_bonus()
			next_bonus += randi() % 3 + 2
			if next_bonus > 20 and i < 19:
				next_bonus = 20
		if i >= 3:
			var random : int = randi() % 5
			if random == 1 or random == 2:
				var new_fire_eater : Node2D = fire_eaters.instance()
# warning-ignore:integer_division
				new_fire_eater.position = Vector2(i * 512 / 3 + 185, 388)
				$Environment.add_child(new_fire_eater)
			elif random == 3 or random == 4:
				var new_juggler : Node2D = jugglers.instance()
# warning-ignore:integer_division
				new_juggler.position = Vector2(i * 512 / 3 + 185, 388)
				$Environment.add_child(new_juggler) 

func _on_Bounds_body_entered(body : PhysicsBody2D):
	if body.name == "Player":
		body.hurt()