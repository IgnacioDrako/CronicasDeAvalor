extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ROLL_SPEED = SPEED * 2  # Velocidad duplicada cuando está rodando

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_timer: Timer = $Timer 
@onready var respawn_timer: Timer = $Timerdead
@onready var hurt_timer: Timer = $HurtTimer  # Asegúrate de que este timer esté presente en la escena
@export var offset_x: float = 100.0 
@onready var hit_box: Area2D = $hitboxplayer
@onready var collision_shape: CollisionShape2D = $Cuerpo  # Asegúrate de que este nodo esté presente en la escena
@onready var timerroll: Timer = $Timerroll
@onready var hurtbox: CollisionShape2D = $hurtbox/hurtbox
@onready var varravida: Sprite2D = $Camera2D/Hud/HP0/HP3
@onready var audio_rodar: AudioStreamPlayer2D = $AudioRodar
@onready var audioda_hurt: AudioStreamPlayer2D = $Audiodaño
@onready var audioda_ataque: AudioStreamPlayer2D = $Audiodañar
@onready var audiomorir: AudioStreamPlayer2D = $Audiomorir
@onready var audio_caminar: AudioStreamPlayer2D = $AudioCaminar


var health = 100  # Salud del jugador
var is_attacking: bool = false  # Variable para controlar el ataque
var is_hurt: bool = false  # Estado para controlar si el jugador está herido
var is_dead: bool = false  # Estado para controlar la muerte
var is_rolling: bool = false  # Estado para controlar si el jugador está rodando
var can_roll: bool = true  # Estado para controlar si el jugador puede rodar

# Variables para almacenar las posiciones y escalas originales
var original_collision_shape_scale: Vector2
var original_collision_shape_position: Vector2
var original_hit_box_scale: Vector2
var original_hit_box_position: Vector2

func _ready() -> void:
	add_to_group("PJ")
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)  # Conectar el temporizador de hurt
	timerroll.timeout.connect(_on_timerroll_timeout)  # Conectar el temporizador de roll
	animated_sprite.animation_finished.connect(_on_animation_finished)  # Conectar la señal de animación terminada
	hit_box.add_to_group("Hitbox")

	# Almacenar las posiciones y escalas originales
	original_collision_shape_scale = collision_shape.scale
	original_collision_shape_position = collision_shape.position
	original_hit_box_scale = hit_box.scale
	original_hit_box_position = hit_box.position
	#Barra de vida
	actualizar_Vida()

func actualizar_Vida() -> void:
	$Camera2D/Hud/Vida.text = str(health)
	varravida.scale.x = 1.0 * health/100
	pass
	
func _physics_process(delta: float) -> void:
	if health <= 0:
		die(delta)  # Solo llama a die() si la salud es 0 o menos

	if is_dead:
		return  # No permite ninguna acción si está muerto

	# Permitimos saltar y atacar, pero no mover horizontalmente
	if is_hurt or is_attacking:
		actualizar_Vida()
		velocity.x = 0  # Detener el movimiento horizontal
		if not is_on_floor():
			velocity += get_gravity() * delta  # Deja que la gravedad afecte el movimiento vertical
		move_and_slide()  # Asegúrate de aplicar el movimiento
		return  # Evita que el jugador haga otras acciones

	if not is_on_floor():
		velocity += get_gravity() * delta  # Aplica gravedad cuando no esté en el suelo

	# Detectar si el jugador está rodando
	if Input.is_action_just_pressed("roll") and can_roll:
		start_rolling()

	# Saltar solo si está en el suelo y no está atacando ni herido ni rodando
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_rolling:
		velocity.y = JUMP_VELOCITY

	# Ataque en el suelo o en el aire, con cooldown
	if Input.is_action_just_pressed("Atack") and not is_attacking:
		is_attacking = true
		$hitboxplayer/hitbox.disabled = false
		animated_sprite.play("ataque0")
		attack_timer.start(0.5)  # Cooldown de 0.5 segundos
		audioda_ataque.play()  # Reproducir sonido de ataque
		if not is_on_floor():
			velocity += get_gravity() * delta  # Asegura que la gravedad siga actuando en el ataque aéreo
		return

	# Manejo del movimiento horizontal
	var direction := Input.get_axis("MVI", "MVD")
	if direction > 0:
		animated_sprite.flip_h = false
		$hitboxplayer.position.x = 40
	elif direction < 0:
		animated_sprite.flip_h = true
		$hitboxplayer.position.x = -40

	# Control de animaciones basado en el estado del jugador
	if is_on_floor():
		if direction == 0:
			audio_caminar.stop()  # Detener el sonido de caminar
			if is_rolling:
				animated_sprite.play("roll")
			else:
				animated_sprite.play("Idle")
		elif not is_rolling:
			animated_sprite.play("move")
			if (Input.is_action_just_pressed("MVI") or Input.is_action_just_pressed("MVD")):
				audio_caminar.play()  # Reproducir sonido de caminar
	elif not is_rolling:
		animated_sprite.play("salto")

	if is_rolling:
		velocity.x = direction * ROLL_SPEED
	else:
		velocity.x = direction * SPEED
	move_and_slide()

