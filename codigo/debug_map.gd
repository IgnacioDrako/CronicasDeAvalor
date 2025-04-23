extends Node2D
@onready var color_rect: ColorRect = $ColorRect
@onready var menu_pausa: Control = $player/MenuPausa
@onready var cargamapa: AnimationPlayer = $ColorRect/AnimationPlayer

func _ready():
	menu_pausa.connect("continuar_juego", Callable(self, "_on_continuar_juego"))
	menu_pausa.connect("salir_al_menu", Callable(self, "_on_salir_al_menu"))
	cargamapa.play("a")
func _input(event):
	if event.is_action_pressed("escape"):
		if menu_pausa.visible:
			menu_pausa.ocultar()
		else:
			menu_pausa.mostrar()
func pausar_juego():
	print("Pausando el juego desde el nodo padre")
	#get_tree().paused = true

func reanudar_juego():
	print("Reanudando el juego desde el nodo padre")
	#get_tree().paused = false

func _on_continuar_juego():
	print("Continuar juego desde el nodo padre")

func _on_salir_al_menu():
	print("Salir al menú desde el nodo padre")


func _on_zona_de_muerte_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var pater = area.get_parent()
		pater.received_damage(500)
		pass
	pass # Replace with function body.


func _on_trigger_mensaje_area_entered(area: Area2D) -> void:
	print("A")
	if area.is_in_group("player"):
		$mensajesTutorail/triggerMensaje.mensaje()
	pass # Replace with function body.


func _on_trigger_mensaje_0_area_entered(area: Area2D) -> void:
	print("B")
	if area.is_in_group("player"):
		$mensajesTutorail/triggerMensaje0.mensaje()
	pass # Replace with function body.


func _on_trigermensaje_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		$mensajesTutorail/trigermensaje1.mensaje()
	pass # Replace with function body.


func _on_trigermensaje_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		$mensajesTutorail/trigermensaje2.mensaje()
	pass # Replace with function body.


func _on_trigermensaje_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		$mensajesTutorail/trigermensaje3.mensaje()
	pass # Replace with function body.


func _on_camvio_mapa_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		$CamvioMapa.siguienteZona()
	pass # Replace with function body.
