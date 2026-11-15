extends CharacterBody2D

enum AttackDirection {
	UP,
	DOWN,
	HORIZONTAL
}

signal health_changed(new_health)
signal rage_changed(new_rage)
signal rage_used
signal died

@export var speed = 500
@export var jump_speed = -800
@export var health = 10
@export var self_knockback_strength = 200
@export var self_pogo_strength = 600
@export var knockback_decay = 1000
@export var rage_boost_value = 1.5
@export var damage = 5

@onready var animation_player = $AnimationPlayer
@onready var animation_sprite = $AnimatedSprite2D
@onready var camera = $"../Camera2D"
@onready var collision_shape = $Hurtbox/CollisionShape2D
@onready var hitbox_pivot = $HitboxPivot
@onready var invincibility_timer = $InvincibilityTimer
@onready var rage_timer = $RageTimer
@onready var collision_start_pos = collision_shape.position
@onready var attack_direction = AttackDirection.HORIZONTAL
@onready var previous_direction = attack_direction

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback_velocity = Vector2.ZERO
var rage = 0
var rage_multiplier = 1

func _ready():
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_animation_finished)

	var hitboxes = hitbox_pivot.get_children()
	for hitbox_area in hitboxes:
		hitbox_area.body_entered.connect(_on_enemy_collision)

	invincibility_timer.wait_time = 2
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_on_invincibility_timeout)

	rage_timer.wait_time = 8
	rage_timer.one_shot = true
	rage_timer.timeout.connect(_on_rage_end)

func _process(_delta: float) -> void:
	get_aiming_input()
	log_attack_direction()

	if Input.is_action_just_pressed("attack"):
		choose_attack_animation()
	
	if Input.is_action_just_pressed("activate") and rage == 100:
		rage = 0
		rage_multiplier *= rage_boost_value
		rage_used.emit()
		animation_player.speed_scale = 2
		rage_timer.start()


func _physics_process(delta: float) -> void:
	get_movement_input()

	if not is_on_floor():
		var gravityMultiplier = 3 if not Input.is_action_pressed("jump") or velocity.y > -200 else 1
		velocity.y += gravityMultiplier * gravity * delta
			
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	velocity += knockback_velocity
	move_and_slide()

func _on_animation_finished(anim_name: String):
	print("Animation done")

	if anim_name.ends_with("attack"):
		animation_player.play("idle")

func _on_enemy_collision(body):
	body.enemy_take_damage(damage * rage_multiplier)
	rage = rage + 2 if rage <= 98 else 100
	rage_changed.emit(rage)

	calculate_knockback(body.global_position, 0.5, 1)

func _on_invincibility_timeout():
	collision_shape.disabled = false

func _on_rage_end():
	animation_player.speed_scale = 1
	rage_multiplier /= rage_boost_value


func calculate_knockback(enemy_position, pogo_multiplier, base_multiplier):
	var distance = global_position - enemy_position

	if distance.y < -16.0:
		velocity.y = -self_pogo_strength
		knockback_velocity.x = sign(distance.x) * self_knockback_strength * pogo_multiplier
	else:
		knockback_velocity = Vector2(sign(distance.x) * self_knockback_strength * base_multiplier, 0)

func get_movement_input():
	var input_direction = Input.get_axis("move_left", "move_right")
	
	if not is_zero_approx(input_direction) and not animation_player.current_animation.ends_with("attack"):
		animation_sprite.scale.x = input_direction
		hitbox_pivot.scale.x = input_direction
		animation_sprite.position = Vector2.ZERO if input_direction == 1 else Vector2(-14, 0)
		hitbox_pivot.position = Vector2.ZERO if input_direction == 1 else Vector2(-14, 0)

	# Uses in the in-built character velocity to determine the direction the player should move.
	velocity.x = input_direction * speed

func get_aiming_input():
	var vertical_aim = Input.get_axis("aim_down", "aim_up")
	
	if not is_zero_approx(vertical_aim):
		attack_direction = AttackDirection.UP if vertical_aim == 1 else AttackDirection.DOWN
	else:
		attack_direction = AttackDirection.HORIZONTAL

func log_attack_direction():
	if attack_direction == previous_direction:
		return

	var output = ""
	match (attack_direction):
		AttackDirection.UP:
			output = "UP"
		AttackDirection.DOWN:
			output = "DOWN"
		AttackDirection.HORIZONTAL:
			output = "HORIZONTAL"

	print("Aiming " + output)
	previous_direction = attack_direction

func choose_attack_animation():
	if animation_player.current_animation.ends_with("attack"):
		return

	if attack_direction == AttackDirection.HORIZONTAL:
		animation_player.play("horizontal-attack")
	elif attack_direction == AttackDirection.UP:
		animation_player.play("up-attack")
	elif attack_direction == AttackDirection.DOWN and not is_on_floor():
		animation_player.play("down-attack")

func take_damage(enemy_position):
	collision_shape.disabled = true
	health -= 1
	health_changed.emit(health)
	rage_multiplier += .02
	rage = rage + 5 if rage <= 95 else 100
	rage_changed.emit(rage)

	calculate_knockback(enemy_position, 2, 3)
	check_death()

	camera.apply_shake(10.0)
	invincibility_timer.start()

func check_death():
	if health == 0:
		invincibility_timer.stop()
		died.emit()
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://death_screen.tscn")
