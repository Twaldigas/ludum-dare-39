extends Node

const MAX_ENERGY = 100
const MAX_DIFFICULTY = 3

var energy = MAX_ENERGY
var light_delta_sum = 0
var bg_start_position_x

var difficulty = 0
var spawn_times = [5, 4, 4, 3]
var shoot_ranges = [Vector2(3, 6), Vector2(3, 3), Vector2(2, 5), Vector2(2, 4)]

var killed_bandits = 0

var bandit_scene = preload("res://scenes/bandit.xml")

onready var energy_timer = get_node("EnergyTimer")
onready var spawn_timer = get_node("SpawnTimer")
onready var diff_timer = get_node("IncDifficultyTimer")
onready var killed_bandits_label = get_node("HUD/KilledBandits")
onready var energy_bar = get_node("HUD/Energy")
onready var loc_light = get_node("Locomotive/Light2D")
onready var bandit_path = get_node("Path2D")
onready var background = get_node("Background")

func _ready():
	set_fixed_process(true)
	
	energy_bar.set_max(MAX_ENERGY)
	energy_timer.connect("timeout", self, "_lower_energy")
	spawn_timer.connect("timeout", self, "_spawn_bandit")
	diff_timer.connect("timeout", self, "_inc_difficulty")
	
	bg_start_position_x = background.get_pos().x
	
func _fixed_process(delta):
	energy_bar.set_value(energy)
	killed_bandits_label.set_text(str(killed_bandits, " Killed Bandits"))
	
	_change_loc_light(delta)
	_move_background(delta)
	
func _lower_energy():
	energy += -1
	if(energy == 0):
		energy_timer.disconnect("timeout", self, "_lower_energy")
		energy_timer.queue_free()

func increase_energy():
	energy += 2
	if(energy > MAX_ENERGY):
		energy = MAX_ENERGY

func _change_loc_light(delta):
	light_delta_sum += delta
	if(light_delta_sum > 0.6):
		if(loc_light.get_energy() == 1):
			loc_light.set_energy(1.5)
		else:
			loc_light.set_energy(1.0)
		light_delta_sum = 0
		
func _move_background(delta):

	var pos = background.get_pos()
	
	if(pos.x == 420):
		print("reset")
		pos.x = 0
	else:
		pos.x += 1
		
	background.set_pos(pos)
		
func _spawn_bandit():
	print("spawn_bandit")
	
	var path = PathFollow2D.new()
	path.set_rotate(false)
	path.set_loop(false)
	path.set_rot(0)
	
	var bandit = bandit_scene.instance()
	bandit.set_shoot_range(shoot_ranges[difficulty])
	
	bandit_path.add_child(path)
	path.add_child(bandit)
	
func _inc_difficulty():
	if(difficulty < MAX_DIFFICULTY):
		difficulty += 1
		spawn_timer.set_wait_time(spawn_times[difficulty])
		print(str("inc. difficulty to ", difficulty))
		
func inc_killed_bandits():
	killed_bandits += 1