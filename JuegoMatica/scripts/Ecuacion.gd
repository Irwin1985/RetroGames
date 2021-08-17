extends Sprite

"""
Dibuja en pantalla la expresión aritmética
"""

var _formula := ""
var _result := 0.0
var _parent_id := 0
var _child_id := 0
var has_pair := false
var _type := ""
var _textures = {
	"selected": "res://assets/seleccion.png",
	"matched": "res://assets/vacio.png",
}

var _resolved := false


# válido para type = "ecuacion"
func draw_formula(data:Array)->void:
	_formula = data[Global.FORMULA]
	_result = data[Global.RESULT]
	$FormulaLabel.text = _formula


# válido para type = "ecuacion"
func get_result()->float:
	return _result


# válido para type = "solucion"
func draw_result(result:float)->void:
	$FormulaLabel.text = str(result)


# válido para type = "solucion"
func set_parent_id(parent_id:int)->void:
	_parent_id = parent_id


# válido para type = "ecuacion"
func set_child_id(child_id:int)->void:
	_child_id = child_id


func get_type()->String:
	return _type


func set_type(type:String)->void:
	_type = type


func get_id()->int:
	if _type == "Ecuacion":
		return _child_id
	else:
		return _parent_id


func change_texture(new_texture:String)->void:
	texture = load(_textures[new_texture])
	if new_texture == "matched":
		_resolved = true
		$FormulaLabel.text = ""


func is_resolved()->bool:
	return _resolved
