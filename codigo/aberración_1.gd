extends CharacterBody2D

# Máquina de estados para la aberración
enum EnemyState {MOVING, ATTACKING, HURT, DEAD}
var current_state = EnemyState.MOVING

var velocidad = Vector2(50, 0)
var derecha = true
var atacando = false
var is_hurt = false
var heal = 50
var max_heal = 50

@onready var mirar_izquierda: RayCast2D = $mirarIzquierda
@onready var mirar_derecha: RayCast2D = $mirarDerecha  
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box: Area2D = $hit_Box
@onready var cajaataque: CollisionShape2D = $hit_Box/ataque
@onready var vision: CollisionShape2D = $"DetectoPJ/visión"
@onready var hurt_box: Area2D = $hurt_box
@onready var detecto_pj: Area2D = $DetectoPJ 
@onready var timer: Timer = $Ataque  
@onready var buscar: Timer = $Buscar  
@onready var mirarespalda: Area2D = $mirarespalda
@onready var audio_da_o: AudioStreamPlayer2D = $AudioDaño
@onready var audio_erido: AudioStreamPlayer2D = $AudioErido
@onready var audio_muerte: AudioStreamPlayer2D = $AudioMuerte
@onready var barravida: TextureProgressBar = $Barravida0/vida

func _ready() -> void:
	max_heal = heal
	#actualizarheal()
	cajaataque.disabled = true
	mirar_derecha.enabled = true
	mirar_izquierda.enabled = true
	timer.connect("timeout", Callable(self, "_on_ataque_timeout"))
	hit_box.connect("area_entered", Callable(self, "_on_hit_box_area_entered"))
func actualizarheal() -> void:
	# Calcula el porcentaje de vida actual
	var porcentaje_vida = float(heal) / max_heal
	# Asegura que el porcentaje no sea negativo
	porcentaje_vida = max(0.0, porcentaje_vida)
	# Actualiza la escala de la barra de vida
	barravida.scale.x = porcentaje_vida
func _physics_process(delta: float) -> void:
	mirar_suelo()
	
	# Determinar el próximo estado
	var next_state = current_state
	
	if heal <= 0:
		next_state = EnemyState.DEAD
	elif is_hurt:
		next_state = EnemyState.HURT
	elif atacando:
		next_state = EnemyState.ATTACKING
	else:
		next_state = EnemyState.MOVING
	
	# Cambiar la animación solo si el estado cambió
	if current_state != next_state:
		change_state(next_state)
	
	# Lógica de movimiento según el estado
	handle_state_logic(delta)

func change_state(new_state: int) -> void:
	current_state = new_state
	
	match current_state:
		EnemyState.MOVING:
			sprite.play("move")
		EnemyState.ATTACKING:
			sprite.play("Ataque")
			audio_da_o.play()
		EnemyState.HURT:
			sprite.play("Hit")
			audio_erido.play()
		EnemyState.DEAD:
			sprite.play("dead")
			audio_muerte.play()

func handle_state_logic(delta: float) -> void:
	match current_state:
		EnemyState.MOVING:
			mover(delta)
		EnemyState.ATTACKING:
			# No hacer nada, esperar a que termine la animación
			pass
		EnemyState.HURT:
			# No hacer nada, esperar a que termine la animación
			pass
		EnemyState.DEAD:
			# No hacer nada, esperar a que se elimine
			pass

func mover(delta: float) -> void:
	if current_state != EnemyState.MOVING:
		return
		
	if derecha:
		hit_box.position.x = 20
		velocidad.x = 50
		sprite.flip_h = true
		detecto_pj.position.x = 20
		mirarespalda.position.x = -30
	else:
		hit_box.position.x = -20
		velocidad.x = -50
		sprite.flip_h = false
		detecto_pj.position.x = -20
		mirarespalda.position.x = 30

	velocity = velocidad
	move_and_slide()

func mirar_suelo() -> void:
	# Cambia de dirección si no hay colisión en el rayo correspondiente
	if derecha and not mirar_derecha.is_colliding():
		derecha = false
	elif not derecha and not mirar_izquierda.is_colliding():
		derecha = true
	# Si ambos rayos dejan de colisionar, la entidad se detiene
	if not mirar_derecha.is_colliding() and not mirar_izquierda.is_colliding():
		velocidad.x = 0

func _on_detecto_pj_area_entered(body) -> void:
	if body.name == "hurtbox" and current_state == EnemyState.MOVING:
		ataque()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox" and current_state == EnemyState.MOVING:
		ataque()

func ataque() -> void:
	if current_state != EnemyState.MOVING:
		return
		
	atacando = true
	velocidad = Vector2(0, 0)
	velocity = Vector2(0, 0)
	move_and_slide()
	timer.start(1.0)
	vision.disabled = true
	
	change_state(EnemyState.ATTACKING)
	
	await get_tree().create_timer(0.5).timeout
	cajaataque.disabled = false

func _on_ataque_timeout() -> void:
	atacando = false
	vision.disabled = false
	cajaataque.disabled = true
	
	if current_state == EnemyState.ATTACKING and heal > 0:
		change_state(EnemyState.MOVING)

func _on_mirarespalda_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		derecha = !derecha

func received_damage(damage: int) -> void:
	if current_state == EnemyState.HURT or current_state == EnemyState.DEAD:
		return
	is_hurt = true
	heal -= damage
	actualizarheal()
	velocidad = Vector2(0, 0)
	velocity = Vector2(0, 0)
	move_and_slide()
	change_state(EnemyState.HURT)
	
	await get_tree().create_timer(0.5).timeout
	
	if heal <= 0:
		die()
	else:
		is_hurt = false
		if current_state == EnemyState.HURT:
			change_state(EnemyState.MOVING)

func die():
	$DetectoPJ/visión.disabled = true
	velocidad = Vector2(0, 0)
	velocity = Vector2(0, 0)
	move_and_slide()
	atacando = true
	
	change_state(EnemyState.DEAD)
	
	await get_tree().create_timer(1.5).timeout
	
	spawn_drop()
	queue_free()

func spawn_drop():
	var drop_scene = preload("res://nodos/elementos/heal.tscn")
	var drop_instance = drop_scene.instantiate()
	
	# Configurar posición y propiedades
	drop_instance.global_position = global_position
	get_tree().get_root().add_child(drop_instance)
	# Opcional: Aplicar un pequeño impulso
	if drop_instance is RigidBody2D:
		drop_instance.apply_impulse(Vector2(randf_range(-50, 50), randf_range(-100, -50)))
