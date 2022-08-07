extends KinematicBody2D

var velocity = Vector2()

var current_state := 0
enum {WALK, ATTACK, JUMP, FALL, IDLE, SLIDE}

var enter_state := true

func _physics_process(delta):
	match current_state:
		WALK:
			_walk_state(delta)
		ATTACK:
			_attack_state(delta)
		JUMP:
			_jump_state(delta)
		FALL:
			_fall_state(delta)
		IDLE:
			_idle_state(delta)
		SLIDE:
			_slide_state(delta)

#Check Functions

func _check_idle_state():
	var new_state = current_state
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		new_state = WALK
	elif Input.is_action_pressed("space"):
		new_state = ATTACK
	elif Input.is_action_pressed("ui_up"):
		new_state = JUMP
	elif not is_on_floor():
		new_state = FALL
	return new_state

func _check_walk_state():
	var new_state = current_state
	if (not Input.is_action_pressed("ui_right")) and (not Input.is_action_pressed("ui_left")):
		new_state = IDLE
	elif Input.is_action_pressed("space"):
		new_state = ATTACK
	elif Input.is_action_pressed("ui_up"):
		new_state = JUMP
	elif Input.is_action_just_pressed("ui_down"):
		new_state = SLIDE
	elif not is_on_floor():
		new_state = FALL
	return new_state

func _check_jump_state():
	var new_state = current_state
	if velocity.y >= 0:
		new_state = FALL
	if Input.is_action_pressed("space"):
		new_state = ATTACK
	return new_state

func _check_fall_state():
	var new_state = current_state
	if is_on_floor():
		new_state = IDLE
	elif Input.is_action_pressed("space"):
		new_state = ATTACK
	return new_state

func _check_slide_state():
	var new_state = current_state
	if abs(round(velocity.x)) <= 20:
		new_state = IDLE
	elif not is_on_floor():
		new_state = FALL
	return new_state
	
#State Functions
func _walk_state(_delta):
	$AnimatedSprite.play("walk")
	_move()
	_apply_gravity(_delta)
	_move_and_slide()
	current_state = _check_walk_state()

func _jump_state(_delta):
	if enter_state:	
		$AnimatedSprite.play("jump")
		velocity.y = -200
		enter_state = false
	_apply_gravity(_delta)
	_move()
	_move_and_slide()
	_set_state(_check_jump_state())
	
func _fall_state(_delta):
	$AnimatedSprite.play("fall")
	_apply_gravity(_delta)
	_move()
	_move_and_slide()
	_set_state(_check_fall_state())
	
func _attack_state(_delta):
	$AnimatedSprite.play("attack")
	_apply_gravity(_delta)
	velocity.x = 0
	_move_and_slide()

func _idle_state(_delta):
	$AnimatedSprite.play("idle")
	_apply_gravity(_delta)
	velocity.x = 0
	_move_and_slide()
	_set_state(_check_idle_state())

func _slide_state(_delta):
	$AnimatedSprite.play("slide")
	_apply_gravity(_delta)
	_move_and_slide()
	velocity.x = lerp(velocity.x, 0, 0.05)
	_set_state(_check_slide_state())
	
#helpers
func _apply_gravity(_delta):
	velocity.y += 981 * _delta
	
func _move_and_slide():
	velocity = move_and_slide(velocity, Vector2.UP)

func _move():
	if Input.is_action_pressed("ui_left"):
		velocity.x = -120
		$AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("ui_right"):
		velocity.x = 120
		$AnimatedSprite.flip_h = false

func _set_state(new_state):
	if new_state != current_state:
		enter_state = true
	current_state = new_state

func _on_AnimatedSprite_animation_finished():
	var anim_name = $AnimatedSprite.animation
	if anim_name == "attack":
		_set_state(IDLE)
