class_name PlayerCharacter
extends CharacterBody2D

@onready var boing_boing = $BoingBoing

@export var max_stamina = 5.0

const SPEED = 600.0
const JUMP_VELOCITY = -1000.0
const PLAYER_SPEED_MULT = 1.8

const MAX_JUMP_CHARGE_TIME = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_charge_amount = 0
var _flag_no_sprint = false

@onready var stamina = max_stamina

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("player_left", "player_right")
	
	var adjusted_direction = direction
	if stamina > 0 and !_flag_no_sprint:
		var is_sprinting = Input.is_action_pressed("player_sprint")
		if is_sprinting:
			adjusted_direction = direction * (1 + float(is_sprinting) * PLAYER_SPEED_MULT)
			stamina -= delta
			if stamina <= 0:
				_flag_no_sprint = true
		else:
			stamina = min(max_stamina, stamina + delta)
	elif _flag_no_sprint:
		stamina = min(max_stamina, stamina + delta / 2)
		if stamina >= max_stamina:
			_flag_no_sprint = false
	# Handle jump.


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		if direction:
			boing_boing.do_boing(adjusted_direction)
		if Input.is_action_pressed("player_jump"):
			_jump_charge_amount = min(MAX_JUMP_CHARGE_TIME, _jump_charge_amount + delta)
		elif Input.is_action_just_released("player_jump"):
			var jump_factor =  JUMP_VELOCITY * 0.5 + (JUMP_VELOCITY * _jump_charge_amount / MAX_JUMP_CHARGE_TIME) * 0.5
			velocity.y = jump_factor
			velocity.x += direction * jump_factor
			
			_jump_charge_amount = 0
		
	if direction:
		velocity.x = adjusted_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		boing_boing.reset_boing()

	move_and_slide()
