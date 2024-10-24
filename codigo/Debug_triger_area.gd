extends Area2D
func _ready():
	connect("area_exited",_on_body_exited) 
	
func _on_triger_area_body_entered(body: Node2D) -> void:
	print("Debug area entrer")
	print(body)
	pass # Replace with function body.

func _on_body_exited(hitbox: HitBoxPJ) -> void:  
	print("Debug area exited")
	print(hitbox) 
	if hitbox != null:
		#health.health -= hitbox.damage
		#received_damage.emit(hitbox.damage)  
		print("hit detro de codigo Area debug")
		print(hitbox.damage)
	else:
		print("null")
