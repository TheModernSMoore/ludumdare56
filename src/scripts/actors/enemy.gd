extends Actor
class_name Enemy

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

enum EnemyState{ACTIVE, STUNNED}
var state : EnemyState = EnemyState.ACTIVE
var facing : Game.Direction = Game.Direction.RIGHT

@onready var arena = get_parent().get_parent() as Arena
@onready var _ray_casters = $RayCasters
@onready var _wall_finder = $RayCasters/WallFinder
@onready var _edge_finder = $RayCasters/EdgeFinder
@onready var _throw_area = $ThrowArea as Throwable
@onready var _hitbox_area = $HitBoxArea
@onready var _pickup_timer = $TimeBeforePickup
@onready var _sprite = $Sprite2D

var thrower = false
var jumper = false
var stabber = false

func _ready():
	_throw_area.lifetime_bar = $LifeBar
	velocity.x = SPEED


func _physics_process(delta: float) -> void:
	if not _throw_area.active:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		# velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if state == EnemyState.ACTIVE:
			if is_on_floor() and (_wall_finder.is_colliding() or not _edge_finder.is_colliding()):
				velocity.x *= -1
				_ray_casters.scale.x *= -1
				_sprite.scale.x *= -1
				facing *= -1
		
		move_and_slide()
		
func _on_hit_box_area_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		var body = area.get_parent()
		if body is Player:
			var direction = (global_position.x - body.global_position.x)/abs(global_position.x - body.global_position.x)
			if body.state == Player.PlayerState.CHARGE:
				body.charge_i_frames()
				body.stop_charge()
				get_hit(direction)
				direction *= -0.25
				body.get_hit(direction)
				arena.play_hit()
			elif body.invincible == false:
				direction *= -1
				body.get_hit(direction)
				arena.play_damaged()


func get_hit(direction : float):
	state = EnemyState.STUNNED
	_sprite.scale.y *= -1
	_pickup_timer.start()
	_hitbox_area.set_deferred("monitorable", false)
	_hitbox_area.set_deferred("monitoring", false)
	super(direction)
	_throw_area.active = true
	_throw_area.can_be_picked_up = true
	_throw_area.lifetime.start()
	

func _on_time_before_pickup_timeout() -> void:
	_throw_area.set_deferred("monitorable", true)
	_throw_area.set_deferred("monitoring", true)

func can_pickup() -> bool:
	return state != EnemyState.STUNNED and thrower

func do_throwable_action():
	state = EnemyState.ACTIVE
	_throw_area.can_be_picked_up = false
	_throw_area.active = false
	_sprite.scale.y *= -1
	_hitbox_area.set_deferred("monitorable", true)
	_hitbox_area.set_deferred("monitoring", true)
	_throw_area.set_deferred("monitorable", false)
	_throw_area.set_deferred("monitoring", false)
	velocity.x = SPEED * facing
