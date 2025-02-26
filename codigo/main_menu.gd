extends Control

func _ready():
	$intro.play()
	$VBoxContainer/Jugar.grab_focus()
	$VBoxContainer/Cargar.grab_focus()
	$VBoxContainer/Salir.grab_focus()
	

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://nodos/Map/entrada_mapa_0.tscn")
	pass 

func _on_salir_pressed() -> void:
	get_tree().quit()
	pass

func _on_cargar_pressed() -> void:
	DemoGlobal.loadgame()
	get_tree().change_scene_to_file(DemoGlobal.current_scene)
	pass # Replace with function body.
