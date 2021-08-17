extends Control


func update_score(new_score:int)->void:
	$LabelPuntos.text = "PUNTOS " + str(new_score)


func update_lives(new_lives:int)->void:
	for i in $HBoxContainer.get_child_count():
		$HBoxContainer.get_child(i).visible = i < new_lives


func update_level(new_level:int)->void:
	$LabelNivelNro.text = str(new_level)
