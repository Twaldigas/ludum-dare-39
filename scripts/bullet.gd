extends RigidBody2D

onready var timer = get_node("Timer")

func _ready():
	timer.connect("timeout", self, "_delete")
	
func _delete():
	self.queue_free()