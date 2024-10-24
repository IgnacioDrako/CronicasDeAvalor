extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_timer: Timer = $Timer 
@onready var respawn_timer: Timer = $Timerdead
@onready var hurt_timer: Timer = $HurtTimer  # Asegúrate de que este timer esté presente en la escena
@export var offset_x: float = 100.0 
@onready var hit_box: Area2D = $hitboxplayer

var health = 100  # Salud del jugador
var is_attacking: bool = false  # Variable para controlar el ataque
var is_hurt: bool = false  # Estado para controlar si el jugador está herido
var is_dead: bool = false  # Estado para controlar la muerte

func _ready() -> void:
	add_to_group("PJ")
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)  # Conectar el temporizador de hurt
	hit_box.add_to_group("Hitbox")

func _physics_process(delta: float) -> void:
	if health <= 0:
		die(delta)  # Solo llama a die() si la salud es 0 o menos

	if is_dead:
		return  # No permite ninguna acción si está muerto

	# Permitimos saltar y atacar, pero no mover horizontalmente
	if is_hurt or is_attacking:
		velocity.x = 0  # Detener el movimiento horizontal
		if not is_on_floor():
			velocity += get_gravity() * delta  # Deja que la gravedad afecte el movimiento vertical
		move_and_slide()  # Asegúrate de aplicar el movimiento
		return  # Evita que el jugador haga otras acciones

	if not is_on_floor():
		velocity += get_gravity() * delta  # Aplica gravedad cuando no esté en el suelo

	# Saltar solo si está en el suelo y no está atacando ni herido
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Ataque en el suelo o en el aire, con cooldown
	if Input.is_action_just_pressed("Atack") and not is_attacking:
		is_attacking = true
		$hitboxplayer/hitbox.disabled = false
		animated_sprite.play("ataque0")
		attack_timer.start(0.5)  # Cooldown de 0.5 segundos
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

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("move")
	else:
		animated_sprite.play("salto")

	velocity.x = direction * SPEED
	move_and_slide()

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
	animated_sprite.stop()
	animated_sprite.play("hurt")
	is_hurt = true  # Cambia el estado a herido
	hurt_timer.start(0.2)  # Inicia el temporizador para volver a la normalidad
	if animated_sprite.flip_h:
		position.x = position.x+25  # Si está mirando a la izquierda, empuja a la derecha
		print("entra")
	else:
		position.x = position.x-25  # Si está mirando a la derecha, empuja a la izquierda
		print("entra")


func _on_hurt_timer_timeout() -> void:
	is_hurt = false  # Permitir que el jugador reciba daño de nuevo

func die(delta) -> void:
	if is_dead:
		return  # Evita múltiples llamadas a die()
	is_dead = true  # Cambia el estado a muerto
	velocity += get_gravity() * delta 
	animated_sprite.play("dead")
	respawn_timer.start(1)  # Inicia el temporizador

func _on_respawn_timer_timeout() -> void:
	get_tree().reload_current_scene()  # Reinicia la escena
