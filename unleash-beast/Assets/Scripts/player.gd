extends CharacterBody2D

enum AttackDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var speed = 400

@onready var animation_sprite = $AnimatedSprite2D
@onready var attack_direction = AttackDirection.RIGHT
@onready var previous_direction = attack_direction

func _ready():
	animation_sprite.play("idle")

func _process(_delta: float) -> void:
	get_aiming_input()
	log_attack_direction()

func _physics_process(_delta: float) -> void:
	get_movement_input()
	move_and_slide()

func get_movement_input():
	var input_direction = Vector2(Input.get_axis("move_left", "move_right"), 0)

	# Uses in the in-built character velocity to determine the direction the player should move.
	velocity = input_direction * speed

func get_aiming_input():
	var vertical_aim = Input.get_axis("aim_down", "aim_up")
	
	if not is_zero_approx(vertical_aim):
		attack_direction = AttackDirection.UP if vertical_aim == 1 else AttackDirection.DOWN
	else:
		var horizontal_aim = Input.get_axis("move_left", "move_right")

		attack_direction = AttackDirection.LEFT if horizontal_aim < 0 else AttackDirection.RIGHT

func log_attack_direction():
	if attack_direction == previous_direction:
		return

	var output = ""
	match (attack_direction):
		AttackDirection.UP:
			output = "UP"
		AttackDirection.DOWN:
			output = "DOWN"
		AttackDirection.LEFT:
			output = "LEFT"
		AttackDirection.RIGHT:
			output = "RIGHT"

	print("Aiming " + output)
	previous_direction = attack_direction
