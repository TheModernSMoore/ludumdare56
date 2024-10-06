extends CharacterBody2D

const explosion_ref = preload("res://src/scenes/actors/items/explosion.tscn")

@onready var _throwable = $Throwable
@onready var _sprite = $Sprite2D

func _ready():
	_throwable.lifetime_bar = $BlowUpBar

# Make sure to call this in child class _physics_process
func _physics_process(delta: float) -> void:
	if not _throwable.active:
		velocity += get_gravity() * delta
		move_and_slide()

func do_throwable_action():
	_sprite.visible = false
	var explosion = explosion_ref.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	queue_free()
	
