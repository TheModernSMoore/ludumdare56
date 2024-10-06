extends StaticBody2D

@onready var arena = get_parent() as Arena


func _on_score_zone_area_entered(area: Area2D) -> void:
	if area is Throwable and (not area.thrower or area.thrower.throwable == null):
		if area.actor is Enemy:
			print("how")
			arena.score()
		area.actor.queue_free()
