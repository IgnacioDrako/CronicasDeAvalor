extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ROLL_SPEED = SPEED * 2  # Velocidad duplicada cuando está rodando# Máquina de estados para el jugador
enum PlayerState {IDLE, MOVING, JUMPING, ATTACKING, ATTACKING_COMBO, HURT, ROLLING, DEAD}#combo no esta implementado
var current_state = PlayerState.IDLE
var can_combo = false  # Variable para permitir el combo
var vida=100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_timer: Timer = $Timer 
@onready var respawn_timer: Timer = $Timerdead
@onready var hurt_timer: Timer = $HurtTimer
@onready var combo_window_timer: Timer = $combo
@onready var auto_combo_timer: Timer
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
var combo_window_open: bool = false  # Variable para controlar la ventana de tiempo del combo
var auto_combo_enabled: bool = true  # Habilitar/deshabilitar el combo automático

# Variables para almacenar las posiciones y escalas originales
var original_collision_shape_scale: Vector2
var original_collision_shape_position: Vector2
var original_hit_box_scale: Vector2
var original_hit_box_position: Vector2

func _ready() -> void:
	# Posicionar al jugador en la posición guardada
	add_to_group("player")
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	#respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	timerroll.timeout.connect(_on_timerroll_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	hit_box.add_to_group("Hitbox")
	
	# Inicializar el timer para la ventana de combo
	combo_window_timer = Timer.new()
	combo_window_timer.one_shot = true
	combo_window_timer.wait_time = 0.5
	combo_window_timer.timeout.connect(_on_combo_window_timeout)
	add_child(combo_window_timer)
	
	# Inicializar el timer para auto combo
	auto_combo_timer = Timer.new()
	auto_combo_timer.one_shot = true
	auto_combo_timer.wait_time = 0.3  # Tiempo después del cual se ejecutará automáticamente el segundo ataque
	auto_combo_timer.timeout.connect(_on_auto_combo_timeout)
	add_child(auto_combo_timer)

	# Almacenar las posiciones y escalas originales
	original_collision_shape_scale = collision_shape.scale
	original_collision_shape_position = collision_shape.position
	original_hit_box_scale = hit_box.scale
	original_hit_box_position = hit_box.position
	
	#Barra de vida
	actualizar_Vida()
	
	#Bug en .EXE no guarda vida en valor global
	
func custom_get_gravity() -> Vector2:
	return Vector2(0, 980)  # Asumiendo una función get_gravity basada en el código original

func _process(delta): 
	if current_state == PlayerState.IDLE or current_state == PlayerState.MOVING:
		if Input.is_action_just_pressed("Atack"):
			start_attack()
	# Para estados dentro del combo, permitiendo cambiar de estado o continuar el combo
	elif current_state == PlayerState.ATTACKING and combo_window_open:
		if Input.is_action_just_pressed("Atack"):
			start_combo()
		# Permitir otros inputs durante la ventana de combo
		elif Input.is_action_just_pressed("Jump") and is_on_floor():
			# Cancelar el combo e ir a salto
			cancel_combo()
			velocity.y = JUMP_VELOCITY
			change_state(PlayerState.JUMPING)
		elif Input.is_action_just_pressed("roll") and can_roll:
			# Cancelar el combo e ir a rodar
			cancel_combo()
			start_rolling()
		elif Input.get_axis("MVI", "MVD") != 0 and is_on_floor():
			# Cancelar el combo y moverse
			cancel_combo()
			change_state(PlayerState.MOVING)

func cancel_combo() -> void:
	# Función auxiliar para cancelar el combo
	combo_window_open = false
	is_attacking = false
	$hitboxplayer/hitbox.disabled = true
	combo_window_timer.stop()
	auto_combo_timer.stop()

func actualizar_Vida() -> void:
	$Camera2D/Hud/HP0/vida.scale.x = vida / 100.0
	if vida <= 0:
		$Camera2D/Hud/HP0/vida.scale.x = 0 / 100.0
	
func _physics_process(delta: float) -> void:
	# Actualizar vida
	actualizar_Vida()
	
	# Determinar el próximo estado basado en la situación actual
	var next_state = current_state
	
	if vida <= 0:
		next_state = PlayerState.DEAD
	elif is_hurt:
		next_state = PlayerState.HURT
	elif is_rolling:
		next_state = PlayerState.ROLLING
	elif not is_on_floor():
		if not is_attacking and not is_combo:
			next_state = PlayerState.JUMPING
	elif Input.get_axis("MVI", "MVD") != 0 and not is_attacking and not is_combo:
		next_state = PlayerState.MOVING
	elif not is_attacking and not is_combo:
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
		PlayerState.ATTACKING_COMBO:
			animated_sprite.play("ataque1")  # Cambiado a ataque1 que debe ser tu segunda animación de ataque
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
		velocity += custom_get_gravity() * delta
	
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
		PlayerState.ATTACKING, PlayerState.ATTACKING_COMBO:
			velocity.x = 0
			$hitboxplayer/hitbox.disabled = false
		PlayerState.HURT:
			velocity.x = 0
		PlayerState.ROLLING:
			var direction = 1 if not animated_sprite.flip_h else -1
			velocity.x = direction * ROLL_SPEED
		PlayerState.DEAD:
			velocity.x = 0

