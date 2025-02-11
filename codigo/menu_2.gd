extends Control

func resume():
	get_tree().paused = false
func pause():
	get_tree().pause=true

func testEsc():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif  Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()
		


func _on_coninue_pressed() -> void:
	resume()
	pass # Replace with function body.
