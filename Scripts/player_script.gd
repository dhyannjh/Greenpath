extends CharacterBody2D

# --- MOVEMENT SETTINGS ---
@export var speed := 100.0
@export var acceleration := 600.0
@export var friction := 1500.0

# --- JUMP SETTINGS ---
@export var jump_velocity := -350.0
@export var fall_gravity_multiplier := 1.0
@export var air_control := 0.7

# --- COYOTE + BUFFER ---
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.05

# --- STATE ---
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var base_velocity = Vector2.ZERO
var knockback_vel = Vector2.ZERO

# --- INPUT CACHE (future AI-ready) ---
var move_input := 0.0
var jump_pressed := false
var jump_released := false
var attack_pressed := false


func _physics_process(delta: float) -> void:
	read_input()
	handle_movement(delta)
	apply_gravity(delta)
	handle_jump(delta)
	
	velocity = base_velocity + knockback_vel
	move_and_slide()


# =========================
# INPUT
# =========================
func read_input():
	move_input = Input.get_axis("left", "right")
	jump_pressed = Input.is_action_just_pressed("jump")
	jump_released = Input.is_action_just_released("jump")
	attack_pressed = Input.is_action_just_pressed("M1")
	
	
# =========================
# MOVEMENT
# =========================
func handle_movement(delta):
	
	var controll = 1
	
	if move_input != 0:
		if is_on_floor():
			base_velocity.x = move_toward(
				base_velocity.x, 
				move_input * speed, acceleration * controll * delta
				)
				
		else:
			base_velocity.x = move_toward(
				base_velocity.x,
				move_input * speed, acceleration * air_control * controll * delta
				)
	else:
		base_velocity.x = move_toward(base_velocity.x, 0, friction * delta)


# =========================
# GRAVITY
# =========================
func apply_gravity(delta):
	if not is_on_floor():
		if base_velocity.y > 0:
			base_velocity.y += global.gravity * fall_gravity_multiplier * delta
		else:
			base_velocity.y += global.gravity * delta
	else:
		base_velocity.y = 0


# =========================
# JUMP
# =========================
func handle_jump(delta):
	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump buffer
	if jump_pressed:
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		base_velocity.y = jump_velocity
		#spawn_burst(0.4)
		jump_buffer_timer = 0
		coyote_timer = 0

	# Short hop
	if jump_released and base_velocity.y < 0:
		base_velocity.y *= 0.5
		
	if is_on_ceiling():
		base_velocity.y = 70
		get_viewport().get_camera_2d().shake(0.7)
