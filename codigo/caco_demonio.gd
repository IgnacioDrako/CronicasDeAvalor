extends CharacterBody2D

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

var health = 50
var is_hurt: bool = false 
var speed = 50.0
var player_position = Vector2()
var threshold = 1.0  # Umbral para evitar vibraciones
var damage = 10

func _ready():
	add_to_group("enemys")
	dead_timer.timeout.connect(die)
	timer_hurt.timeout.connect(_on_hurt_timer_timeout)  # Conectar el temporizador al método
	timer_detection.timeout.connect(_on_detection_timer_timeout)  # Conectar el temporizador de detección al método
	timer_detection.start(0.5)  # Iniciar el temporizador de detección

func _process(delta):
	move_towards_player(delta)

func get_PJ_position(pos_x: int, pos_y: int) -> void:
	player_position = Vector2(pos_x, pos_y)
	#print("Caco demonio ha recibido: ", pos_x, " y ", pos_y)

func move_towards_player(delta):
	if is_hurt or health <= 0:
		return  # No moverse si está herido o muerto
	var direction = player_position - position
	if direction.length() > threshold:
		direction = direction.normalized()
		velocity = direction * speed
		if direction.x < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
	else:
		velocity = Vector2()
	
	move_and_slide()

func received_damage(damage: int) -> void:
	if not is_hurt:  # Solo recibe daño si no está en estado de daño
		is_hurt = true  # Cambia el estado a herido
		health -= damage
		#print("CacoDemonio recibe daño: ", damage)
		#print("Salud restante: ", health)
		speed = 0
		animated_sprite_2d.stop()
		animated_sprite_2d.play("Hit")  # Reproduce la animación de daño
		audioerido.play()
		timer_hurt.start(0.5)  # Inicia el temporizador para la animación de daño
		if animated_sprite_2d.flip_h:
			position.x += 30  # Si está mirando a la izquierda, empuja a la derecha
		else:
			position.x -= 30  # Si está mirando a la derecha, empuja a la izquierda
		if health <= 0:
			$Detection/detector.disabled = true
			speed = 0
			position.y -= 1 
			animated_sprite_2d.stop()
			animated_sprite_2d.play("Dead")
			audiomuerte.play()
			dead_timer.start(1.5)

func _on_hurt_timer_timeout() -> void:
	is_hurt = false  # Permitir que el caco demonio reciba daño nuevamente
	if health > 0:
		animated_sprite_2d.play("Idle")

func _on_detection_timer_timeout() -> void:
	DetectionShape.disabled = not DetectionShape.disabled  # Alternar el estado del CollisionShape2D

func die() -> void:
	queue_free()

func _on_detection_2_body_entered(body: Node2D) -> void:
	if not is_hurt and health > 0:
		print("Detetion 2")
		animated_sprite_2d.stop()
		animated_sprite_2d.play("Ataque")
		audioataque.play()
		speed *= 2

func _on_detection_2_body_exited(body: Node2D) -> void:
	if not is_hurt and health > 0:
		speed = 50
		animated_sprite_2d.stop()
		animated_sprite_2d.play("Idle")
