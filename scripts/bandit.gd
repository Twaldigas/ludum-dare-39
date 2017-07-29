extends KinematicBody2D

const WALK_SPEED = 20

onready var anim_sprite = get_node("AnimatedSprite")
onready var area2d = get_node("Area2D")
onready var shoot_timer = get_node("ShootTimer")

var bullet_scene = preload("res://scenes/bullet.xml")

var is_walking = true
var is_shooting = false
var is_dying = false

func _ready():
	set_fixed_process(true)
	
	anim_sprite.connect("finished", self, "_anim_finished")
	area2d.connect("body_enter", self, "_die")
	shoot_timer.connect("timeout", self, "_shoot")
	
func _fixed_process(delta):
		
	if(is_dying == false && is_shooting == false):
		get_parent().set_offset(get_parent().get_offset() + (WALK_SPEED * delta))
	
	_handle_animation()
	
func _die(body):
	if(body.get_name() == "Bullet"):
		body.queue_free()
		is_walking = false
		is_dying = true
		anim_sprite.stop()
		anim_sprite.set_frame(0)
		anim_sprite.set_opacity(0.7)
	
func _shoot():
	is_shooting = true
	is_walking = false
	
	var bullet = bullet_scene.instance()
	var ss = -1.0
	var pos = get_pos() + get_node("Position2D").get_pos() * Vector2(ss, 1.0)
	bullet.set_pos(pos)
	get_parent().add_child(bullet)
	bullet.set_linear_velocity(Vector2(200.0 * ss, 0))
	
	shoot_timer.set_wait_time(rand_range(3, 6))
	shoot_timer.start()
	
func _handle_animation():
	if(is_walking):
		anim_sprite.set_animation("walking")
	elif(is_dying):
		anim_sprite.set_animation("dying")
	elif(is_shooting):
		anim_sprite.set_animation("shooting")
	else:
		anim_sprite.set_animation("idle")
	
	if(anim_sprite.is_playing() == false):
		anim_sprite.play(anim_sprite.get_animation())
		
func _anim_finished():
	if(anim_sprite.get_animation() == "dying"):
		self.queue_free()
	elif(anim_sprite.get_animation() == "shooting"):
		is_shooting = false
		is_walking = true