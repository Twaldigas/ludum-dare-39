extends KinematicBody2D

const MAX_HP = 3

const WALK_SPEED = 100
const JUMP_FORCE = 400
const CLIMB_FORCE = 100
const MAX_JUMP_COUNT = 1
const GRAVITY = 2000.0

var hp = MAX_HP
var jump_count = 0
var velocity = Vector2()
var direction = ""
var bullet_scene = preload("res://scenes/bullet.xml")

onready var anim_sprite = get_node("AnimatedSprite")
onready var area2d = get_node("Area2D")
onready var hitTimer = get_node("HitTimer")

onready var world = get_tree().get_root().get_node("World")
onready var battle_area = get_tree().get_root().get_node("World/Locomotive/BattleArea")
onready var ladder_top = get_tree().get_root().get_node("World/Locomotive/LadderTop")
onready var ladder_bottom = get_tree().get_root().get_node("World/Locomotive/LadderBottom")
onready var top_one_way = get_tree().get_root().get_node("World/Locomotive/TopOneWay")
onready var shovel_area = get_tree().get_root().get_node("World/Locomotive/ShovelArea")

var is_walking = false
var is_shooting = false
var is_shoveling = false
var is_invulnerable = false
var is_climbing = false
var is_dying = false

var can_climb_up = false
var can_climb_down = false
var can_jump = false
var can_shoot = false
var can_shovel = true

var shoot_left = false
var shoot_right = true

func _ready():
	set_fixed_process(true)
	
	anim_sprite.connect("finished", self, "_anim_finished")
	area2d.connect("body_enter", self, "_got_hit")
	hitTimer.connect("timeout", self, "_not_invulnerable")
	
	battle_area.connect("body_enter", self, "_enter_battle_area")
	battle_area.connect("body_exit", self, "_exit_battle_area")
	ladder_top.connect("body_enter", self, "_on_end_of_ladder")
	ladder_top.connect("body_exit", self, "_not_on_end_of_ladder")
	ladder_bottom.connect("body_enter", self, "_on_start_of_ladder")
	ladder_bottom.connect("body_exit", self, "_not_on_start_of_ladder")
	shovel_area.connect("body_enter", self, "_enter_shovel_area")
	shovel_area.connect("body_exit", self, "_exit_shovel_area")
	
func _fixed_process(delta):
	
	_handle_dead()
	if(is_dying == false):
	
		if(jump_count == 0):
			_handle_shooting()
			
		if(can_shovel):
			_handle_shoveling()
		
		if(is_climbing == false && is_shooting == false && is_shoveling == false):
			_handle_movement(delta)
		elif(is_climbing):
			_handle_climbing(delta)
		
	if(anim_sprite.is_playing() == false):
		anim_sprite.play(anim_sprite.get_animation())
		
	if(is_invulnerable):
		anim_sprite.set_opacity(0.7)
	else:
		anim_sprite.set_opacity(1.0)
	
