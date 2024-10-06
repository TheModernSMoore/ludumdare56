extends Node2D
class_name Arena

var points : int = 0

const enemy_ref = preload("res://src/scenes/actors/enemy.tscn")
const bomb_ref = preload("res://src/scenes/actors/items/bomb.tscn")

@onready var time_label = $Time as Label
@onready var timer = $Timer as Timer
@onready var points_label = $Points as Label
@onready var fmod_event_emitter = $FmodEventEmitter2D as FmodEventEmitter2D
@onready var spawners = $Spawners
@onready var enemies = $Enemies
@onready var bombs = $Bombs
@onready var final_screen = $CanvasLayer
@onready var final_score = $CanvasLayer/ColorRect/FinalScore

@export var max_enemies : int

func score():
	points += 1
	play_scored()

func _process(delta: float) -> void:
	_update_timer()

func _update_timer():
	time_label.text = str(ceil(timer.time_left))
	points_label.text = "Points: " + str(points)
	fmod_event_emitter.set_parameter("Score", points)


func _on_spawn_timer_timeout() -> void:
	var rand_idx = randi_range(0, spawners.get_child_count() - 1)
	if enemies.get_child_count() < max_enemies:
		var enemy = enemy_ref.instantiate()
		enemy.global_position = spawners.get_child(rand_idx).global_position
		enemies.add_child(enemy)
	elif bombs.get_child_count() < 2:
		var bomb = bomb_ref.instantiate()
		bomb.global_position = spawners.get_child(rand_idx).global_position
		bombs.add_child(bomb)

func play_hit():
	fmod_event_emitter.set_parameter("Hit", 1.0)
	fmod_event_emitter.set_parameter("Hit", 0)

func play_scored():
	fmod_event_emitter.set_parameter("Scored", 1.0)
	fmod_event_emitter.set_parameter("Scored", 0)

func play_damaged():
	fmod_event_emitter.set_parameter("Damaged", 1.0)
	fmod_event_emitter.set_parameter("Damaged", 0)


func _on_timer_timeout() -> void:
	final_screen.visible = true
	final_score.text = "You got " + str(points) + "!"


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
