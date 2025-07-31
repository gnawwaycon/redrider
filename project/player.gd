extends Area2D

@export var max_speed = 400
@export var acceleration = 2000
@export var friction = .1 

#balance
@export var balance_torque = 200.0 # How much force you can apply to balance
@export var gravity_torque = 100.0  # How strongly gravity pulls you over when tilted
@export var max_tilt_angle = 80.0  # The angle in degrees where you fall
@export var angular_damping = 0.98 # A little friction to stop endless wobbling

var screen_size 
var velocity = Vector2.ZERO # The player's current speed and direction.
var angular_velocity = 0.0 # How fast the panda is currently rotating
var tilt_angle = 3.0 # The panda's current tilt in degrees. Start slightly off-balance.
var is_fallen = false
var reached_end = false

func _ready():
	DebugDisplay.clear()
	screen_size = get_viewport_rect().size
	position = Vector2(50, 375)

func _process(delta):
	# 0. If the panda has fallen, do nothing until the game is reset.
	if is_fallen or reached_end:
		# You could add logic here to press a button to restart
		if Input.is_action_just_pressed("ui_accept"): # Press Enter or Spacebar
			get_tree().reload_current_scene()
		return

	# Get input from the player.
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1

	# Player applies torque to balance.
	# Moving left/right creates a force that pushes you upright.
	if input_direction.x != 0:
		angular_velocity -= input_direction.x * balance_torque * delta

	# Gravity applies torque, causing the fall.
	# The more you are tilted, the stronger gravity's pull.
	# We use sin(angle) because the force is strongest when you are more horizontal.
	angular_velocity += sin(deg_to_rad(tilt_angle)) * gravity_torque * delta

	# Apply damping to slow down rotation naturally.
	angular_velocity *= angular_damping

	# Update the tilt angle based on the angular velocity.
	tilt_angle += angular_velocity * delta
	
	# Apply the rotation to the entire player node.
	# This makes sure visuals and future collision shapes all rotate together.
	self.rotation_degrees = tilt_angle

	# Apply acceleration or friction based on keypress
	if input_direction != Vector2.ZERO:
		var target_velocity = input_direction * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * friction * delta)
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x) # Only clamp x-axis

	update_animation()

	#Check if the panda should fall over.
	if abs(tilt_angle) > max_tilt_angle:
		fall_over()
		
	#check if panda reached end
	if position.x >= 1900:
		finish_level()

func update_animation():
	if is_fallen:
		return

	if velocity.length() > 10:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		return

	if abs(velocity.x) > 0:
		$AnimatedSprite2D.animation = "bike"
		#$AnimatedSprite2D.flip_h = velocity.x < 0
 
func fall_over():
		is_fallen = true
		velocity = Vector2.ZERO # Stop moving
	
		$AnimatedSprite2D.stop()
		DebugDisplay.log("Panda has fallen! Press Enter to restart.")
		
func finish_level():
		reached_end = true
		velocity = Vector2.ZERO# Stop moving
		$AnimatedSprite2D.stop()
		DebugDisplay.log("You reached the end! Press Enter to restart.")
