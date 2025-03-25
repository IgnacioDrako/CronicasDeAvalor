extends CharacterBody2D
var heal = 500
var speed = 00
var damage = 10
var max_heal = 500  
@onready var mirar_derecha: RayCast2D = $Derecha
@onready var mirar_izquierda: RayCast2D = $Izquierda
var derecha = true
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_atque_d_2: AnimatedSprite2D = $AnimatedSpriteAtqueD2
@onready var cabeza0: CollisionShape2D = $hitbox/CollisionShape2D
@onready var cabeza1: CollisionShape2D = $hurtbox/CollisionShape2D2
@onready var barravida: TextureProgressBar = $fondoVida/Barravida
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
		cabeza0.position.x = -25
		cabeza1.position.x = -25
	# Si el raycast izquierdo detecta una colisión, cambia a la derecha
	elif mirar_izquierda.is_colliding():
		derecha = true
		speed = abs(speed)  # Mueve a la derecha
		print("Cambiando a derecha")
		animated_sprite_2d.flip_h = false 
		animated_sprite_atque_d_2.flip_h=false 
		cabeza0.position.x = 10
		cabeza1.position.x = 10
		
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
		# Asegura que la vida no baje de 0
		heal = max(0, heal)
		# Actualiza la barra de vida
		actualizarvida()


func actualizarvida():
	# Calcula el porcentaje de vida actual
	var porcentaje_vida = float(heal) / max_heal
	# Asegura que el porcentaje no sea negativo
	porcentaje_vida = max(0.0, porcentaje_vida)
	
	# Actualiza la escala de la barra de vida
	$fondoVida/Barravida.scale.x = porcentaje_vida
