extends Node2D
@onready var menu_pausa = $player/MenuPausa

func _ready():
	menu_pausa.connect("continuar_juego", Callable(self, "_on_continuar_juego"))
	menu_pausa.connect("salir_al_menu", Callable(self, "_on_salir_al_menu"))

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
