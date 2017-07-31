extends Node

const POINTS_PER_BANDIT = 100
const POINTS_PER_ENERGY = 20

onready var killed_bandits_score = get_node("CanvasLayer/KilledBanditsScore")
onready var energy_left_score = get_node("CanvasLayer/EnergyLeftScore")
onready var highscore = get_node("CanvasLayer/Highscore")
onready var lost_reason = get_node("CanvasLayer/LostReason")

func _ready():
	set_fixed_process(true)
	
	var bandits_score = global.bandits_killed * POINTS_PER_BANDIT
	var energy_score = global.energy_left * POINTS_PER_ENERGY
	var score_total = bandits_score + energy_score
	
	lost_reason.set_text(global.lost_reason)
	killed_bandits_score.set_text(str(global.bandits_killed, "x ", POINTS_PER_BANDIT, " = ", bandits_score))
	energy_left_score.set_text(str(global.energy_left, "% x ", POINTS_PER_ENERGY, " = ", energy_score))
	
	highscore.set_text(str(score_total))

func _fixed_process(delta):
	if(Input.is_action_pressed("ui_accept")):
		global.bandits_killed = 0
		global.energy_left = 0
		global.lost_reason = ""
		get_tree().change_scene("res://scenes/world.xml")
	elif(Input.is_action_pressed("ui_cancel")):
		get_tree().change_scene("res://scenes/menu.xml")