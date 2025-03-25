extends Node2D

var damage: int = 10
@onready var mamotreto: Timer = $mamotreto
@onready var range: CollisionShape2D = $damage/range 
@onready var mondongo: Timer = $mondongo
@onready var explosion: AudioStreamPlayer2D = $explosion


func _on_collision_timer_timeout():
	range.disabled = false
func _ready():
	mondongo.wait_time = 0.5
	mondongo.one_shot = true
	mondongo.start()
	mondongo.timeout.connect(_on_collision_timer_timeout)
	mamotreto.wait_time = 1.5
	mamotreto.one_shot = true
	mamotreto.start()
	mamotreto.timeout.connect(_on_mamotreto_timeout)

func _on_mamotreto_timeout():
	queue_free()
func _on_damage_area_entered(area):
	print("Bola du fogo"+ str(area))
	if area.is_in_group("player"):
		var parent = area.get_parent()
		if parent and parent.has_method("received_damage"):
			parent.received_damage(damage)
			print("Bola du fogo ha impactado en el nodo padre del jugador")
		else:
			print("El nodo padre no tiene el método 'received_damage'")
		if area.has_method("received_damage"):
			area.received_damage(damage)
			print("Bola du fogo a impactado en jugador")
		else:
			print("El área no tiene el método 'received_damage'")
	pass 
func set_damage(value: int) -> void:
	damage = value


func _on_mondongo_timeout() -> void:
	range.disabled = false
	explosion.play()
	pass # Replace with function body.
