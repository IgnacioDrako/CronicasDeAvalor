extends Area2D

@onready var update: Timer = $update

#func _ready():
	#connect("body_entered", self, "_on_body_entered")
	#connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	print("detector ha visto a:")
	print(body)
	print("Código de detección")
	# Verifica que el objeto sea del tipo que esperas (opcional)
	if body.is_in_group("player"): 
		var pos_x = body.position.x
		var pos_y = body.position.y
		print("Posición del objeto dentro del área: ", pos_x, pos_y)
		get_parent().get_PJ_position(pos_x, pos_y)

func _on_body_exited(body):
	print("detector ha visto a:")
	#print(body)
	print("Código de detección")
	 #Verifica que el objeto sea del tipo que esperas (opcional)
	if body.is_in_group("player"): 
		var pos_x = body.position.x
		var pos_y = body.position.y
		#print("Posición del objeto dentro del área: ", pos_x, pos_y)
		get_parent().get_PJ_position(pos_x, pos_y)
	#print("Un objeto salió del área.")
