extends Node

const SAVE_DATA_PATH = "user://saved_data.json"

# constantes para los niveles
const ESCALERA_Y_PISO_1 = 194
const ESCALERA_Y_PISO_2 = 270
const ESCALERA_Y_PISO_3 = 346

# constantes para la formula y su resultado
const FORMULA = 0
const RESULT = 1
const X_POS = 0
const Y_POS = 1

# constantes de movimiento
const MOVE_UP = -1
const MOVE_DOWN = 1
const MOVE_LEFT = -1
const MOVE_RIGHT = 1

# constantes para los pisos
const PRIMER_PISO = 0
const SEGUNDO_PISO = 1
const TERCER_PISO = 2
const CUARTO_PISO = 3

# niveles de dificultad
const FACIL = 1
const MEDIO = 2
const DIFICIL = 4

enum {
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4,
	LEVEL_5,
	LEVEL_6,
	LEVEL_7,
	LEVEL_8,
	LEVEL_9,
	LEVEL_10,
}

# TODO: cargar estas variables desde el fichero
var _default_save_data: Dictionary = {
	"suma_resta": 1,
	"multiplicacion": 1,
	"division": 1,
	"fracciones": true,
	"negativos": true,
	"scores": [
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		},
		{
			"name": "",
			"score": 0,
		}
	],
}

# cargamos configuración de fichero
var config: Dictionary = load_data_from_file()

var suma_resta = int(config.suma_resta)
var multiplica = int(config.multiplicacion)
var division = int(config.division)
var fracciones:bool = config.fracciones
var negativos:bool = config.negativos

# variables de sesión
var player_lives := 4
var current_level := LEVEL_1
var current_score := 0
var level_dificulty := FACIL
var show_scores_readonly := false
var selected_game := ""
var exit_to_main_menu := false


# información acerca del piso y sus desplazamientos
var x_positions: Array = [58, 150, 242, 334, 426, 518]
# var y_positions: Array = [132, 208, 284, 360]
var y_positions: Array = [130, 206, 282, 358]


# variables de tipo array
# con el detalle de los niveles
var level_1: Array = [
		{
			"scene": "Cuadro",
			"position": [93,125]
		},
		{
			"scene": "Ecuacion",
			"position": [273,125]
		},
		{
			"scene": "Interruptor",
			"position": [265,157]
		},
		{
			"scene": "Ecuacion",
			"position": [365,125]
		},
		{
			"scene": "Interruptor",
			"position": [357,157]
		},
		{
			"scene": "Cuadro",
			"position": [553,125]
		},
		{
			"scene": "Ecuacion",
			"position": [89,201]
		},
		{
			"scene": "Interruptor",
			"position": [81,233]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [273,201]
		},
		{
			"scene": "Interruptor",
			"position": [265,233]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [549,201]
		},
		{
			"scene": "Interruptor",
			"position": [541,233]
		},
		{
			"scene": "Ecuacion",
			"position": [89,277]
		},
		{
			"scene": "Interruptor",
			"position": [81,309]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [365,277]
		},
		{
			"scene": "Interruptor",
			"position": [357,309]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [549,277]
		},
		{
			"scene": "Interruptor",
			"position": [541,309]
		},
		{
			"scene": "Ecuacion",
			"position": [89,353]
		},
		{
			"scene": "Interruptor",
			"position": [81,385]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [273,353]
		},
		{
			"scene": "Interruptor",
			"position": [265,385]
		},
		{
			"scene": "Ecuacion",
			"position": [365,353]
		},
		{
			"scene": "Interruptor",
			"position": [357,385]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [549,353]
		},
		{
			"scene": "Interruptor",
			"position": [541,385]
		}
	]

