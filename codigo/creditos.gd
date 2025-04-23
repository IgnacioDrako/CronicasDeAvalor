extends Control

@onready var credits_label = $Fondo_0/ColorRect/textoCreditos

# Variables para la animación
var start_position
var mid_position
var end_position
var animation_duration = 4.0  # Duración total de la animación
var pause_duration = 1.0      # Tiempo de pausa antes de detenerse

func _ready():
	# Configura las posiciones inicial, intermedia y final
	start_position = Vector2(credits_label.position.x, get_viewport_rect().size.y)
	mid_position = Vector2(credits_label.position.x, get_viewport_rect().size.y * 0.4)
	end_position = Vector2(credits_label.position.x, get_viewport_rect().size.y * 0.3)
	
	# Coloca inicialmente el texto fuera de la pantalla
	credits_label.position = start_position
	
	# Inicia con transparencia cero
	credits_label.modulate.a = 0
	
	# Inicia la animación cuando esté listo
	start_credits_animation()

func start_credits_animation():
	var tween = create_tween()
	
	# Fase 1: Aparición gradual mientras asciende hasta el punto medio
	tween.tween_property(credits_label, "position", mid_position, animation_duration * 0.5)
	tween.parallel().tween_property(credits_label, "modulate:a", 1.0, animation_duration * 0.3)
	
	# Fase 2: Continúa ascendiendo hasta la posición final pero más lento
	tween.tween_property(credits_label, "position", end_position, animation_duration * 0.5)
	
	# Fase 3: Pequeña pausa antes de terminar
	tween.tween_interval(pause_duration)
