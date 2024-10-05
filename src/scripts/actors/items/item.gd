extends Throwable

func _ready() -> void:
	can_throw = true
	pickup_box = $HitBoxArea/HitBox
