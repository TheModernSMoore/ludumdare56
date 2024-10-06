extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Actor:
		var direction = (body.global_position.x - global_position.x) / abs(body.global_position.x - global_position.x) * 1.5
		body.get_hit(direction)

func _on_explosion_timer_timeout() -> void:
	queue_free()
