extends Node2D

@onready var demo_global = get_node("/root/DemoGlobal")  

func _ready():
	print("DemoGlobal node: ", demo_global)

func _on_area_2d_area_entered(area: Area2D) -> void:
		demo_global.current_scene = "res://nodos/Map/debug_map.tscn"  # Guarda la escena debug_map
		demo_global.savegame()
		print("Juego guardado al entrar en el área")
