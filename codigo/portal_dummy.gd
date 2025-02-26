extends Node2D


func _on_trigger_area_entered(body):
	#if body.name == "Cuerpo":
	get_tree().change_scene_to_file("res://nodos/Map/debug_boss_map.tscn")
	print(str(DemoGlobal.vidaPj))
	pass # Replace with function body.
