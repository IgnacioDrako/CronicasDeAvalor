extends Area2D
@onready var trasicion_animacion: AnimationPlayer = $ColorRect/cargamapa
@onready var color_rect: ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func siguienteZona():
	color_rect.visible=true
	$ColorRect/AnimationPlayer.play("a")
	await get_tree().create_timer(0.5).timeout  # Espera 1 segundo
	get_tree().change_scene_to_file("res://nodos/Map/zonasegura_0.tscn")
	pass
