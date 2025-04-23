extends Node2D
@onready var enfriamiento: Timer = $enfriamiento
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var vida: Timer = $vida
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Configura el Timer para que se repita automáticamente cada 10 segundos
	#enfriamiento.wait_time = 10.0
	#enfriamiento.autostart = true
	#enfriamiento.one_shot = false
	#enfriamiento.start(10)
	animated_sprite_2d.visible = false
	enfriamiento.start(55)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

# Esta función ahora solo muestra la animación y prepara la invocación
func invocaresqueleto() -> void:
	# Mostrar animación de invocación
	# Crear el enemigo
	var esqueleto = preload("res://nodos/elementos/caco_demonio.tscn")
	var esqueleto_instance = esqueleto.instantiate()
	get_parent().add_child(esqueleto_instance)
	esqueleto_instance.global_position = global_position
	# Iniciar temporizador para completar la invocación
	vida.start(5)
	pass

# Cuando termina la animación, se crea el enemigo
func _on_vida_timeout() -> void:
	# Ocultar la animación
	animated_sprite_2d.visible = false

	pass

# Iniciar el proceso de invocación cuando el enfriamiento termina
func _on_enfriamiento_timeout() -> void:
	enfriamiento.start(35)
	animated_sprite_2d.visible = true
	await(1)
	invocaresqueleto()
	pass
