extends CharacterBody2D


@export var SPEED : float
@export var DECCEL : float
@export var JUMP_VELOCITY : float
@export var CHARGE_VELOCITY : float

@onready var hitbox = $HitBoxArea/HitBox
@onready var charge_timer = $ChargeTimer
@onready var charge_cooldown_timer = $ChargeCooldownTimer

var _can_charge = true

enum PlayerState{CHILL, CHARGE, HOLDING, STUNNED}
var state : PlayerState = PlayerState.CHILL

var _facing : Game.Direction = Game.Direction.RIGHT


func _physics_process(delta: float) -> void:
	
	# Add the gravity.  This always happens.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Check if the player is stunnned, they should not be able to do things
	if state == PlayerState.STUNNED:
		velocity.x = move_toward(velocity.x, 0, DECCEL)
	else:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		
		if Input.is_action_just_pressed("action"):
			if state == PlayerState.CHILL or state == PlayerState.CHARGE:
				_handle_charge_action()
			elif state == PlayerState.HOLDING:
				_handle_throw_action()
		
		var direction := Input.get_axis("left", "right")
		if direction > 0:
			_facing = Game.Direction.RIGHT
		elif direction < 0:
			_facing = Game.Direction.LEFT
		
		if state != PlayerState.CHARGE:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions
			if direction and is_on_floor():
				velocity.x = direction * SPEED
			elif not is_on_floor():
				if not direction or direction == velocity.x/abs(velocity.x):
					velocity.x = velocity.x
				else:
					velocity.x = move_toward(velocity.x, direction * SPEED, DECCEL)
			else:
				velocity.x = 0
	move_and_slide()

# Charge related functions

func _handle_charge_action() -> void:
	if state == PlayerState.CHILL and _can_charge:
		state = PlayerState.CHARGE
		velocity.x = CHARGE_VELOCITY * _facing
		charge_timer.start()
	elif state == PlayerState.CHARGE:
		_stop_charge()

func _on_charge_timer_timeout() -> void:
	_stop_charge()

func _stop_charge():
	state = PlayerState.CHILL
	charge_timer.stop()
	_can_charge = false
	charge_cooldown_timer.start()

func _on_charge_cooldown_timer_timeout() -> void:
	_can_charge = true

# End of Charge handling


func _handle_throw_action() -> void:
	# TODO
	pass

func stun_player() -> void:
	state = PlayerState.STUNNED
	hitbox.disabled = true


func _on_stun_timer_timeout() -> void:
	# Give the player control again but don't let them get hit gain yet
	state = PlayerState.CHILL

func _on_i_frame_timer_timeout() -> void:
	# Turns off the i frames
	hitbox.disabled = false
