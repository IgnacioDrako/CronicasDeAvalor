extends Node2D
@onready var label: Label = $Label
@onready var demo_global = get_node("/root/DemoGlobal")  

# Variables para la animación del texto
var animating_text = false
var text_alpha = 0.0
var text_y_offset = 0.0
var text_animation_speed = 50.0  # Velocidad de ascenso
var fade_speed = 1.5  # Velocidad de desvanecimiento

func _ready():
	# Ocultar el label al inicio
	$Label.modulate.a = 0.0
	# Guardar la posición inicial del label
	text_y_offset = $Label.position.y

func _process(delta):
	if animating_text:
		# Mover el texto hacia arriba
		$Label.position.y -= text_animation_speed * delta
		
		# Reducir el alpha gradualmente
		text_alpha -= fade_speed * delta
		$Label.modulate.a = text_alpha
		
		# Detener la animación cuando el texto sea completamente transparente
		if text_alpha <= 0:
			animating_text = false
			# Restablecer la posición del label para la próxima vez
			$Label.position.y = text_y_offset
func _on_area_2d_area_entered(area: Area2D) -> void:
		demo_global.current_scene = "res://nodos/Map/zonasegura_0.tscn"
		demo_global.savegame()
		$Label.modulate.a = 1.0  # Hacer visible el texto
		text_alpha = 1.0  # Reiniciar el valor alpha
		$Label.position.y = text_y_offset  # Resetear la posición
		animating_text = true
		$AudioStreamPlayer2D.play()
