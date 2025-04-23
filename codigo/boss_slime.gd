extends CharacterBody2D
var heal = 100
var speed = 0
var damage = 10
var max_heal = 100
@onready var mirar_derecha: RayCast2D = $Derecha
@onready var mirar_izquierda: RayCast2D = $Izquierda
var derecha = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_atque_d_2: AnimatedSprite2D = $AnimatedSpriteAtqueD2
@onready var cabeza0: CollisionShape2D = $hitbox/CollisionShape2D
@onready var cabeza1: CollisionShape2D = $hurtbox/CollisionShape2D2
@onready var barravida: TextureProgressBar = $fondoVida/Barravida
@onready var detection: CollisionShape2D = $detection/CollisionShape2D
@onready var coso: Timer = $coso
@onready var muerte_estatico: Sprite2D = $muerteEstatico
@onready var cuerpo1: CollisionShape2D = $hitbox/CollisionShape2D2
@onready var cuerpo0: CollisionShape2D = $hurtbox/CollisionShape2D



func _ready() -> void:
	# Establece el valor máximo de vida al inicio
	max_heal = heal
	actualizarvida()
func cambiar_direccion() -> void:
	# Si el raycast derecho detecta una colisión, cambia a la izquierda
	if mirar_derecha.is_colliding():
		derecha = false
		speed = -abs(speed)  # Mueve a la izquierda
		print("Cambiando a izquierda")
		animated_sprite_2d.flip_h = true
		animated_sprite_atque_d_2.flip_h = true
		muerte_estatico.flip_h=true
		animated_sprite_atque_d_2.position.x = -60
		cabeza0.position.x = -25
		cabeza1.position.x = -25
		detection.position.x = -50
	# Si el raycast izquierdo detecta una colisión, cambia a la derecha
	elif mirar_izquierda.is_colliding():
		derecha = true
		speed = abs(speed)  # Mueve a la derecha
		print("Cambiando a derecha")
		animated_sprite_2d.flip_h = false 
		animated_sprite_atque_d_2.flip_h=false 
		muerte_estatico.flip_h=false
		cabeza0.position.x = 10
		cabeza1.position.x = 10
		detection.position.x = 50
		animated_sprite_atque_d_2.position.x = 68

		
func _physics_process(delta: float) -> void:
	cambiar_direccion()
	velocity.x = speed
	move_and_slide()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.is_in_group("pjhurtbox"):
		var parent = area.get_parent()
		parent.received_damage(damage)
		print("Slime a tocado jugador")
		pass
	pass # Replace with function body.
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.is_in_group("pjataque"):
		print("Daño al boss " + str(heal))
		# Reduce la vida en 10 puntos
		heal -= 10
		$"Daño".play()
		# Asegura que la vida no baje de 0
		heal = max(0, heal)
		# Actualiza la barra de vida
		actualizarvida()
		if heal<= 0:
			muerte()


func actualizarvida():
	# Calcula el porcentaje de vida actual
	var porcentaje_vida = float(heal) / max_heal
	# Asegura que el porcentaje no sea negativo
	porcentaje_vida = max(0.0, porcentaje_vida)
	
	# Actualiza la escala de la barra de vida
	barravida.scale.x = porcentaje_vida


func _on_detection_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("Jugador detectado")
		if heal <=35:
			speed = 0
			animated_sprite_2d.visible=false
			animated_sprite_atque_d_2.visible = true
			animated_sprite_atque_d_2.play("attack")
			var parent = area.get_parent()
			parent.received_damage(25)
			coso.start(1)
			$Ataque.play()
		else:
			#👍
			pass
		pass
	pass # Replace with function body.


func _on_coso_timeout() -> void:
	animated_sprite_2d.visible=true
	animated_sprite_atque_d_2.visible=false
	if derecha:
		speed = 300
	else:
		speed = -300
	pass # Replace with function body.
func muerte():
	$AnimatedSprite2D.play("dead")
	speed=0
	$hurtbox.monitorable=false
	$hitbox.monitorable=false
	cabeza0.disabled=true
	cabeza1.disabled=true
	cuerpo0.disabled=true
	cuerpo1.disabled=true
	animated_sprite_2d.visible=false
	animated_sprite_atque_d_2.visible=false
	muerte_estatico.visible=true
	detection.disabled=true
	barravida.visible=false
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 100, 2.0).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate:a", 0, 1.5)
	tween.tween_callback(queue_free)
	$ColorRect/AnimationPlayer.play("fin")
	$Muerte.play()
	get_parent()._fin_demo()
	pass
