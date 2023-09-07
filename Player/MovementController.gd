extends CharacterBody3D
class_name MovementController


@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 1
@export var deceleration := .75
@export_range(0.0, 1.0, 0.05) var air_control := 0.5
@export var jump_height := 10
var direction := Vector3()
var input_axis := Vector2()
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)


# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	
	input_axis = Input.get_vector(&"move_back", &"move_forward",
			&"move_left", &"move_right")
	
	direction_input()
	
	if is_on_floor():
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = jump_height
	else:
		velocity.y -= gravity * delta
	if input_axis.x < 0:
		centripetal_acceleration(delta)
	else:
		
		centripetal_acceleration(delta)
		
	move_and_slide()


func direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration * log(1 + abs(direction.dot(temp_vel)))
	else:
		temp_accel = deceleration   # Applying the deceleration curve
	
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z

func centripetal_acceleration(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	#if left pressed 135degrees if right pressed 45 degrees
	
	input_axis = Input.get_vector(&"move_back", &"move_forward",
			&"move_left", &"move_right")
	var angle = velocity.angle_to(position + Vector3(1,0,0))	
	var new_velocity = velocity
	new_velocity = Vector3(1,0,0).rotated(Vector3(0,1,0), angle) * input_axis.x
	#take the y input + or - and then use that to modify our angle ( for y input do left/right input)
	new_velocity = new_velocity.rotated(Vector3(0,1,0), input_axis.y *deg_to_rad(25)) 
	velocity = new_velocity
	print()
