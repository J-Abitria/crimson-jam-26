extends CharacterBody2D

enum AttackState {
	ROLL,
	JUMP,
	DASH,
	IDLE
}

@export var roll_speed = 800
@export var jump_horizontal_speed = 600
@export var jump_vertical_speed = -900
@export var dash_speed = 400
@export var health = 500

@onready var attack_timer = $AttackTimer
@onready var hurtbox = $Hurtbox
@onready var timer = $Timer
@onready var attack_state = AttackState.IDLE
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite = $AnimatedSprite2D

var base_order = [AttackState.ROLL, AttackState.JUMP, AttackState.DASH]
var attack_direction = 1
var num_attacks = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor = false

func _ready() -> void:
	animation_player.play("idle")
	hurtbox.area_entered.connect(_on_player_collision)
	timer.wait_time = 3.5
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	timer.start()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var gravityMultiplier = 3 if velocity.y > -300 else 1
		velocity.y += gravityMultiplier * gravity * delta
	elif not was_on_floor:
		velocity.x = 0
	
	was_on_floor = is_on_floor()

	check_cancel_attack()
	move_and_slide()

func _on_timer_timeout():
	if num_attacks < 3:
		attack_state = base_order[num_attacks]
	else:
		timer.wait_time = randf_range(2, 3.5)
		attack_state = base_order[randi() % 3]

	num_attacks += 1
	process_attack()

func _on_attack_timer_timeout():
	if attack_state == AttackState.ROLL:
		attack_state = AttackState.IDLE
	else:
		velocity = Vector2(attack_direction * roll_speed, dash_speed)

func _on_player_collision(area_entered):
	area_entered.get_parent().take_damage.call_deferred()

func check_cancel_attack():
	if attack_state == AttackState.IDLE:
		return
	
	if attack_state == AttackState.ROLL and is_on_wall():
		attack_timer.stop()
		velocity.x = 0
		attack_state = AttackState.IDLE


func process_attack():
	match(attack_state):
		AttackState.ROLL:
			trigger_rolling()
		AttackState.JUMP:
			trigger_jumping()
		AttackState.DASH:
			trigger_dashing()
		_:
			print("Not implemented")

func trigger_rolling():
	attack_direction = 1 if global_position.x < 600 else -1
	velocity.x = attack_direction * roll_speed

	setup_attack_timer(0.75)

func trigger_jumping():
	attack_direction = 1 if global_position.x < 600 else -1
	velocity.x = attack_direction * jump_horizontal_speed
	velocity.y = jump_vertical_speed

func trigger_dashing():
	attack_direction = 1 if global_position.x < 600 else -1
	velocity.x = attack_direction * jump_horizontal_speed
	velocity.y = jump_vertical_speed

	setup_attack_timer(0.4)

func setup_attack_timer(time):
	attack_timer.wait_time = time
	attack_timer.one_shot = true
	attack_timer.start()

func flash_white():
	animated_sprite.modulate = Color(10, 10, 10, 10)
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1, 1)

func enemy_take_damage(amount):
	flash_white()
	health -= amount

func check_enemy_death():
	if health <= 0:
		queue_free()
