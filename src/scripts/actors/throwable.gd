extends CharacterBody2D
class_name Throwable


@export var SPEED : float = 500.0

var thrown : bool = false

# Make sure to call this in child class _physics_process
func _physics_process(delta: float) -> void:
	if thrown:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		velocity.x = SPEED
		move_and_slide()

func throw(direction : Game.Direction):
	thrown = true
	SPEED *= direction
	
