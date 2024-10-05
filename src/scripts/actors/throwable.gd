extends CharacterBody2D
class_name Throwable


const SPEED : float = 500
const UP_SPEED : float = 500
const BOUNCE_LOSS_Y : float = 250
const BOUNCE_LOSS_X : float = 250

var can_throw : bool
var thrown : bool = false
var thrower : CharacterBody2D
var pickup_box : CollisionShape2D

# Make sure to call this in child class _physics_process
func _physics_process(delta: float) -> void:
	if thrown:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			velocity.x -= velocity.normalized().x * BOUNCE_LOSS_X
			velocity.y -= velocity.normalized().y * BOUNCE_LOSS_Y

func throw(direction : Game.Direction):
	thrown = true
	process_mode = PROCESS_MODE_ALWAYS
	pickup_box.disabled = true
	velocity.x = SPEED * direction
	velocity.y = UP_SPEED * -1
	
func _on_hit_box_area_body_entered(body: Node2D) -> void:
	if can_throw and body is Thrower and body.can_pickup():
		thrower = body
		call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
		body.pickup_throwable(self)
