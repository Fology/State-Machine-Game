extends Node2D

func _ready():
	pass


func _input(event):
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()



