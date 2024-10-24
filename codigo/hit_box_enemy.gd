extends Area2D
class_name HitBoxEnemi
var damage = 10 
func set_damage(value: int) -> void:
	damage = value

func get_damage() -> int:
	return damage

func _on_body_entered(body: Node2D) -> void:
	print("Detecto: ",body," (HistBoxEnemy)")
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	print("salio: ",body,"(HistBoxEnemy)")
	pass # Replace with function body.
