extends KinematicBody2D

const MAX_HP = 3
const BULLET_DAMAGE = 1
const BULLET_SPEED = 100

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

onready var battle_area = get_tree().get_root().get_node("World/Locomotive/BattleArea")
onready var ladder_top = get_tree().get_root().get_node("World/Locomotive/LadderTop")
onready var ladder_bottom = get_tree().get_root().get_node("World/Locomotive/LadderBottom")
onready var top_one_way = get_tree().get_root().get_node("World/Locomotive/TopOneWay")

var is_walking = false
var is_shooting = false
var is_shoveling = false
var is_invulnerable = false
var is_climbing = false

var can_climb_up = false
var can_climb_down = false
var can_jump = false
var can_shoot = false

var shoot_left = false
var shoot_right = true

func _ready():
	
	anim_sprite.connect("finished", self, "_anim_finished")
	
	battle_area.connect("body_enter", self, "_enter_battle_area")
	battle_area.connect("body_exit", self, "_exit_battle_area")
	ladder_top.connect("body_enter", self, "_on_end_of_ladder")
	ladder_top.connect("body_exit", self, "_not_on_end_of_ladder")
	ladder_bottom.connect("body_enter", self, "_on_start_of_ladder")
	ladder_bottom.connect("body_exit", self, "_not_on_start_of_ladder")
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	if(jump_count == 0):
		_handle_shooting()
	
	if(is_climbing == false && is_shooting == false):
		_handle_movement(delta)
		_handle_shoveling()
	elif(is_climbing):
		_handle_climbing(delta)
	
	if(anim_sprite.is_playing() == false):
		anim_sprite.play(anim_sprite.get_animation())
	
func _handle_damage(damage):
	hp += -damage
	if(hp < 0):
		hp = 0

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
		get_parent().add_child(bullet)
		
		bullet.set_linear_velocity(Vector2(200.0 * ss, 0))
	
func _handle_shoveling():
	pass

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