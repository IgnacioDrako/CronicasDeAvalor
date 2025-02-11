extends Node2D
@onready var menu_pausa: Control = $player/MenuPausa

# Called when the node enters the scene tree for the first time.
func _ready():
	if menu_pausa:
		menu_pausa.connect("continuar_juego", Callable(self, "_on_continuar_juego"))
		menu_pausa.connect("salir_al_menu", Callable(self, "_on_salir_al_menu"))
	else:
		print("Error: menu_pausa no está instanciado correctamente")

func _input(event):
	if event.is_action_pressed("escape"):
		if menu_pausa and menu_pausa.visible:
			menu_pausa.ocultar()
		elif menu_pausa:
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