var level_2 = [
		{
			"scene": "Ecuacion",
			"position": [89,125]
		},
		{
			"scene": "Interruptor",
			"position": [81,158]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [273,125]
		},
		{
			"scene": "Interruptor",
			"position": [265,158]
		},
		{
			"scene": "Ecuacion",
			"position": [365,125]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [549,125]
		},
		{
			"scene": "Interruptor",
			"position": [541,158]
		},
		{
			"scene": "Ecuacion",
			"position": [273,202]
		},
		{
			"scene": "Interruptor",
			"position": [265,234]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},		
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [273,278]
		},
		{
			"scene": "Interruptor",
			"position": [265,310]
		},
		{
			"scene": "Ecuacion",
			"position": [365,278]
		},
		{
			"scene": "Interruptor",
			"position": [357,310]
		},		
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_3]
		},		
		{
			"scene": "Ecuacion",
			"position": [181,354]
		},
		{
			"scene": "Interruptor",
			"position": [173,386]
		},
		{
			"scene": "Cuadro",
			"position": [277,354]
		},
		{
			"scene": "Cuadro",
			"position": [369,354]
		},				
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_3]
		}
	]

var level_3 = [
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [365,126]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Ecuacion",
			"position": [457,126]
		},
		{
			"scene": "Interruptor",
			"position": [449,158]
		},
		{
			"scene": "Cuadro",
			"position": [553,126]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [549,202]
		},
		{
			"scene": "Interruptor",
			"position": [541,234]
		},
		{
			"scene": "Ecuacion",
			"position": [89,278]
		},
		{
			"scene": "Interruptor",
			"position": [81,310]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [273,278]
		},
		{
			"scene": "Interruptor",
			"position": [265,310]
		},
		{
			"scene": "Cuadro",
			"position": [369,278]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Cuadro",
			"position": [553,278]
		},
		{
			"scene": "Cuadro",
			"position": [93,354]
		},
		{
			"scene": "Ecuacion",
			"position": [273,354]
		},
		{
			"scene": "Interruptor",
			"position": [265,386]
		},
		{
			"scene": "Ecuacion",
			"position": [365,354]
		},
		{
			"scene": "Interruptor",
			"position": [357,386]
		},
		{
			"scene": "Ecuacion",
			"position": [549,354]
		},
		{
			"scene": "Interruptor",
			"position": [541,386]
		}
	]
var level_4 = [
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Ecuacion",
			"position": [273,126]
		},
		{
			"scene": "Interruptor",
			"position": [265,158]
		},
		{
			"scene": "Ecuacion",
			"position": [365,126]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Ecuacion",
			"position": [457,126]
		},
		{
			"scene": "Interruptor",
			"position": [449,158]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [273,202]
		},
		{
			"scene": "Interruptor",
			"position": [265,234]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [89,278]
		},
		{
			"scene": "Interruptor",
			"position": [81,310]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Escalera",
			"position": [333,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [549,278]
		},
		{
			"scene": "Interruptor",
			"position": [541,310]
		},
		{
			"scene": "Cuadro",
			"position": [93,354]
		},
		{
			"scene": "Ecuacion",
			"position": [181,354]
		},
		{
			"scene": "Interruptor",
			"position": [173,386]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		},
		{
			"scene": "Cuadro",
			"position": [553,354]
		}
	]
var level_5 = [
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [365,126]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Cuadro",
			"position": [461,126]
		},
		{
			"scene": "Ecuacion",
			"position": [549,126]
		},
		{
			"scene": "Interruptor",
			"position": [541,158]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [181,202]
		},
		{
			"scene": "Interruptor",
			"position": [173,234]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [354,234]
		},
		{
			"scene": "Ecuacion",
			"position": [457,202]
		},
		{
			"scene": "Interruptor",
			"position": [449,234]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [181,278]
		},
		{
			"scene": "Interruptor",
			"position": [173,310]
		},
		{
			"scene": "Cuadro",
			"position": [277,278]
		},
		{
			"scene": "Cuadro",
			"position": [369,278]
		},
		{
			"scene": "Ecuacion",
			"position": [457,278]
		},
		{
			"scene": "Interruptor",
			"position": [449,310]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [181,354]
		},
		{
			"scene": "Interruptor",
			"position": [173,386]
		},
		{
			"scene": "Ecuacion",
			"position": [273,354]
		},
		{
			"scene": "Interruptor",
			"position": [265,386]
		},
		{
			"scene": "Ecuacion",
			"position": [365,354]
		},
		{
			"scene": "Interruptor",
			"position": [357,386]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		}
	]
