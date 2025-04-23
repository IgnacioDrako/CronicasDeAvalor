extends CharacterBody2D

# Máquina de estados para el caco demonio 
enum DemonState {IDLE, ATTACKING, HURT, DEAD}
var current_state = DemonState.IDLE

@onready var HurtBox: CollisionShape2D = $hurtboxenemi/CollisionShape2D
@onready var Detection: Area2D = $Detection
@onready var DetectionShape: CollisionShape2D = $Detection/detector
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_hurt: Timer = $TimerHurt
@onready var timer_detection: Timer = $Detection/update
@onready var dead_timer: Timer = $Timerdead
@onready var detector_2: CollisionShape2D = $Detection2/detector2
@onready var audioataque: AudioStreamPlayer2D = $Audioataque
@onready var audioerido: AudioStreamPlayer2D = $Audioerido
@onready var audiomuerte: AudioStreamPlayer2D = $Audiomuerte
@onready var barra_vida: TextureProgressBar = $vida/barraVida

var health = 50
var maxlife = 50
var is_hurt: bool = false
var speed = 0
var player_position = Vector2()
var threshold = 1.0  # Umbral para evitar vibraciones
var damage = 10
var is_attacking: bool = false
var damage_received: bool = false  # Nueva variable para forzar el cambio de estado

func _ready():
	#actualizarvida()
	add_to_group("enemys")
	dead_timer.timeout.connect(die)
	timer_hurt.timeout.connect(_on_hurt_timer_timeout)
	timer_detection.timeout.connect(_on_detection_timer_timeout)
	timer_detection.start(0.5)
	
	# Configurar el timer_hurt para que sea one-shot
	timer_hurt.one_shot = true
	
	# Iniciar con animación Idle
	change_state(DemonState.IDLE)

func actualizarvida() -> void:
	# Actualiza la barra de vida
	var porcetajevida = float(health) / maxlife
	porcetajevida = max(0.0, porcetajevida)
	barra_vida.scale.x = porcetajevida

func _process(delta):
	if is_hurt and health > 0:
		handle_state_logic(delta)
		update_sprite_direction()
		return
	
	# Determinar el próximo estado - simplificado sin MOVING
	var next_state = current_state
	
	if health <= 0:
		next_state = DemonState.DEAD
	elif is_hurt:
		next_state = DemonState.HURT
	elif is_attacking:
		next_state = DemonState.ATTACKING
	else:
		next_state = DemonState.IDLE
	
	# Cambiar la animación solo si el estado cambió
	if current_state != next_state:
		print("Cambiando estado de ", current_state, " a ", next_state)
		change_state(next_state)
	
	# Lógica de movimiento según el estado
	handle_state_logic(delta)
	
	# Actualizar la dirección del sprite según el movimiento
	update_sprite_direction()

func update_sprite_direction():
	if velocity.x < 0 and velocity.length() > threshold:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0 and velocity.length() > threshold:
		animated_sprite_2d.flip_h = false

func change_state(new_state: int) -> void:
	# Prevenir cambios de estado mientras está herido
	if current_state == DemonState.HURT and is_hurt and (new_state == DemonState.IDLE or new_state == DemonState.ATTACKING):
		print("Intentando cambiar de HURT a ", new_state, " pero sigue herido")
		return
		
	current_state = new_state
	
	print("Ejecutando animación para el estado: ", current_state)
	
	match current_state:
		DemonState.IDLE:
			animated_sprite_2d.play("Idle")
		DemonState.ATTACKING:
			animated_sprite_2d.play("Ataque")
			audioataque.play()
		DemonState.HURT:
			animated_sprite_2d.play("Hit")
			audioerido.play()
		DemonState.DEAD:
			animated_sprite_2d.play("Dead")
			audiomuerte.play()

func handle_state_logic(delta: float) -> void:
	match current_state:
		DemonState.IDLE:
			move_towards_player(delta)
		DemonState.ATTACKING:
			# Mantener velocidad aumentada durante el ataque
			var direction = player_position - position
			if direction.length() > threshold:
				direction = direction.normalized()
				velocity = direction * (speed * 2)
			else:
				velocity = Vector2.ZERO
		DemonState.HURT, DemonState.DEAD:
			# No mover en estos estados
			velocity = Vector2.ZERO
			
	move_and_slide()

func get_PJ_position(pos_x: int, pos_y: int) -> void:
	player_position = Vector2(pos_x, pos_y)

func move_towards_player(delta):
	speed=50
	if current_state == DemonState.HURT or current_state == DemonState.DEAD:
		return
		
	var direction = player_position - position
	if direction.length() > threshold:
		direction = direction.normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

func received_damage(damage: int) -> void:
	print("¡Recibiendo daño! Health antes: ", health)
	if current_state == DemonState.HURT or current_state == DemonState.DEAD:
		print("Ya estaba herido o muerto, ignorando daño")
		return
	is_hurt = true
	damage_received = true  # Marcar que se recibió daño para forzar cambio en _process
	health -= damage
	actualizarvida()
	print("Health después: ", health, " is_hurt: ", is_hurt)
	
	# Efecto de knock-back
	if animated_sprite_2d.flip_h:
		position.x += 30
	else:
		position.x -= 30
	
	# Detener el timer si está activo y reiniciarlo
	timer_hurt.stop()
	timer_hurt.start(0.5)  # Asegurarse de que esta duración sea suficiente para la animación
	
	if health <= 0:
		print("¡Muriendo!")
		$Detection/detector.disabled = true
		position.y -= 1
		dead_timer.start(1.5)
		change_state(DemonState.DEAD)

func _on_hurt_timer_timeout() -> void:
	print("Timer de hurt completado, is_hurt: ", is_hurt)
	is_hurt = false
	print("is_hurt ahora es: ", is_hurt)
	
	# Restaurar siempre a IDLE o ATTACKING después del hurt, nunca a MOVING
	if health > 0:
		print("Restaurando estado después de hurt")
		if is_attacking:
			print("Volviendo a ATTACKING")
			change_state(DemonState.ATTACKING)
		else:
			print("Volviendo a IDLE")
			change_state(DemonState.IDLE)

func _on_detection_timer_timeout() -> void:
	DetectionShape.disabled = not DetectionShape.disabled

func die() -> void:
	print("Función die() ejecutada")
	spawn_drop()
	queue_free()

func spawn_drop() -> void:
	var drop_scene = preload("res://nodos/elementos/heal.tscn")
	var drop_instance = drop_scene.instantiate()
	
	# Configurar posición y propiedades
	drop_instance.global_position = global_position
	get_tree().get_root().add_child(drop_instance)
	
	# Opcional: Aplicar un pequeño impulso
	if drop_instance is RigidBody2D:
		drop_instance.apply_impulse(Vector2(randf_range(-50, 50), randf_range(-100, -50)))

func _on_detection_2_body_entered(body: Node2D) -> void:
	print("Cuerpo entró en rango de ataque")
	if current_state != DemonState.HURT and current_state != DemonState.DEAD:
		is_attacking = true
		change_state(DemonState.ATTACKING)

func _on_detection_2_body_exited(body: Node2D) -> void:
	print("Cuerpo salió del rango de ataque")
	if current_state != DemonState.HURT and current_state != DemonState.DEAD:
		is_attacking = false
		change_state(DemonState.IDLE)  # Siempre volver a IDLE, nunca a MOVING
