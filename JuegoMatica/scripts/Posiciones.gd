extends Control
var _first_enter := true


func _ready():
	_show_score_table()
	if Global.show_scores_readonly:
		Global.show_scores_readonly = false
		$VBoxContainer/Body/txtScore.text = str(Global.config.scores[0].score)
		$VBoxContainer/Body/txtNombre.text = Global.config.scores[0].name
		$VBoxContainer/Body/txtNombre.editable = false
	else:
		$VBoxContainer/Body/txtScore.text = str(Global.current_score)
		$VBoxContainer/Body/txtNombre.editable = true

	$VBoxContainer/Body/txtNombre.grab_focus()


func _show_score_table()->void:
	var _node_str := ""
	var _node = null
	for i in range(9, -1, -1):
		if Global.config.scores[i].score > 0:
			if i != 0:
				_node_str = "VBoxContainer/Body/VBoxScore/Score" + str(i)
				_node = get_node(_node_str)
				if _node != null:
					_node.text = str(i) + "-" + str(Global.config.scores[i].score) + " " + Global.config.scores[i].name
					_node.visible = true
			else:
				$VBoxContainer/Body/txtScore.text = str(Global.config.scores[i].score)
				$VBoxContainer/Body/txtNombre.text = Global.config.scores[i].name


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Global.new_score(0, "")
		Global.change_scene("MainMenu")


func _on_txtNombre_text_entered(new_text):
	if _first_enter:
		_first_enter = false
		var _player := new_text as String
		var _score := int($VBoxContainer/Body/txtScore.text)
		Global.new_score(_score, _player)
		Global.change_scene("MainMenu")
