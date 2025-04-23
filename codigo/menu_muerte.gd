extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Button2.grab_focus()
	$VBoxContainer/Button.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	DemoGlobal.loadgame()
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://nodos/elementos/main_menu.tscn")
	pass # Replace with function body.
