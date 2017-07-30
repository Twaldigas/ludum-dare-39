extends RigidBody2D

onready var timer = get_node("Timer")

var is_good = false
var is_bad = false

func _ready():
	timer.connect("timeout", self, "_delete")
	
func _delete():
	self.queue_free()
	
func set_is_good():
	is_good = true

func set_is_bad():
	is_bad = true
	
func is_good():
	return is_good
	
func is_bad():
	return is_bad