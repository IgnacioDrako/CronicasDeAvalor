extends Node2D
@onready var menu_pausa = $player/MenuPausa
@onready var dummy: Timer = $dummy
@onready var enfriamiento: Timer = $nfriamiento
@onready var animation_player: AnimationPlayer = $Map/MainMap/Muro/AnimationPlayer
@onready var boss_slime: CharacterBody2D = $BossSlime
var contador=0

func _ready():
	menu_pausa.connect("continuar_juego", Callable(self, "_on_continuar_juego"))
	menu_pausa.connect("salir_al_menu", Callable(self, "_on_salir_al_menu"))
	$ColorRect/AnimationPlayer.play("a")

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


func _on_triger_puerta_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if contador==0:
			animation_player.play("cerrar")
			boss_slime.speed=100
			$Map/trigerPuerta/CollisionShape2D.disabled=true
			contador=+1
		else:
			print("si")
	pass # Replace with function body.
func _fin_demo():
	$ColorRect/AnimationPlayer.play("b")
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://nodos/elementos/creditos.tscn")
	pass
