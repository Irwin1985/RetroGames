extends Node2D



func _on_Player_moved(motion):
	if $Ball.is_player_detected:
		$Ball.speed = motion
