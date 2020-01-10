extends Node2D
const PLAYER_NAME = "Player"

func process_check_point(_name, node_path):
	if _name == PLAYER_NAME or _name == "Lion":
		global.current_check_point_path = node_path


func _on_CheckPoint190_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_190m")


func _on_CheckPoint180_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_180m")


func _on_CheckPoint170_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_170m")


func _on_CheckPoint160_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_160m")


func _on_CheckPoint150_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_150m")


func _on_CheckPoint140_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_140m")


func _on_CheckPoint130_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_130m")


func _on_CheckPoint120_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_120m")


func _on_CheckPoint110_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_110m")


func _on_CheckPoint100_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_100m")


func _on_CheckPoint90_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_90m")


func _on_CheckPoint80_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_80m")


func _on_CheckPoint70_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_70m")


func _on_CheckPoint60_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_60m")


func _on_CheckPoint50_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_50m")


func _on_CheckPoint40_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_40m")


func _on_CheckPoint30_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_30m")


func _on_CheckPoint20_body_entered(body):
	process_check_point(body.name, "CheckPoints/chkpt_20m")
