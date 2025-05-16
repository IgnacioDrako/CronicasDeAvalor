extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Button2.grab_focus()
	$VBoxContainer/Button.grab_focus()
	$VBoxContainer/Button.pressed.connect(_on_button_pressed)
	$VBoxContainer/Button2.pressed.connect(_on_button_2_pressed)
	visible = false
	pass # Replace with function body.

func mostrar():
	visible = true
	$VBoxContainer/Button.grab_focus()
	pass

func _on_button_pressed() -> void:
	visible = false
	DemoGlobal.vidaPj += 100
	DemoGlobal.loadgame()
	get_tree().change_scene_to_file(DemoGlobal.current_scene)
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://nodos/elementos/main_menu.tscn")
	pass # Replace with function body.
