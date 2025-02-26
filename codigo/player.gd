extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ROLL_SPEED = SPEED * 2  # Velocidad duplicada cuando está rodando

# Máquina de estados para el jugador
enum PlayerState {IDLE, MOVING, JUMPING, ATTACKING, ATTACKINGCOMBO, HURT, ROLLING, DEAD}
var current_state = PlayerState.IDLE

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_timer: Timer = $Timer 
@onready var respawn_timer: Timer = $Timerdead
@onready var hurt_timer: Timer = $HurtTimer
@export var offset_x: float = 100.0 
@onready var hit_box: Area2D = $hitboxplayer
@onready var collision_shape: CollisionShape2D = $Cuerpo
@onready var timerroll: Timer = $Timerroll
@onready var hurtbox: CollisionShape2D = $hurtbox/hurtbox
@onready var varravida: Sprite2D = $Camera2D/Hud/HP0/HP3
@onready var audio_rodar: AudioStreamPlayer2D = $AudioRodar
@onready var audioda_hurt: AudioStreamPlayer2D = $Audiodaño
@onready var audioda_ataque: AudioStreamPlayer2D = $Audiodañar
@onready var audiomorir: AudioStreamPlayer2D = $Audiomorir
@onready var audio_caminar: AudioStreamPlayer2D = $AudioCaminar

var is_attacking: bool = false
var is_combo: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var is_rolling: bool = false
var can_roll: bool = true

# Variables para almacenar las posiciones y escalas originales
var original_collision_shape_scale: Vector2
var original_collision_shape_position: Vector2
var original_hit_box_scale: Vector2
var original_hit_box_position: Vector2

