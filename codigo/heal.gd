extends RigidBody2D
func _ready() -> void:
	add_to_group("Heal")
func _on_area_2d_area_entered(area):
	print("vida esta viendo al area "+str(area))
	if area.is_in_group("player"):
		print("es el jugador")
		area.get_parent().heal(10)
		queue_free()
	pass # Replace with function body.
