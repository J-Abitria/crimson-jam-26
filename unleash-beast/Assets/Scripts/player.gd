extends CharacterBody2D

enum AttackDirection {
	UP,
	DOWN,
	HORIZONTAL
}

@export var speed = 500
@export var jump_speed = -800

@onready var animation_sprite = $AnimatedSprite2D
@onready var attack_direction = AttackDirection.HORIZONTAL
@onready var previous_direction = attack_direction

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animation_sprite.play("idle")
	animation_sprite.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	get_aiming_input()
	log_attack_direction()

	if Input.is_action_just_pressed("attack"):
		choose_attack_animation()

func _physics_process(delta: float) -> void:
	get_movement_input()

	if not is_on_floor():
		var gravityMultiplier = 3 if not Input.is_action_pressed("jump") or velocity.y > -200 else 1
		velocity.y += gravityMultiplier * gravity * delta
			
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	move_and_slide()

func _on_animation_finished():
	print("Animation done")
	if animation_sprite.animation == "horizontal-attack":
		animation_sprite.play("idle")

func get_movement_input():
	var input_direction = Input.get_axis("move_left", "move_right")
	
	if not is_zero_approx(input_direction) and not animation_sprite.animation.ends_with("attack"):
		animation_sprite.scale.x = input_direction

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
	if animation_sprite.animation.ends_with("attack"):
		return

	match(attack_direction):
		AttackDirection.HORIZONTAL:
			animation_sprite.play("horizontal-attack")
		_:
			print("Not a recognized direction")