func handle_input() -> void:
	# Solo procesar inputs en estados específicos
	if current_state == PlayerState.DEAD or current_state == PlayerState.HURT:
		return
	
	# Detectar salto solo si no está atacando o en combo
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_attacking and not is_combo and current_state != PlayerState.ROLLING:
		velocity.y = JUMP_VELOCITY
		change_state(PlayerState.JUMPING)
		return
	
	# Detectar roll solo si no está atacando o en combo
	if Input.is_action_just_pressed("roll") and can_roll and not is_attacking and not is_combo:
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
	#collision_shape.position.y = original_collision_shape_position.y + collision_shape.shape.extents.y / 2
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

func start_attack() -> void:
	is_attacking = true
	is_combo = false
	combo_window_open = false
	$hitboxplayer/hitbox.disabled = false
	change_state(PlayerState.ATTACKING)
	attack_timer.start(0.3)  # Temporizador para abrir la ventana de combo
	if auto_combo_enabled:
		auto_combo_timer.start()  # Inicia el timer para auto combo

func start_combo() -> void:
	is_attacking = false  # Desactivamos el primer ataque
	is_combo = true       # Activamos el combo
	combo_window_open = false
	$hitboxplayer/hitbox.disabled = false
	combo_window_timer.stop()  # Detener el timer de la ventana de combo
	auto_combo_timer.stop()    # Detener el timer de auto combo
	change_state(PlayerState.ATTACKING_COMBO)
	attack_timer.start(0.5)  # Duración del ataque combo

func _on_combo_window_timeout() -> void:
	# Cuando expira el tiempo de la ventana de combo, transición fluida al próximo estado
	combo_window_open = false
	is_attacking = false
	$hitboxplayer/hitbox.disabled = true
	
	# Determinar el próximo estado basado en los inputs actuales
	if Input.get_axis("MVI", "MVD") != 0 and is_on_floor():
		change_state(PlayerState.MOVING)
	elif is_on_floor():
		change_state(PlayerState.IDLE)
	else:
		change_state(PlayerState.JUMPING)

func _on_auto_combo_timeout() -> void:
	# Ejecuta automáticamente el segundo golpe si está en el primer ataque y con la ventana abierta
	if current_state == PlayerState.ATTACKING and combo_window_open and auto_combo_enabled:
		start_combo()

func _on_attack_timer_timeout() -> void:
	if current_state == PlayerState.ATTACKING and not is_combo:
		# Abrir ventana para combo después del primer ataque
		combo_window_open = true
		# Iniciar el timer para cerrar automáticamente la ventana de combo
		combo_window_timer.start()
	else:
		# Finalizar el ataque o el combo
		is_attacking = false
		is_combo = false
		combo_window_open = false
		$hitboxplayer/hitbox.disabled = true
		
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)

func _on_animation_finished(anim_name: String) -> void:
	# Manejar la finalización de las animaciones de ataque
	if anim_name == "ataque0" and combo_window_open:
		# No hacemos nada, esperamos a que el jugador decida si quiere hacer combo
		# o a que expire el timer de la ventana de combo
		pass
	elif anim_name == "ataque0" and not combo_window_open:
		# Si la ventana de combo está cerrada, volvemos al estado normal
		is_attacking = false
		$hitboxplayer/hitbox.disabled = true
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)
	elif anim_name == "ataque1":
		# Al terminar el combo, volvemos al estado normal
		is_combo = false
		$hitboxplayer/hitbox.disabled = true
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)

func received_damage(damage_amount: int) -> void:
	if vida <= 0:
		die()
	if is_hurt or is_dead or current_state == PlayerState.ROLLING:
		return
	
	vida -= damage_amount
	print("Jugador recibe daño: ", damage_amount)
	print("Salud restante: ", vida)
	
	is_hurt = true
	hurt_timer.start(0.5)
	
	# Efecto de knock-back
	if animated_sprite.flip_h:
		position.x += 25
	else:
		position.x -= 25
	
	# Interrumpir el ataque si está atacando
	cancel_combo()
	
	if vida <= 0:
		#change_state(PlayerState.DEAD)
		die()
	else:
		change_state(PlayerState.HURT)

func _on_hurt_timer_timeout() -> void:
	is_hurt = false
	
	if current_state == PlayerState.HURT:
		if is_on_floor():
			change_state(PlayerState.IDLE)
		else:
			change_state(PlayerState.JUMPING)

func die():
	$MenuMuerte.mostrar()
	animated_sprite.play("dead")
	#DemoGlobal.loadgame()

func _on_respawn_timer_timeout() -> void:
	get_tree().reload_current_scene()
	DemoGlobal.loadgame()

func hit(damage: int) -> void:
	if not is_hurt and not is_dead and current_state != PlayerState.ROLLING:
		received_damage(damage)

func heal(cura: int) -> void:
	print("Curado "+str(cura))
	if vida + cura >= 100:
		vida = 100
	else:
		vida += cura
	actualizar_Vida()

# Función para habilitar/deshabilitar el combo automático (útil si quieres agregar una opción en el menú)
func set_auto_combo(enabled: bool) -> void:
	auto_combo_enabled = enabled
