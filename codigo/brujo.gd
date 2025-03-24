extends CharacterBody2D

enum BrujoState {IDLE, CASTING, HURT, DEAD}

@onready var hurt_box: CollisionShape2D = $body/HurtBox
@onready var spellrange: CollisionShape2D = $Detection/Spellrange
@onready var cuerpo: CollisionShape2D = $cuerpo
@onready var detetion: Timer = $detetion
@onready var casteo: Timer = $casteo
@onready var hurt: Timer = $hurt
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var espera: Timer = $espera

var health = 50
var is_hurt: bool = false
var player_position = Vector2()
var damage = 10
var is_attacking: bool = false
var damage_received: bool = false
var current_state = BrujoState.IDLE

func change_state(new_state: BrujoState) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	
	match current_state:
		BrujoState.IDLE:
			animated_sprite_2d.play("idle")
		BrujoState.CASTING:
			animated_sprite_2d.play("atack")
			is_attacking = true
		BrujoState.HURT:
			animated_sprite_2d.play("hurt")
			is_hurt = true
		BrujoState.DEAD:
			animated_sprite_2d.play("dead")
			# Desactiva colisiones y otras funciones cuando está muerto
			hurt_box.set_deferred("disabled", true)
			cuerpo.set_deferred("disabled", true)

func _ready():
	detetion.timeout.connect(_toggle_spellrange)
	hurt.timeout.connect(_on_hurt_timer_timeout)
	casteo.timeout.connect(_on_detection_timer_timeout)
	detetion.start(1.0)
	
	# Iniciar en estado IDLE
	change_state(BrujoState.IDLE)

func _process(delta):
	# Lógica de estado en el process
	match current_state:
		BrujoState.IDLE:
			# Comportamiento en estado IDLE
			pass
		BrujoState.CASTING:
			# Comportamiento en estado CASTING
			pass
		BrujoState.HURT:
			# Comportamiento en estado HURT
			pass
		BrujoState.DEAD:
			# Comportamiento en estado DEAD
			pass

func take_damage(amount):
	if current_state == BrujoState.DEAD:
		return
	health -= amount
	if health <= 0:
		change_state(BrujoState.DEAD)
	else:
		change_state(BrujoState.HURT)
		hurt.start(1.0)  # Duración de la animación de daño

func _toggle_spellrange():
	spellrange.disabled = not spellrange.disabled

func _on_hurt_timer_timeout():
	is_hurt = false
	if current_state == BrujoState.HURT:
		change_state(BrujoState.IDLE)
	
func get_pj_position(pos_x: int, pos_y: int) -> void:
	player_position = Vector2(pos_x, pos_y)
	
func _on_detection_timer_timeout():
	if spellrange.disabled == false:
		casteo.start()

func _on_detection_area_entered(area: Area2D) -> void:
	print("Brujo: Area entered")
	if area.is_in_group("player") and area.is_in_group("pjhurtbox") and current_state != BrujoState.DEAD:
		print("Brujo: Player detected")
		get_pj_position(area.global_position.x, area.global_position.y)
		change_state(BrujoState.CASTING)
		summon_spel("res://nodos/elementos/fireball.tscn", player_position)
		espera.start(1.5)

func summon_spel(scene_path: String, position: Vector2) -> void:
	var scene = preload("res://nodos/elementos/fireball.tscn")
	var instance = scene.instantiate()
	get_parent().add_child(instance)
	instance.global_position = position

func _on_espera_timeout() -> void:
	if current_state == BrujoState.CASTING:
		change_state(BrujoState.IDLE)
		is_attacking = false

func received_damage(damage: int) -> void:
	print("¡Recibiendo daño! Health antes: ", health)
	health -= damage
	if health <= 0:
		print("¡Muriendo!")
		change_state(BrujoState.DEAD)
	else:
		change_state(BrujoState.HURT)
		hurt.start(1.0)  # Duración de la animación de daño
	pass
