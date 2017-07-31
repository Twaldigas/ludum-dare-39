extends Node

onready var start_button = get_node("CanvasLayer/Start")
onready var credits_button = get_node("CanvasLayer/Credits")
onready var exit_button = get_node("CanvasLayer/Exit")
onready var music_toggle = get_node("CanvasLayer/MusicToggle")

func _ready():
	start_button.connect("pressed", self, "_start_game")
	credits_button.connect("pressed", self, "_show_credits")
	exit_button.connect("pressed", self, "_exit_game")
	music_toggle.connect("toggled", self, "_music_toggled")
	
	if(global.music):
		music_toggle.set_pressed(true)
	else:
		music_toggle.set_pressed(false)

func _start_game():
	get_tree().change_scene("res://scenes/world.xml")
	
func _show_credits():
	get_tree().change_scene("res://scenes/credits.xml")
	
func _exit_game():
	get_tree().quit()
	
func _music_toggled(pressed):
	global.music = pressed