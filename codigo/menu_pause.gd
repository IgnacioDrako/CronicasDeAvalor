extends Control
signal continuar_juego
signal salir_al_menu

func _ready():
	$PanelContainer/VBoxContainer/Continue.grab_focus()
	$PanelContainer/VBoxContainer/Exit.grab_focus()
	print("Menu de pausa listo")
	print("Nodo padre: ", get_parent().name)
	$PanelContainer/VBoxContainer/Continue.pressed.connect(_on_continuar_pressed)
	$PanelContainer/VBoxContainer/Exit.pressed.connect(_on_salir_pressed)
	visible = false  # Ocultar el menú al inicio

func mostrar():
	get_tree().paused=true
	print("Mostrando menú de pausa")
	visible = true
	var parent_node = get_node("../..")  # Subir dos niveles para obtener el nodo mapa
	if parent_node.has_method("pausar_juego"):
		parent_node.call_deferred("pausar_juego")
	else:
		print("Error: El nodo padre no tiene el método 'pausar_juego'")

func ocultar():
	print("Ocultando menú de pausa")
	visible = false
	var parent_node = get_node("../..")  # Subir dos niveles para obtener el nodo mapa
	if parent_node.has_method("reanudar_juego"):
		parent_node.call_deferred("reanudar_juego")
	else:
		print("Error: El nodo padre no tiene el método 'reanudar_juego'")

func _on_continuar_pressed():
	get_tree().paused=false
	print("Continuar presionado")
	ocultar()
	continuar_juego.emit()

func _on_salir_pressed():
	print("Salir presionado")
	get_tree().paused=false
	var parent_node = get_node("../..")  # Subir dos niveles para obtener el nodo mapa
	if parent_node.has_method("reanudar_juego"):
		parent_node.call_deferred("reanudar_juego")
	else:
		print("Error: El nodo padre no tiene el método 'reanudar_juego'")
	salir_al_menu.emit()
	get_tree().change_scene_to_file("res://nodos/elementos/main_menu.tscn")
	continuar_juego.emit()