func start_rolling() -> void:
	is_rolling = true
	can_roll = false
	animated_sprite.play("roll")
	audio_rodar.play()  # Reproducir sonido de rodar
	collision_shape.scale.y = 0.5  # Reducir la altura del collision shape
	collision_shape.position.y = original_collision_shape_position.y / 2  # Ajustar la posición del collision shape
	hurtbox.disabled = true  # Deshabilitar la hurtbox durante el roll
	timerroll.start(0.5)  # Duración del roll

func stop_rolling() -> void:
	is_rolling = false
	animated_sprite.play("Idle")
	collision_shape.scale = original_collision_shape_scale  # Restaurar la altura del collision shape
	collision_shape.position = original_collision_shape_position  # Restaurar la posición del collision shape
	hurtbox.disabled = false  # Habilitar la hurtbox después del roll
	timerroll.start(1.5)  # Tiempo de enfriamiento del roll

func _on_timerroll_timeout() -> void:
	if is_rolling:
		stop_rolling()
	else:
		can_roll = true

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	$hitboxplayer/hitbox.disabled = true
	if is_on_floor():
		animated_sprite.play("Idle")

func received_damage(damage_amount: int) -> void:
	if is_hurt:  # Evita que el jugador reciba daño mientras ya está herido
		return
	health -= damage_amount
	print("Jugador recibe daño: ", damage_amount)
	print("Salud restante: ", health)
	animated_sprite.play("hurt")
	audioda_hurt.play()  # Reproducir sonido de daño recibido
	is_hurt = true  # Cambia el estado a herido
	hurt_timer.start(0.5)  # Inicia el temporizador para volver a la normalidad
	if animated_sprite.flip_h:
		position.x += 25  # Si está mirando a la izquierda, empuja a la derecha
	else:
		position.x -= 25  # Si está mirando a la derecha, empuja a la izquierda

func _on_hurt_timer_timeout() -> void:
	is_hurt = false  # Permitir que el jugador reciba daño de nuevo

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hurt" and not is_hurt:
		if is_on_floor():
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("salto")

func die(delta) -> void:
	if is_dead:
		return  # Evita múltiples llamadas a die()
	is_dead = true  # Cambia el estado a muerto
	velocity += get_gravity() * delta 
	animated_sprite.play("dead")
	audiomorir.play()  # Reproducir sonido de muerte
	respawn_timer.start(1)  # Inicia el temporizador

func _on_respawn_timer_timeout() -> void:
	get_tree().reload_current_scene()  # Reinicia la escena

func hit(damage: int) -> void:
	if not is_hurt and not is_dead:
		health -= damage
		is_hurt = true
		hurt_timer.start()
		if health <= 0:
			die(0.5)
