extends Area2D
var animating_text = false
var text_alpha = 0.0
var text_y_offset = 0.0
var text_animation_speed = 1 # Velocidad de ascenso
var fade_speed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Ocultar el label al inicio
	$Label.modulate.a = 0.0
	# Guardar la posición inicial del label
	text_y_offset = $Label.position.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
func mensaje():
	$Label.modulate.a = 1.0  # Hacer visible el texto
	text_alpha = 1.0  # Reiniciar el valor alpha
	$Label.position.y = text_y_offset  # Resetear la posición
	animating_text = true
	pass