var level_6 = [
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Ecuacion",
			"position": [273,126]
		},
		{
			"scene": "Interruptor",
			"position": [265,158]
		},
		{
			"scene": "Cuadro",
			"position": [369,126]
		},
		{
			"scene": "Ecuacion",
			"position": [457,126]
		},
		{
			"scene": "Interruptor",
			"position": [449,158]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [181,202]
		},
		{
			"scene": "Interruptor",
			"position": [173,234]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},
		{
			"scene": "Ecuacion",
			"position": [457,202]
		},
		{
			"scene": "Interruptor",
			"position": [449,234]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [181,278]
		},
		{
			"scene": "Interruptor",
			"position": [173,310]
		},
		{
			"scene": "Ecuacion",
			"position": [365,278]
		},
		{
			"scene": "Interruptor",
			"position": [357,310]
		},
		
		{
			"scene": "Ecuacion",
			"position": [457,278]
		},
		{
			"scene": "Interruptor",
			"position": [449,310]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [181,354]
		},
		{
			"scene": "Interruptor",
			"position": [173,386]
		},
		{
			"scene": "Ecuacion",
			"position": [273,354]
		},
		{
			"scene": "Interruptor",
			"position": [265,386]
		},
		{
			"scene": "Cuadro",
			"position": [369,354]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		}
	]
var level_7 = [
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [365,126]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Cuadro",
			"position": [461,126]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [181,202]
		},
		{
			"scene": "Interruptor",
			"position": [173,234]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},
		{
			"scene": "Ecuacion",
			"position": [457,202]
		},
		{
			"scene": "Interruptor",
			"position": [449,234]
		},
		{
			"scene": "Ecuacion",
			"position": [181,278]
		},
		{
			"scene": "Interruptor",
			"position": [173,310]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [365,278]
		},
		{
			"scene": "Interruptor",
			"position": [357,310]
		},
		{
			"scene": "Cuadro",
			"position": [461,278]
		},
		{
			"scene": "Ecuacion",
			"position": [549,278]
		},
		{
			"scene": "Interruptor",
			"position": [541,310]
		},
		{
			"scene": "Ecuacion",
			"position": [89,354]
		},
		{
			"scene": "Interruptor",
			"position": [81,386]
		},
		{
			"scene": "Ecuacion",
			"position": [181,354]
		},
		{
			"scene": "Interruptor",
			"position": [173,386]
		},
		{
			"scene": "Ecuacion",
			"position": [365,354]
		},
		{
			"scene": "Interruptor",
			"position": [357,386]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		},
		{
			"scene": "Cuadro",
			"position": [553,354]
		}
	]
