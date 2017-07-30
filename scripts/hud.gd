extends CanvasLayer

var hp_textures = []

onready var player = get_tree().get_root().get_node("World/Player")
onready var hp = get_node("HP")

func _ready():
	set_fixed_process(true)
	
	hp_textures.append(load("res://assets/textures/hp_0.tex"))
	hp_textures.append(load("res://assets/textures/hp_1.tex"))
	hp_textures.append(load("res://assets/textures/hp_2.tex"))
	hp_textures.append(load("res://assets/textures/hp_3.tex"))

func _fixed_process(delta):
	var player_hp = player.get_hp()
	hp.set_texture(hp_textures[player_hp])