extends Node2D
class_name Arena

var points : int = 0

const enemy_ref = preload("res://src/scenes/actors/enemy.tscn")

@onready var time_label = $Time as Label
@onready var timer = $Timer as Timer
@onready var points_label = $Points as Label
@onready var fmod_event_emitter = $FmodEventEmitter2D as FmodEventEmitter2D
@onready var spawners = $Spawners
@onready var enemies = $Enemies

@export var max_enemies : int

func score():
	points += 1

func _process(delta: float) -> void:
	_update_timer()

func _update_timer():
	time_label.text = str(ceil(timer.time_left))
	points_label.text = "Points: " + str(points)
	fmod_event_emitter.set_parameter("Score", points)


func _on_spawn_timer_timeout() -> void:
	if enemies.get_child_count() < max_enemies:
		print(enemies.get_child_count())
		var rand_idx = randi_range(0, spawners.get_child_count() - 1)
		var enemy = enemy_ref.instantiate()
		enemy.position = spawners.get_child(rand_idx).position
		enemies.add_child(enemy)
