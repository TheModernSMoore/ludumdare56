extends CharacterBody2D
class_name Thrower

var _throwable : Throwable = null
var _holding_spot : Node2D

func pickup_throwable(thing : Throwable):
	_throwable = thing

func _process(delta: float) -> void:
	if _throwable:
		_throwable.global_position = _holding_spot.global_position

func can_pickup() -> bool:
	assert(false, "this function must be overridden")
	return false
