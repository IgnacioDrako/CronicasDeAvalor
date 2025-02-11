extends Control

func _ready():
	$intro.play()
func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://nodos/Map/entrada_mapa_0.tscn")
	pass 


func _on_salir_pressed() -> void:
	get_tree().quit()
	pass
