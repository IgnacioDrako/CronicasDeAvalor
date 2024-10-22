extends Node2D
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp: Label = $Hp
@onready var hurt_timer: Timer = $TimerHurt 
var health = 100
var is_hurt: bool = false  # Variable para controlar si el dummy está en estado de daño
var dano: bool = false
func _ready() -> void:
	add_to_group("enemys")
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)  # Conectar el temporizador al método de tiempo agotado
	actualizar_texto_vida()

# Actualizar el texto de vida
func actualizar_texto_vida():
	$Hp.text = "health: " + str(health)

# Eliminar el muñeco cuando muere
func die() -> void:
	queue_free()  # Eliminar el muñeco de la escena

# Función para manejar cuando el enemigo recibe daño
func received_damage(damage: int) -> void:
	if not is_hurt:  # Solo recibe daño si no está en estado de daño
		is_hurt = true  # Cambia el estado a herido para evitar múltiples golpes
		health -= damage
		actualizar_texto_vida()
		print("Dummy recibe daño: ", damage)
		print("Salud restante: ", health)
		animation_player.play("Hit0")  # Reproduce la animación de daño
		hurt_timer.start(0.5)  # Inicia el temporizador de 1 segundo para la animación de daño
		if health <= 0:
			animation_player.play("Dead")
			die()
# Función que se llama cuando el temporizador de daño se agota
func _on_hurt_timer_timeout() -> void:
	is_hurt = false  # Permitir que el dummy reciba daño nuevamente
	animation_player.play("Idle")  # Detener la animación de daño y volver a "Idle" después de 1 segundo
func _on_area_2d_body_entered(body) -> void:
	print(body)
	received_damage(10)
	pass # Replace with function body.