func _ready() -> void:
	# Posicionar al jugador en la posición guardada
	add_to_group("player")
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	timerroll.timeout.connect(_on_timerroll_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	hit_box.add_to_group("Hitbox")

	# Almacenar las posiciones y escalas originales
	original_collision_shape_scale = collision_shape.scale
	original_collision_shape_position = collision_shape.position
	original_hit_box_scale = hit_box.scale
	original_hit_box_position = hit_box.position
	
	#Barra de vida
	actualizar_Vida()

func custom_get_gravity() -> Vector2:
	return Vector2(0, 980)  # Asumiendo una función get_gravity basada en el código original

func actualizar_Vida() -> void:
	$Camera2D/Hud/Vida.text = str(DemoGlobal.vidaPj)
	varravida.scale.x = 1.0 * DemoGlobal.vidaPj/100
	
func _physics_process(delta: float) -> void:
	# Actualizar vida
	actualizar_Vida()
	
	# Determinar el próximo estado basado en la situación actual
	var next_state = current_state
	
	if DemoGlobal.vidaPj <= 0:
		next_state = PlayerState.DEAD
	elif is_hurt:
		next_state = PlayerState.HURT
	elif is_attacking:
		next_state = PlayerState.ATTACKING
		if is_combo:
			next_state=PlayerState.ATTACKINGCOMBO
	elif is_rolling:
		next_state = PlayerState.ROLLING
	elif not is_on_floor():
		next_state = PlayerState.JUMPING
	elif Input.get_axis("MVI", "MVD") != 0:
		next_state = PlayerState.MOVING
	else:
		next_state = PlayerState.IDLE
	
	# Solo cambiar la animación si el estado cambió
	if current_state != next_state:
		change_state(next_state)
	
	# Lógica de movimiento según el estado
	handle_state_logic(delta)
	
	# Procesar inputs solo si está en estados que los permitan
	if not is_dead and not is_hurt:
		handle_input()
	
	# Aplicar movimiento
	move_and_slide()

func change_state(new_state: int) -> void:
	var old_state = current_state
	current_state = new_state
	
	# Acciones de salida del estado anterior
	match old_state:
		PlayerState.MOVING:
			audio_caminar.stop()
	
	# Acciones de entrada al nuevo estado
	match current_state:
		PlayerState.IDLE:
			animated_sprite.play("Idle")
		PlayerState.MOVING:
			animated_sprite.play("move")
			if not audio_caminar.playing:
				audio_caminar.play()
		PlayerState.JUMPING:
			animated_sprite.play("salto")
		PlayerState.ATTACKING:
			animated_sprite.play("ataque0")
			audioda_ataque.play()
		PlayerState.HURT:
			animated_sprite.play("hurt")
			audioda_hurt.play()
		PlayerState.ROLLING:
			animated_sprite.play("roll")
			audio_rodar.play()
		PlayerState.DEAD:
			animated_sprite.play("dead")
			audiomorir.play()
			respawn_timer.start(1)

func handle_state_logic(delta: float) -> void:
	# Aplicar gravedad siempre que no esté en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Lógica específica por estado
	match current_state:
		PlayerState.IDLE:
			velocity.x = 0
		PlayerState.MOVING:
			var direction = Input.get_axis("MVI", "MVD")
			velocity.x = direction * SPEED
			update_facing_direction(direction)
		PlayerState.JUMPING:
			var direction = Input.get_axis("MVI", "MVD")
			velocity.x = direction * SPEED
			update_facing_direction(direction)
		PlayerState.ATTACKING:
			velocity.x = 0
			$hitboxplayer/hitbox.disabled = false
		PlayerState.HURT:
			velocity.x = 0
		PlayerState.ROLLING:
			var direction = Input.get_axis("MVI", "MVD")
			velocity.x = direction * ROLL_SPEED
			update_facing_direction(direction)
		PlayerState.DEAD:
			velocity.x = 0

func handle_input() -> void:
	# Solo procesar inputs en estados específicos
	if current_state == PlayerState.DEAD or current_state == PlayerState.HURT:
		return
	
	# Detectar ataque
	if Input.is_action_just_pressed("Atack") and current_state != PlayerState.ATTACKING and current_state != PlayerState.ROLLING:
		is_attacking = true
		$hitboxplayer/hitbox.disabled = false
		attack_timer.start(0.5)
		change_state(PlayerState.ATTACKING)
		if Input.is_action_just_pressed("Atack") and current_state != PlayerState.ATTACKINGCOMBO and current_state != PlayerState.ROLLING:
			is_combo = true
			$hitboxplayer/hitbox.disabled = false
			attack_timer.start(0.5)
			change_state(PlayerState.ATTACKINGCOMBO)
			return
		return
	
	# Detectar salto
	if Input.is_action_just_pressed("Jump") and is_on_floor() and current_state != PlayerState.ROLLING and current_state != PlayerState.ATTACKING:
		velocity.y = JUMP_VELOCITY
		change_state(PlayerState.JUMPING)
		return
	
	# Detectar roll
	if Input.is_action_just_pressed("roll") and can_roll and current_state != PlayerState.ATTACKING:
		start_rolling()
		return

func update_facing_direction(direction: float) -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		$hitboxplayer.position.x = 40
	elif direction < 0:
		animated_sprite.flip_h = true
		$hitboxplayer.position.x = -40

func start_rolling() -> void:
	is_rolling = true
	can_roll = false
	collision_shape.scale.y = 0.5
	collision_shape.position.y = original_collision_shape_position.y / 2
	hurtbox.disabled = true
	timerroll.start(0.5)
	change_state(PlayerState.ROLLING)

func stop_rolling() -> void:
	is_rolling = false
	collision_shape.scale = original_collision_shape_scale
	collision_shape.position = original_collision_shape_position
	hurtbox.disabled = false
	timerroll.start(1.5)
	
	if is_on_floor():
		change_state(PlayerState.IDLE)
	else:
		change_state(PlayerState.JUMPING)

func _on_timerroll_timeout() -> void:
	if is_rolling:
		stop_rolling()
	else:
		can_roll = true

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	$hitboxplayer/hitbox.disabled = true
	
	if current_state == PlayerState.ATTACKING:
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)

func received_damage(damage_amount: int) -> void:
	if is_hurt or is_dead or current_state == PlayerState.ROLLING:
		return
	
	DemoGlobal.vidaPj -= damage_amount
	print("Jugador recibe daño: ", damage_amount)
	print("Salud restante: ", DemoGlobal.vidaPj)
	
	is_hurt = true
	hurt_timer.start(0.5)
	
	# Efecto de knock-back
	if animated_sprite.flip_h:
		position.x += 25
	else:
		position.x -= 25
	
	if DemoGlobal.vidaPj <= 0:
		change_state(PlayerState.DEAD)
	else:
		change_state(PlayerState.HURT)

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	
	if current_state == PlayerState.HURT:
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hurt" and not is_hurt:
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)
	elif anim_name == "ataque0" and not is_attacking:
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)

func die(delta: float = 0) -> void:
	if is_dead:
		return
	
	is_dead = true
	change_state(PlayerState.DEAD)

func _on_respawn_timer_timeout() -> void:
	get_tree().reload_current_scene()

func hit(damage: int) -> void:
	if not is_hurt and not is_dead and current_state != PlayerState.ROLLING:
		received_damage(damage)

func heal(cura: int) -> void:
	print("Curado "+str(cura))
	if DemoGlobal.vidaPj + cura >= 100:
		DemoGlobal.vidaPj = 100
	else:
		DemoGlobal.vidaPj += cura
	actualizar_Vida()
