extends Node



func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if(Input.is_action_pressed("ui_cancel")):
		get_tree().change_scene("res://scenes/menu.xml")