extends Node2D  # Enemigo (dummy)

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp: Label = $Hp
@onready var hurt_timer: Timer = $TimerHurt
var health = 50
var is_hurt: bool = false  # Variable para controlar si el dummy está en estado de daño
var N_hits = 0
func _ready() -> void:
	add_to_group("enemys")
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)  # Conectar el temporizador al método
	connect("area_entered", Callable(self,"_on_area_entered"))
	actualizar_texto_vida()
# Actualizar el texto de vida
func actualizar_texto_vida():
	#$Hp.text = "health: " + str(health)
	$vida2.scale.x = health / 50
# Eliminar el muñeco cuando muere
func die() -> void:
	health=50

# Función para manejar cuando el enemigo recibe daño
func received_damage(damage: int) -> void:
	if not is_hurt:  # Solo recibe daño si no está en estado de daño
		is_hurt = true  # Cambia el estado a herido
		health -= damage
		actualizar_texto_vida()
		print("Dummy recibe daño: ", damage)
		print("Salud restante: ", health)
		match N_hits:
			0: 
				animation_player.play("Hit0")  # Reproduce la animación de daño
				N_hits+=1
				hurt_timer.start(0.5)  # Inicia el temporizador para la animación de daño
			1: 
				animation_player.play("Hit1")
				N_hits+=1
				hurt_timer.start(0.5)  # Inicia el temporizador para la animación de daño
			2: 
				animation_player.play("Hit2")
				N_hits=0
				hurt_timer.start(0.5)  # Inicia el temporizador para la animación de daño
		if health <= 0:
			animation_player.play("Dead")
			die()
# Función que se llama cuando el temporizador de daño se agota
func _on_hurt_timer_timeout() -> void:
	is_hurt = false  # Permitir que el dummy reciba daño nuevamente
	animation_player.stop()
	animation_player.play("idle")  # Volver a "Idle" después del daño
