extends Node2D
@onready var trasicion_animacion: AnimationPlayer = $ColorRect/TrasicionAnimacion
@onready var color_rect: ColorRect = $ColorRect

func _on_trigger_area_entered(body):
	print("puerta")
	get_tree().change_scene_to_file("res://nodos/Map/mapa_0.tscn")
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("puerta")
	color_rect.visible=true
	trasicion_animacion.play("dummy")
	await get_tree().create_timer(0.5).timeout  # Espera 1 segundo
	get_tree().change_scene_to_file("res://nodos/Map/mapa_0.tscn")
	
