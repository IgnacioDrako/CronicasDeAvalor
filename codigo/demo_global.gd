extends Node2D

var vidaPj = 100
@onready var demo_global = get_node("res://codigo/demo_global.gd")  
var ruta = "res://Salve/Guardado.Dummy" 
var current_scene = "res://nodos/Map/entrada_mapa_0.tscn"  # Escena inicial por defecto
func loadgame():
		if not FileAccess.file_exists(ruta):
			print("No se encontró el archivo de guardado.")
			return
		var file = FileAccess.open(ruta, FileAccess.READ)
		if file:
			var line = file.get_line()
			var loaded_data = JSON.parse_string(line)  # En Godot 4 devuelve un diccionario directamente
			if typeof(loaded_data) != TYPE_DICTIONARY:
				print("Error al parsear JSON: El archivo no contiene un diccionario válido.")
				return
			print("Cargado exitoso")
			vidaPj = loaded_data.get("vidaPj", vidaPj)
			current_scene = loaded_data.get("current_scene", current_scene)
			file.close()

func savegame():
	var data: Dictionary = {
		"vidaPj": vidaPj,
		"current_scene": current_scene,
	}
	var file = FileAccess.open(ruta, FileAccess.WRITE)
	if file:
		var data_json = JSON.stringify(data)
		file.store_line(data_json)
		file.close()
		print("Juego guardado exitosamente")
	else:
		print("Error al abrir el archivo de guardado.")