func _handle_movement(delta):
	
	velocity.y += delta * GRAVITY
	
	# Stand, walk left or right and climbing
	
	if(Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
		anim_sprite.set_flip_h(true)
		anim_sprite.set_animation("walking")
		shoot_left = true
		shoot_right = false
	elif(Input.is_action_pressed("ui_right")):
		velocity.x = WALK_SPEED
		anim_sprite.set_flip_h(false)
		anim_sprite.set_animation("walking")
		shoot_right = true
		shoot_left = false
	elif(can_climb_up && Input.is_action_pressed("ui_up")):
		_climb_up()
	elif(can_climb_down && Input.is_action_pressed("ui_down")):
		_climb_down()
	else:
		velocity.x = 0
		anim_sprite.set_animation("idle")
	
	# Jump
	
	if(Input.is_action_pressed("ui_up") && jump_count < MAX_JUMP_COUNT && can_jump):
		velocity.y = -JUMP_FORCE
		jump_count += 1
	
	var motion = velocity * delta
	motion = move(motion)
	
	if(is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
		if(n == Vector2(0, -1)):
			jump_count = 0
	
func _handle_shooting():
	
	if(can_shoot && is_shooting == false && Input.is_action_pressed("ui_accept")):
		is_shooting = true
		anim_sprite.stop()
		anim_sprite.set_frame(0)
		anim_sprite.set_animation("shooting")
		
		var bullet = bullet_scene.instance()
		var ss
		#if (siding_left):
		if(shoot_left):
			ss = -1.0
		else:
			ss = 1.0
		var pos = get_pos() + get_node("Position2D").get_pos() * Vector2(ss, 1.0)
		
		bullet.set_pos(pos)
		bullet.set_is_good()
		get_parent().add_child(bullet)
		
		bullet.set_linear_velocity(Vector2(200.0 * ss, 0))
	
func _handle_shoveling():
	if(is_shoveling == false && Input.is_action_pressed("ui_accept")):
		is_shoveling = true
		anim_sprite.stop()
		anim_sprite.set_frame(0)
		anim_sprite.set_animation("shoveling")
		anim_sprite.set_flip_h(false)
		world.increase_energy()

func _handle_climbing(delta):
	
	velocity.y += delta * GRAVITY
	velocity.y = -CLIMB_FORCE
	
	if(direction == "up"):
		velocity.y = -CLIMB_FORCE
		top_one_way.set_one_way_collision_direction(Vector2(0, 1))
	elif(direction == "down"):
		velocity.y = CLIMB_FORCE
		top_one_way.set_one_way_collision_direction(Vector2(0, -1))
	
	anim_sprite.set_animation("climbing")
	
	var motion = velocity * delta
	move(motion)

func _enter_battle_area(body):
	if(body.get_name() == self.get_name()):
		can_jump = true
		can_shoot = true

func _exit_battle_area(body):
	if(body.get_name() == self.get_name()):
		can_jump = false
		can_shoot = false

func _on_start_of_ladder(body):
	if(body.get_name() == self.get_name()):
		can_climb_up = true
		if(is_climbing == true):
			is_climbing = false
	
func _not_on_start_of_ladder(body):
	if(body.get_name() == self.get_name()):
		can_climb_up = false
		top_one_way.set_one_way_collision_direction(Vector2(0, 0))
		
func _on_end_of_ladder(body):
	if(body.get_name() == self.get_name()):
		can_climb_down = true
		if(is_climbing == true):
			is_climbing = false
	
func _not_on_end_of_ladder(body):
	if(body.get_name() == self.get_name()):
		can_climb_down = false
		top_one_way.set_one_way_collision_direction(Vector2(0, 0))
		
func _enter_shovel_area(body):
	if(body.get_name() == self.get_name()):
		can_shovel = true
		
func _exit_shovel_area(body):
	if(body.get_name() == self.get_name()):
		can_shovel = false
		
func _climb_up():
	is_climbing = true
	direction = "up"
	velocity.x = 0
	
func _climb_down():
	is_climbing = true
	direction = "down"
	velocity.x = 0
	
func _anim_finished():
	if(anim_sprite.get_animation() == "shooting"):
		is_shooting = false
	elif(anim_sprite.get_animation() == "dying"):
		print("dead")
	elif(anim_sprite.get_animation() == "shoveling"):
		is_shoveling = false
		
func _got_hit(body):
	if(body.get_name() == "Bullet" && is_invulnerable == false):
		if(body.is_bad()):
			body.queue_free()
			hp += -1
			if(hp < 0):
				hp = 0
	
			is_invulnerable = true
			hitTimer.start()

func _not_invulnerable():
	is_invulnerable = false

func _handle_dead():
	if(hp == 0):
		is_dying = true
		anim_sprite.set_animation("dying")
		hitTimer.stop()
	
func get_hp():
	return hp