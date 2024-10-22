extends Area2D
class_name HitBoxPJ
#@export var damage: int = 10 set =  set_damage, get = get_damage
var damage = 10
func set_damage(value: int) -> void:
	damage = value

func get_damage() -> int:
	return damage

func _on_body_entered(body: Node) -> void:
	print(body)
