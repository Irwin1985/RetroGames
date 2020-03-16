extends RigidBody2D

signal pick_up


func _ready():
	pass


func _on_Ride_body_entered(body):
	print("Ride " + body.name)
	if body.name == "Player":
		emit_signal("pick_up")
	pass # Replace with function body.
