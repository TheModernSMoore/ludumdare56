extends StaticBody2D

@onready var arena = get_parent() as Arena


func _on_score_zone_area_entered(area: Area2D) -> void:
	if area is Throwable:
		if area.actor is Enemy:
			arena.score()
		area.actor.queue_free()
