extends CharacterBody2D

@export var attack_range: float = 20.0
@export var move_speed: float = 150.0
@export var attack_cooldown: float = 2.0
@export var max_hp: int = 50                          # NEW

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox               # NEW

var player: Node2D = null
var is_attacking: bool = false
var can_attack: bool = true
var current_hp: int                                   # NEW

enum State { CHASE, ATTACK }
var state = State.CHASE

func _ready() -> void:
	current_hp = max_hp                               # NEW
	hurtbox.damaged.connect(_on_damaged)              # NEW
	animated_sprite.animation_finished.connect(_on_attack_finished)
	print("hurtbox connected: ", hurtbox.damaged.is_connected(_on_damaged))

func _on_damaged(amount: int) -> void:
	if current_hp <= 0:
		return                  # ignore hits on a dead enemy
	current_hp -= amount
	print("Demon HP: %d / %d" % [current_hp, max_hp])
	if current_hp <= 0:
		_die()

func _die() -> void:                                  # NEW
	hurtbox.set_deferred("monitoring", false)
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		if not is_attacking:
			animated_sprite.play("idle")
		move_and_slide()
		return
	var distance := global_position.distance_to(player.global_position)
	_update_state(distance)
	_handle_state()

func _update_state(distance: float) -> void:
	if is_attacking:
		return
	if distance <= attack_range and can_attack:
		state = State.ATTACK
	else:
		state = State.CHASE

func _handle_state() -> void:
	match state:
		State.CHASE:
			var direction := (player.global_position - global_position).normalized()
			if direction == Vector2.ZERO:
				direction = Vector2.RIGHT
			velocity = direction * move_speed
			animated_sprite.flip_h = player.global_position.x > global_position.x
			if animated_sprite.animation != "walk":
				animated_sprite.play("walk")
		State.ATTACK:
			velocity = Vector2.ZERO
			if not is_attacking:
				is_attacking = true
				can_attack = false
				animated_sprite.flip_h = player.global_position.x > global_position.x
				animated_sprite.play("attack")
	move_and_slide()

func _on_attack_finished() -> void:
	is_attacking = false
	state = State.CHASE
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
