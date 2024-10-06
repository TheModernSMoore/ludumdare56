extends CharacterBody2D
class_name Actor

var _throwable : Throwable = null
var _holding_spot : Node2D
@export var knockback_velocity = 400

func pickup_throwable(thing : Throwable):
	_throwable = thing

func _process(delta: float) -> void:
	if _throwable and _holding_spot:
		_throwable.actor.global_position = _holding_spot.global_position

func can_pickup() -> bool:
	return false

func get_hit(direction : float):
	velocity.y = -knockback_velocity
	velocity.x = knockback_velocity * direction
