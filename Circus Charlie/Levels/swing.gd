extends Node2D

export var speed : float = 1
var got_player : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body : PhysicsBody2D)->void:
	if body.name == "Player" and not got_player:
		call_deferred("take_player", body)
		got_player = true
		
func take_player(body : PhysicsBody2D)->void:
	body.get_parent().remove_child(body)
	$Area2D/CollisionShape2D.add_child(body)
	body.position.x = -10
	body.position.y = 30
	body.scale.x = 1.5
	body.scale.y = 1.5
