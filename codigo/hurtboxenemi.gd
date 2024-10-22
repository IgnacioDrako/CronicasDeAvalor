extends Area2D
signal received_damage(damage: int)  

#@export var health: Health
func _ready():
	connect("area_entered", _on_area_entered)  

func _on_area_entered(hitbox: HitBoxPJ) -> void:  
	print(hitbox) 
	if hitbox != null:
		#health.health -= hitbox.damage
		received_damage.emit(hitbox.damage)  
		print("hit")
		print(hitbox.damage)