var level_8 = [
		{
			"scene": "Ecuacion",
			"position": [89,126]
		},
		{
			"scene": "Interruptor",
			"position": [81,158]
		},
		{
			"scene": "Cuadro",
			"position": [185,126]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [365,126]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Ecuacion",
			"position": [457,126]
		},
		{
			"scene": "Interruptor",
			"position": [449,158]
		},
		{
			"scene": "Escalera",
			"position": [517,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [181,202]
		},
		{
			"scene": "Interruptor",
			"position": [173,234]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},
		{
			"scene": "Ecuacion",
			"position": [457,202]
		},
		{
			"scene": "Interruptor",
			"position": [449,234]
		},
		{
			"scene": "Ecuacion",
			"position": [181,278]
		},
		{
			"scene": "Interruptor",
			"position": [173,310]
		},
		{
			"scene": "Ecuacion",
			"position": [273,278]
		},
		{
			"scene": "Interruptor",
			"position": [265,310]
		},
		{
			"scene": "Escalera",
			"position": [333,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [457,278]
		},
		{
			"scene": "Interruptor",
			"position": [449,310]
		},
		{
			"scene": "Ecuacion",
			"position": [549,278]
		},
		{
			"scene": "Interruptor",
			"position": [541,310]
		},
		{
			"scene": "Ecuacion",
			"position": [89,354]
		},
		{
			"scene": "Interruptor",
			"position": [81,386]
		},
		{
			"scene": "Cuadro",
			"position": [185,354]
		},
		{
			"scene": "Cuadro",
			"position": [277,354]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		},
		{
			"scene": "Cuadro",
			"position": [553,354]
		}
	]
var level_9 = [
		{
			"scene": "Escalera",
			"position": [57,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Ecuacion",
			"position": [273,126]
		},
		{
			"scene": "Interruptor",
			"position": [265,158]
		},
		{
			"scene": "Escalera",
			"position": [333,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Cuadro",
			"position": [461,126]
		},
		{
			"scene": "Ecuacion",
			"position": [549,126]
		},
		{
			"scene": "Interruptor",
			"position": [541,158]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [273,202]
		},
		{
			"scene": "Interruptor",
			"position": [265,234]
		},
		{
			"scene": "Ecuacion",
			"position": [457,202]
		},
		{
			"scene": "Interruptor",
			"position": [449,234]
		},
		{
			"scene": "Ecuacion",
			"position": [549,202]
		},
		{
			"scene": "Interruptor",
			"position": [541,234]
		},
		{
			"scene": "Ecuacion",
			"position": [89,278]
		},
		{
			"scene": "Interruptor",
			"position": [81,310]
		},
		{
			"scene": "Escalera",
			"position": [150,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [273,278]
		},
		{
			"scene": "Interruptor",
			"position": [265,310]
		},
		{
			"scene": "Ecuacion",
			"position": [365,278]
		},
		{
			"scene": "Interruptor",
			"position": [357,310]
		},
		{
			"scene": "Cuadro",
			"position": [461,278]
		},
		{
			"scene": "Cuadro",
			"position": [553,278]
		},
		{
			"scene": "Ecuacion",
			"position": [89,354]
		},
		{
			"scene": "Interruptor",
			"position": [81,386]
		},
		{
			"scene": "Ecuacion",
			"position": [273,354]
		},
		{
			"scene": "Interruptor",
			"position": [265,386]
		},
		{
			"scene": "Ecuacion",
			"position": [365,354]
		},
		{
			"scene": "Interruptor",
			"position": [357,386]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		},
		{
			"scene": "Ecuacion",
			"position": [549,354]
		},
		{
			"scene": "Interruptor",
			"position": [541,386]
		}
	]
var level_10 = [
		{
			"scene": "Cuadro",
			"position": [93,126]
		},
		{
			"scene": "Ecuacion",
			"position": [181,126]
		},
		{
			"scene": "Interruptor",
			"position": [173,158]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_1]
		},
		{
			"scene": "Ecuacion",
			"position": [365,126]
		},
		{
			"scene": "Interruptor",
			"position": [357,158]
		},
		{
			"scene": "Ecuacion",
			"position": [457,126]
		},
		{
			"scene": "Interruptor",
			"position": [449,158]
		},
		{
			"scene": "Cuadro",
			"position": [553,126]
		},
		{
			"scene": "Cuadro",
			"position": [93,202]
		},
		{
			"scene": "Ecuacion",
			"position": [181,202]
		},
		{
			"scene": "Interruptor",
			"position": [173,234]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Ecuacion",
			"position": [365,202]
		},
		{
			"scene": "Interruptor",
			"position": [357,234]
		},
		{
			"scene": "Escalera",
			"position": [426,ESCALERA_Y_PISO_2]
		},
		{
			"scene": "Cuadro",
			"position": [553,202]
		},
		{
			"scene": "Ecuacion",
			"position": [89,278]
		},
		{
			"scene": "Interruptor",
			"position": [81,310]
		},
		{
			"scene": "Ecuacion",
			"position": [181,278]
		},
		{
			"scene": "Interruptor",
			"position": [173,310]
		},
		{
			"scene": "Escalera",
			"position": [241,ESCALERA_Y_PISO_3]
		},
		{
			"scene": "Ecuacion",
			"position": [365,278]
		},
		{
			"scene": "Interruptor",
			"position": [357,310]
		},
		{
			"scene": "Ecuacion",
			"position": [549,278]
		},
		{
			"scene": "Interruptor",
			"position": [541,310]
		},
		{
			"scene": "Ecuacion",
			"position": [89,354]
		},
		{
			"scene": "Interruptor",
			"position": [81,386]
		},
		{
			"scene": "Ecuacion",
			"position": [181,354]
		},
		{
			"scene": "Interruptor",
			"position": [173,386]
		},
		{
			"scene": "Ecuacion",
			"position": [365,354]
		},
		{
			"scene": "Interruptor",
			"position": [357,386]
		},
		{
			"scene": "Ecuacion",
			"position": [457,354]
		},
		{
			"scene": "Interruptor",
			"position": [449,386]
		},
		{
			"scene": "Ecuacion",
			"position": [549,354]
		},
		{
			"scene": "Interruptor",
			"position": [541,386]
		}
	]

# diccionario principal
var level_dictionary: Dictionary = {
	"levels": [
			level_1,
			level_2,
			level_3,
			level_4,
			level_5,
			level_6,
			level_7,
			level_8,
			level_9,
			level_10
	]
}

# listado de escenas
var scenes: Dictionary = {
	"Cuadro": preload("res://scenes/Cuadro.tscn"),
	"Ecuacion": preload("res://scenes/Ecuacion.tscn"),
	"Interruptor": preload("res://scenes/Interruptor.tscn"),
	"Escalera": preload("res://scenes/Escalera.tscn"),
	"Seleccion": preload("res://scenes/Seleccion.tscn"),
}

# instancia global de MathClass
var MathObj:MathClass = MathClass.new()


func _ready():
	OS.center_window()


func generate_expression(list:Array)->Array:
	var _exp:Array = ["", 0.0]

	MathObj.reset()
	MathObj.negativos = negativos
	MathObj.generate_expression([1, 1], randi() % get_allowed_operations(), list)

	_exp[FORMULA] = MathObj.to_string()
	_exp[RESULT] = MathObj.get_result()
	list.append(MathObj.to_string())

	return _exp


func get_allowed_operations():
	return suma_resta + multiplica + division


func save_data_to_file(save_data):
	if save_data == null:
		save_data = config

	var _json_str = to_json(save_data)
	var _file_handle = File.new()
	_file_handle.open(SAVE_DATA_PATH, File.WRITE)
	_file_handle.store_line(_json_str)
	_file_handle.close()


func load_data_from_file():
	var _file_handle = File.new()
	if !_file_handle.file_exists(SAVE_DATA_PATH):
		return _default_save_data
	
	_file_handle.open(SAVE_DATA_PATH, File.READ)	
	var _data = parse_json(_file_handle.get_as_text())
	_file_handle.close()
	
	return _data


"""
Rutinas para obtener las posiciones de los personajes.
"""
func get_final_y_position(y_pos:float, y_direction:int)->int:
	var _pos := int(y_pos)
	if y_direction == 1:
		for i in y_positions:
			if i > _pos:
				return i
	else:
		for i in range(3, -1, -1):
			var _cur_pos = Global.y_positions[i]
			if _cur_pos < _pos:
				return _cur_pos

	if y_direction == 1:
		return y_positions[y_positions.size()-1] # last position
	else:
		return y_positions[0] # first position


func get_final_x_position(x_pos:float, x_direction:int)->int:
	var _pos := int(x_pos)
	if x_direction == 1:
		for i in x_positions:
			if i > _pos:
				return i
	else:
		for i in range(5, -1, -1):
			var _cur_pos = x_positions[i]
			if _cur_pos < _pos:
				return _cur_pos

	if x_direction == 1:
		return x_positions[x_positions.size()-1] # last position
	else:
		return x_positions[0] # first position


# agrega un nuevo record en la lista top 10
func new_score(score:int, player:String)->void:

	if score == 0:
		score = current_score

	for i in range(9, -1, -1):
		config.scores[i].name = config.scores[i-1].name
		config.scores[i].score = config.scores[i-1].score

	# update the first player
	config.scores[0].name = player
	config.scores[0].score = score
	# save data
	save_data_to_file(config)
	

func change_scene(_new_scene:String)->void:
	if _new_scene != "":
		var _root = get_tree()
		_root.change_scene("res://scenes/" + _new_scene + ".tscn")

