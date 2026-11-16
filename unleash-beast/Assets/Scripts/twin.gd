extends CharacterBody2D

enum AttackState {
	ROLL,
	JUMP,
	DASH,
	IDLE
}

signal enemy_died
signal enemy_removed

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
@onready var audio_player = $AudioStreamPlayer2D

var base_order = [AttackState.ROLL, AttackState.JUMP, AttackState.DASH]
var attack_direction = 1
var num_attacks = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor = false

func _ready() -> void:
	animation_player.play("idle")
	audio_player.volume_db = AudioLevel.sound_effect_volume
	hurtbox.area_entered.connect(_on_player_collision)
	timer.wait_time = 4
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	timer.start()

func _process(_delta: float) -> void:
	animated_sprite.scale.x = -1 if global_position.x <= 600 else 1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var gravityMultiplier = 3 if velocity.y > -300 else 1
		velocity.y += gravityMultiplier * gravity * delta
	elif not was_on_floor:
		velocity.x = 0
		reset_animation()
	
	was_on_floor = is_on_floor()

	move_and_slide()

func _on_timer_timeout():
	if num_attacks < 3:
		attack_state = base_order[num_attacks]
	else:
		timer.wait_time = randf_range(2.5, 4)
		attack_state = base_order[randi() % 3]
	
	animation_player.play("bundle-up")
	await animation_player.animation_finished

	num_attacks += 1
	process_attack()

func _on_attack_timer_timeout():
	if attack_state == AttackState.ROLL:
		attack_state = AttackState.IDLE
		reset_animation()
	else:
		velocity = Vector2(attack_direction * roll_speed, dash_speed)

func _on_player_collision(area_entered):
	area_entered.get_parent().take_damage.call_deferred(global_position)

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
	
	animation_player.play("rolling")

func trigger_rolling():
	attack_direction = 1 if global_position.x < 600 else -1
	velocity.x = attack_direction * roll_speed

	setup_attack_timer(0.6)

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

func reset_animation():
	animation_player.play("bundle-down")
	await animation_player.animation_finished
	animation_player.play("idle")

func enemy_take_damage(amount):
	flash_white()
	health -= amount
	check_enemy_death()

func check_enemy_death():
	if health <= 0:
		timer.stop()
		attack_timer.stop()
		enemy_died.emit()
		animation_player.play("die")
		await animation_player.animation_finished
		enemy_removed.emit()
		queue_free()
	else:
		audio_player.play()
