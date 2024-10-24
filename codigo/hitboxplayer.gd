extends Area2D
class_name HitBoxPJ
var damage = 10
func set_damage(value: int) -> void:
	damage = value

func get_damage() -> int:
	return damage

func _on_body_entered(body: Node) -> void:
	#print(body)
	pass
