extends Actor
class_name Player


@export var SPEED : float
@export var DECCEL : float
@export var JUMP_VELOCITY : float
@export var CHARGE_VELOCITY : float
@export var charge_cooldown : float

@onready var _hitbox_area = $HitBoxArea
@onready var charge_timer = $ChargeTimer
@onready var charge_cooldown_bar = $CanvasLayer/ChargeCooldownBar
@onready var stun_timer = $StunTimer
@onready var i_framer_timer = $IFrameTimer
@onready var stun_bar = $StunBar
@onready var animation = $AnimatedSprite2D

var _can_charge = true
var invincible = false

enum PlayerState{CHILL, CHARGE, STUNNED}
var state : PlayerState = PlayerState.CHILL

var _facing : Game.Direction = Game.Direction.RIGHT

func _ready():
	charge_cooldown_bar.value = charge_cooldown
	charge_cooldown_bar.max_value = charge_cooldown
	_holding_spot = $ThrowingSpot

func _physics_process(delta: float) -> void:
	match _facing:
		Game.Direction.RIGHT:
			animation.scale.x = abs(animation.scale.x)
		Game.Direction.LEFT:
			animation.scale.x = -1 * abs(animation.scale.x)
	match state:
		PlayerState.CHILL:
			animation.animation = "default"
		PlayerState.CHARGE:
			animation.animation = "dash"
		PlayerState.STUNNED:
			animation.animation = "stun"
	update_stun_bar()
	if invincible:
		modulate.a = 0.5
	else:
		modulate.a = 1
	_update_cooldown(delta)
	# Add the gravity.  This always happens.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Check if the player is stunnned, they should not be able to do things
	if state == PlayerState.STUNNED:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, DECCEL)
	else:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		
		if Input.is_action_just_pressed("action"):
			if _throwable:
				_handle_throw_action()
			elif state == PlayerState.CHILL or state == PlayerState.CHARGE:
				_handle_charge_action()
		
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


func update_stun_bar():
	stun_bar.value = (stun_timer.wait_time - stun_timer.time_left)/stun_timer.wait_time * 100
	if stun_bar.value == 100:
		stun_bar.visible = false
	else:
		stun_bar.visible = true

# Charge related functions

func _handle_charge_action() -> void:
	if state == PlayerState.CHILL and _can_charge:
		state = PlayerState.CHARGE
		velocity.x = CHARGE_VELOCITY * _facing
		charge_timer.start()
		charge_cooldown_bar.value = 0
	elif state == PlayerState.CHARGE:
		stop_charge()

func _on_charge_timer_timeout() -> void:
	stop_charge()

func charge_i_frames() -> void:
	invincible = true
	i_framer_timer.stop()
	i_framer_timer.start()

func stop_charge():
	if state == PlayerState.CHARGE:
		state = PlayerState.CHILL
	charge_timer.stop()
	_can_charge = false

func _update_cooldown(delta : float):
	if state != PlayerState.CHARGE:
		charge_cooldown_bar.value += delta
		if charge_cooldown_bar.value >= charge_cooldown:
			_can_charge = true

# End of Charge handling

# Holding and throwing handling
func can_pickup() -> bool:
	print(state != PlayerState.STUNNED)
	print(not _throwable)
	return state != PlayerState.STUNNED and not _throwable

func _handle_throw_action() -> void:
	_throwable.throw(_facing)
	state = PlayerState.CHILL
	_throwable = null

# End of holding and throwing

# Start of stun handling

func get_hit(direction : float) -> void:
	state = PlayerState.STUNNED
	invincible = true
	super(direction)
	stun_timer.wait_time = abs(direction)
	stun_timer.start()

func _on_stun_timer_timeout() -> void:
	# Give the player control again but don't let them get hit gain yet
	state = PlayerState.CHILL
	i_framer_timer.stop()
	i_framer_timer.start()
	

func _on_i_frame_timer_timeout() -> void:
	# Turns off the i frames
	print("ooff")
	invincible = false

# End of stun handling
