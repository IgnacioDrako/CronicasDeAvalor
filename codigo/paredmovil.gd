extends Node2D

#var velocidad = 305
#var direccion = Vector2(0, 1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("mover")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position.x += velocidad * delta
	#velocidad += 0.02
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var pater = area.get_parent()
		pater.received_damage(500)
		pass
	pass # Replace with function body.

	
