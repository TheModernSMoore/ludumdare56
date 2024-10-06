extends Area2D
class_name Throwable


const THROW_SPEED : float = 500
const UP_SPEED : float = 500
const BOUNCE_LOSS_Y : float = 250
const BOUNCE_LOSS_X : float = 250

var active : bool = false
var thrower : CharacterBody2D
var cooldown_over = true
@export var can_be_picked_up = true
@onready var actor : CharacterBody2D = get_parent()
@onready var cooldown = $ThrowCoolDown
@onready var lifetime = $Lifetime
@export var lifetime_seconds : float

var lifetime_bar : ProgressBar

func _ready() -> void:
	lifetime.wait_time = lifetime_seconds

# Make sure to call this in child class _physics_process
func _physics_process(delta: float) -> void:
	update_life_bar()
	if active:
		actor.velocity += actor.get_gravity() * delta
		
		
		var collision = actor.move_and_collide(actor.velocity * delta)
		if collision:
			actor.velocity = actor.velocity.bounce(collision.get_normal())
			actor.velocity.x -= actor.velocity.normalized().x * BOUNCE_LOSS_X
			actor.velocity.y -= actor.velocity.normalized().y * BOUNCE_LOSS_Y

func update_life_bar():
	lifetime_bar.value = (lifetime.wait_time - lifetime.time_left)/lifetime.wait_time * 100
	if lifetime_bar.value == 100:
		lifetime_bar.visible = false
	else:
		lifetime_bar.visible = true

func throw(direction : Game.Direction):
	active = true
	# set_deferred("monitorable", true)
	# set_deferred("monitoring", true)
	actor.velocity.x = THROW_SPEED * direction
	actor.velocity.y = UP_SPEED * -1
	cooldown.start()
	cooldown_over = false
	lifetime.start()

func _on_body_entered(body: Node2D) -> void:
	if body != actor and cooldown_over and body is Actor and body.can_pickup() and can_be_picked_up:
		thrower = body
		lifetime.stop()
		body.pickup_throwable(self)
	else:
		pass
		#if (thrower is Player and body is Enemy and body.state == Enemy.EnemyState.ACTIVE) or (thrower is Enemy and body is Player):
			#print("jo")
			#var direction = (body.global_position.x - global_position.x)/abs(body.global_position.x - global_position.x)
			#body.get_hit(direction)
	   


func _on_throw_cool_down_timeout() -> void:
	cooldown_over = true


func _on_lifetime_timeout() -> void:
	actor.do_throwable_action()
