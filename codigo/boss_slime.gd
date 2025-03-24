extends CharacterBody2D

enum Boss {IDLE, MOVING, ATTACKING}
var current_state = Boss.MOVING

const SPEED = 100.0

@onready var derecha: RayCast2D = $Derecha
@onready var izquierda: RayCast2D = $Izquierda
var flip_timer: Timer
@onready var animated_sprite_movimiento: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_ataque: AnimatedSprite2D = $AnimatedSpriteAtaque
@onready var hitbox: Area2D = $hitbox2
@onready var collision_shape_2d: CollisionShape2D = $hitbox2/CollisionShape2D

var direction = 1  # 1 para derecha, -1 para izquierda
var can_flip = true

func _ready():
	# Configurar las animaciones iniciales
	animated_sprite_movimiento.play("move")
	
	# Conectar la señal del timer
	flip_timer = Timer.new()
	flip_timer.wait_time = 0.5  # Ajusta este valor según necesites
	flip_timer.one_shot = false
	flip_timer.autostart = false
	add_child(flip_timer)
	flip_timer.timeout.connect(_on_FlipTimer_timeout)
	
	# Asegurarse que los RayCast2D estén habilitados
	if derecha != null:
		derecha.enabled = true
	if izquierda != null:
		izquierda.enabled = true

func _physics_process(delta: float) -> void:
	match current_state:
		Boss.MOVING:
			move_horizontally()
		Boss.ATTACKING:
			handle_attack()
		Boss.IDLE:
			stop_movement()

func move_horizontally() -> void:
	velocity.x = SPEED * direction
	
	# Verificar colisiones con los RayCast2D
	if can_flip:
		if direction > 0 and derecha.is_colliding():  # Moviéndose a la derecha y detecta pared
			flip_direction()
			flip_timer.start()  # Iniciar el temporizador de cooldown
		elif direction < 0 and izquierda.is_colliding():  # Moviéndose a la izquierda y detecta pared
			flip_direction()
			flip_timer.start()  # Iniciar el temporizador de cooldown
	
	move_and_slide()
	update_movement_animation()

func update_movement_animation() -> void:
	if velocity.x != 0:
		animated_sprite_movimiento.play("move")
	else:
		animated_sprite_movimiento.play("idle")

func handle_attack() -> void:
	# Detener movimiento durante el ataque
	velocity.x = 0
	
	# Mostrar animación de ataque
	animated_sprite_movimiento.play("attack")  # Simplificado para usar la misma sprite

func stop_movement() -> void:
	velocity.x = 0
	animated_sprite_movimiento.play("idle")

func flip_direction() -> void:
	direction *= -1
	scale.x *= -1  # Voltea el sprite para que mire en la nueva dirección
	
	# Cambiar dirección del área de ataque si es necesario
	# hitbox.scale.x *= -1  # Comentado porque ya se voltea con el nodo padre
	
	# Opcional: reposicionar ligeramente para evitar que siga colisionando
	position.x += direction * 5
	can_flip = false  # Desactivar la capacidad de voltear temporalmente

func _on_FlipTimer_timeout() -> void:
	can_flip = true  # Permitir voltear nuevamente después del timeout

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Cambiar a estado de ataque cuando se detecta algo en la zona de daño
	if current_state != Boss.ATTACKING:
		current_state = Boss.ATTACKING

func _on_attack_animation_finished() -> void:
	# Volver al estado de movimiento cuando termina la animación de ataque
	current_state = Boss.MOVING

func _on_hitbox_area_entered(area: Area2D) -> void:
	# Lógica cuando el enemigo golpea algo
	pass
