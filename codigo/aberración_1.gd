extends CharacterBody2D

var velocidad = Vector2(50, 0)
var derecha = true
var atacando = false  # Variable para controlar si el enemigo está atacando
var is_hurt = false
var vida = 50

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

func _ready() -> void:
	cajaataque.disabled = true
	mirar_derecha.enabled = true
	mirar_izquierda.enabled = true
	timer.connect("timeout", Callable(self, "_on_ataque_timeout"))  # Conectamos el evento de timeout del ataque
	hit_box.connect("area_entered", Callable(self, "_on_hit_box_area_entered"))  # Verificar si el pj está en el área de ataque

func _physics_process(delta: float) -> void:
	mirar_suelo()
	if not atacando and not is_hurt:  # Solo mueve si no está atacando ni herido
		mover(delta)

func mover(delta: float) -> void:
	if atacando or is_hurt:
		# No se mueve durante el ataque o si está herido
		return
	sprite.play("move")
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
	if body.name == "hurtbox": 
		ataque()
	pass

func _on_hit_box_area_entered(area: Area2D) -> void:
	print("Debug hitbox")
	if area.name == "hurtbox": 
		print("Debug hitbox, pj")
		ataque()

	pass

func ataque() -> void:
	atacando = true  # Activamos el estado de ataque
	sprite.stop()
	sprite.play("Ataque")
	audio_da_o.play()
	velocidad = Vector2(0, 0)  # Detenemos la velocidad
	velocity = Vector2(0, 0)  # Detenemos el movimiento
	move_and_slide()  # Asegura que la entidad no se mueva mientras ataca
	timer.start(1.0)  # Inicia el ataque, que durará 1 segundo 
	vision.disabled = true
	await get_tree().create_timer(0.5).timeout
	cajaataque.disabled  = false
	pass

func _on_ataque_timeout() -> void:
	# Cuando el ataque termina, desactivamos el estado de ataque
	atacando = false
	vision.disabled = false
	cajaataque.disabled = true
	# Ahora el enemigo puede volver a moverse
	sprite.play("move")  # Se puede reiniciar la animación de movimiento si lo deseas

func _on_mirarespalda_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		if derecha:
			derecha = false
		else:
			derecha = true
	pass

func received_damage(damage: int) -> void:
	if not is_hurt:  # Solo recibe daño si no está en estado de daño
		is_hurt = true  # Cambia el estado a herido
		vida -= damage
		velocidad = Vector2(0, 0)
		sprite.stop()
		sprite.play("Hit")  # Reproduce la animación de daño
		audio_erido.play()
		await get_tree().create_timer(0.5).timeout
		if vida <= 0:
			$DetectoPJ/visión.disabled = true
			velocidad = Vector2(0, 0)
			velocity = Vector2(0, 0)
			move_and_slide()
			sprite.stop()
			sprite.play("dead")
			audio_muerte.play()
			atacando = true
			await get_tree().create_timer(1.5).timeout
			queue_free()  # "muere"
		else:
			is_hurt = false  # Permitir que el enemigo reciba daño nuevamente
			sprite.play("move")
			velocidad = Vector2(50, 0)
			move_and_slide()
	pass
