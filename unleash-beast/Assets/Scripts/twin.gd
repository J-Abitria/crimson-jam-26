extends CharacterBody2D

enum AttackState {
    ROLL,
    JUMP,
    DASH,
    IDLE
}

@export var roll_speed = 800

@onready var attack_timer = $AttackTimer
@onready var timer = $Timer
@onready var attack_state = AttackState.IDLE

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
    timer.wait_time = 5
    timer.one_shot = false
    timer.timeout.connect(_on_timer_timeout)
    attack_timer.timeout.connect(_on_attack_timer_timeout)
    timer.start()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        var gravityMultiplier = 3 if velocity.y > -200 else 1
        velocity.y += gravityMultiplier * gravity * delta
    
    if attack_state == AttackState.ROLL and is_on_wall():
        attack_timer.stop()
        velocity.x = 0
        attack_state = AttackState.IDLE

    move_and_slide()

func _on_timer_timeout():
    attack_state = AttackState.ROLL

    process_attack()

func _on_attack_timer_timeout():
    attack_state = AttackState.IDLE

func process_attack():
    match(attack_state):
        AttackState.ROLL:
            trigger_rolling()
        _:
            print("Not implemented")

func trigger_rolling():
    var attack_direction = 1 if global_position.x < 600 else -1
    velocity.x = attack_direction * roll_speed

    attack_timer.wait_time = 0.75
    attack_timer.one_shot = true
    attack_timer.start()
