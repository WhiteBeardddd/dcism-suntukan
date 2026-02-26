extends CharacterBody2D

# --- Movement Stats ---
const SPEED := 180.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 900.0

# --- Dash ---
const DASH_SPEED := 400.0
const DASH_DURATION := 0.2

# --- Wall ---
const WALL_SLIDE_SPEED := 60.0
const WALL_CLIMB_SPEED := -120.0

# --- Combat ---
const COMBO_WINDOW := 0.6

# --- State ---
var direction : float = 0
var is_dashing := false
var dash_timer := 0.0
var dash_direction := 1.0

var is_crouching := false
var is_dead := false
var is_attacking := false
var is_rolling := false
var is_sliding := false

var attack_combo := 0
var combo_timer := 0.0

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):

	if is_dead:
		return

	# Cache direction input (optimization)
	direction = Input.get_axis("move_left", "move_right")

	_apply_gravity(delta)
	_handle_dash(delta)

	if not is_dashing:
		_handle_movement()
		_handle_jump()
		_handle_wall()
		_handle_crouch()
		_handle_roll()
		_handle_slide()
		_handle_attack(delta)

	move_and_slide()
	_update_animation()


# -------------------------------------------------
# Animation Signal
# -------------------------------------------------

func _on_animation_finished():

	match anim.animation:

		"attack1","attack2","attack3","crouch_attack":
			is_attacking = false
			attack_combo = 0
			combo_timer = 0

		"roll":
			is_rolling = false

		"slide":
			is_sliding = false

		"death":
			anim.stop()


# -------------------------------------------------
# Gravity
# -------------------------------------------------

func _apply_gravity(delta):

	if not is_on_floor():
		velocity.y += GRAVITY * delta


# -------------------------------------------------
# Movement
# -------------------------------------------------

func _handle_movement():

	if is_crouching or is_rolling or is_sliding:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		return

	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


# -------------------------------------------------
# Jump
# -------------------------------------------------

func _handle_jump():

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# -------------------------------------------------
# Dash
# -------------------------------------------------

func _handle_dash(delta):

	if is_dashing:

		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0

		if dash_timer <= 0:
			is_dashing = false

	elif Input.is_action_just_pressed("dash") and is_on_floor():

		is_dashing = true
		dash_timer = DASH_DURATION
		dash_direction = -1 if anim.flip_h else 1


# -------------------------------------------------
# Wall Mechanics
# -------------------------------------------------

func _handle_wall():

	if is_on_wall() and not is_on_floor():

		if direction != 0:

			if Input.is_action_pressed("jump"):
				velocity.y = WALL_CLIMB_SPEED
			else:
				velocity.y = WALL_SLIDE_SPEED


# -------------------------------------------------
# Crouch
# -------------------------------------------------

func _handle_crouch():

	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()


# -------------------------------------------------
# Roll
# -------------------------------------------------

func _handle_roll():

	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:

		is_rolling = true
		anim.play("roll")


# -------------------------------------------------
# Slide
# -------------------------------------------------

func _handle_slide():

	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding:

		is_sliding = true
		velocity.x = (-1 if anim.flip_h else 1) * SPEED * 1.5
		anim.play("slide")


# -------------------------------------------------
# Attack Combo
# -------------------------------------------------

func _handle_attack(delta):

	if combo_timer > 0:
		combo_timer -= delta
	else:
		if not is_attacking:
			attack_combo = 0

	if is_attacking:
		return

	if Input.is_action_just_pressed("attack1"):

		is_attacking = true

		if attack_combo == 1 and combo_timer > 0:
			attack_combo = 2
			anim.play("attack2")
		else:
			attack_combo = 1
			anim.play("attack1")

		combo_timer = COMBO_WINDOW


	elif Input.is_action_just_pressed("attack2"):

		is_attacking = true

		if is_crouching:
			anim.play("crouch_attack")
		else:
			anim.play("attack2")

		combo_timer = COMBO_WINDOW


	elif Input.is_action_just_pressed("attack3"):

		is_attacking = true
		attack_combo = 0
		anim.play("attack3")


# -------------------------------------------------
# Animation Controller
# -------------------------------------------------

func _update_animation():

	if is_attacking or is_rolling or is_sliding or is_dead:
		return

	if is_dashing:
		anim.play("dash")
		return

	if not is_on_floor():

		if is_on_wall():
			anim.play("wall_hang")
		elif velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("jump")

		return

	if is_crouching:

		if abs(velocity.x) > 10:
			anim.play("crouch_walk")
		else:
			anim.play("crouch")

		return

	if abs(velocity.x) > 10:
		anim.play("run")
	else:
		anim.play("idle")


# -------------------------------------------------
# External
# -------------------------------------------------

func take_hit():

	if is_dead:
		return

	is_attacking = false
	anim.play("hit")


func die():

	is_dead = true
	anim.play("death")
