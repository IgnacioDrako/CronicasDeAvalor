extends CharacterBody2D

var speed = 50.0
var health = 70.0
var player_position = 0
var movement_velocity = Vector2()
var is_atack = false
var is_hurt = false
var is_player_detected = false
var player_hit_range = false
var damage = 10 
@onready var mirar_suelo: RayCast2D = $MirarSuelo
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_ataque: Timer = $TimerAtaque
@onready var update: Timer = $Detection/update
@onready var detector: CollisionShape2D = $Detection/detector
@onready var detector_2: CollisionShape2D = $Detection2/detector2
@onready var busqueda: Timer = $Busqueda
@onready var update_2: Timer = $Detection2/update2
@onready var hit_box_enemy: CollisionShape2D = $HitBoxEnemy2/CollisionShape2D

func _ready() -> void:
	mirar_suelo.enabled = true  # Asegúrate de que el RayCast2D esté habilitado
	hit_box_enemy.disabled = true  # Desactivar el CollisionShape2D por defecto
	timer_ataque.timeout.connect(_on_attack_timer_timeout)  # tiempo de ataque
	update.timeout.connect(_on_detection_timer_timeout)  # Conectar el temporizador de detección al método
	update.start(0.5) 
	update_2.timeout.connect(_on_detection_2_timer_timerout)
	update_2.start(0.5)
	busqueda.timeout.connect(_on_Busqueda_timeout) # Conectar el temporizador de búsqueda al método
	busqueda.start(1.0)
func _physics_process(delta: float) -> void:
	if is_atack:
		return  # No permitir movimiento si está atacando
	if not hay_suelo():
		camviosentido()
		mover_izquierda(delta)
	elif hay_suelo():
		if position.x > player_position:
			mover_izquierda(delta)
			animated_sprite_2d.flip_h = false
			hit_box_enemy.position.x = -40
		elif position.x < player_position:
			velocity.x = +speed
			animated_sprite_2d.flip_h = true
			hit_box_enemy.position.x = +40
	move_and_slide()
	
func hay_suelo() -> bool:
	return mirar_suelo.is_colliding()
	
func _on_detection_timer_timeout() -> void:
	detector.disabled = not detector.disabled
	
func _on_detection_2_timer_timerout() -> void:
	detector_2.disabled = not detector_2.disabled
	
func _on_Busqueda_timeout() -> void:#metodo, posible escoria
	Busqueda_timer()

func Busqueda_timer()-> void:#escoria
	is_player_detected = false #reactivar "modo patrulla"

func camviosentido():# Cambia la dirección del movimiento
	speed = -speed
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h  # Voltea el sprite

func mover_izquierda(_delta: float) -> void:
	animated_sprite_2d.play("move")
	velocity.x = -speed
func get_PJ_position(pos_x: int, _pos_y: int) -> void:
	player_position = pos_x
	#is_player_detected = true
	#$Busqueda.start(0.5)

func _on_detection_2_body_entered(_body: Node2D) -> void:
	velocity = Vector2()  # Detener el movimiento
	movement_velocity = Vector2()  # Detener la velocidad
	if is_atack == false:
		atack()

func set_damage(value: int) -> void:
	damage = value
func atack():
	$TimerAtaque.start(1)
	velocity.x = 0
	hit_box_enemy.disabled = false  # Activar el CollisionShape2D para el ataque
	animated_sprite_2d.play("Ataque")
	is_atack=true

func _on_attack_timer_timeout():
	is_atack = false
	hit_box_enemy.disabled = true
	animated_sprite_2d.play("move")
