extends CharacterBody3D
class_name MovementController


@export var fmod_land_event: EventAsset
@export var fmod_jump_event: EventAsset
@export var fmod_move_event: EventAsset
var move_instance: EventInstance
var attributes: FMOD_3D_ATTRIBUTES = FMOD_3D_ATTRIBUTES.new()


@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 1
@export var deceleration := .75
@export_range(0.0, 1.0, 0.05) var air_control := 0.5
@export var jump_height := 10
var direction := Vector3()
var input_axis := Vector2()
var current_state = ""
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)


func _ready():
	move_instance = RuntimeManager.create_instance(fmod_move_event)
	move_instance.start()


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
	
	if Input.is_action_just_pressed("skate_walk"):
		#know current state, change to the opposite, so if skate is 1 then make it 2, if walk is 2
		if current_state == "Walking":
			$StateMachinePlayer.set_trigger("on_board")
		if current_state == "Skating":
			$StateMachinePlayer.set_trigger("off_board")
	else:
		pass
	
	
	if current_state == "Walking":
		walking(delta)
	if current_state == "Skating":
		skating(delta)
		if velocity.length() > 1 and is_on_floor():
			move_instance.set_parameter_by_name("speed", clamp(velocity.length() * 2, 0.0, 20.0), false)
		else:
			# force mute
			move_instance.set_parameter_by_name("speed", 0.0, false)
		
		if is_on_floor():
			if Input.is_action_just_pressed(&"jump"):
				RuntimeManager.play_one_shot_attached(fmod_jump_event, self)
				
		else:
			(func(): if is_on_floor(): RuntimeManager.play_one_shot_attached(fmod_land_event, self)).call_deferred()
		
	move_and_slide()


func direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	direction = aim.z * -input_axis.x + aim.x * input_axis.y


func walking(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity / 1.05
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration 
	else:
		temp_accel = deceleration   # Applying the deceleration curve
	
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	
func skating(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity * 1.05
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = 10 * acceleration * log(1 + abs(direction.dot(temp_vel)))
	else:
		temp_accel = deceleration   # Applying the deceleration curve
	
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z

#func centripetal_acceleration(delta: float) -> void:
#	# Using only the horizontal velocity, interpolate towards the input.
#	#if left pressed 135degrees if right pressed 45 degrees
#
#	input_axis = Input.get_vector(&"move_back", &"move_forward",
#			&"move_left", &"move_right")
#	var angle = velocity.angle_to(position + Vector3(1,0,0))	
#	var new_velocity = velocity
#	new_velocity = Vector3(1,0,0).rotated(Vector3(0,1,0), angle) * input_axis.x + new_velocity
#	#take the y input + or - and then use that to modify our angle ( for y input do left/right input)
#	new_velocity = new_velocity.rotated(Vector3(0,1,0), input_axis.y *-1 *deg_to_rad(180*delta/2)) 
#	velocity = new_velocity
#
#func WIPskating(delta: float) -> void:
#	# Using only the horizontal velocity, interpolate towards the input.
#	input_axis = Input.get_vector(&"move_back", &"move_forward",
#			&"move_left", &"move_right")
#	var angle = velocity.angle_to(position + Vector3(1,0,0))	
#	var new_velocity = velocity
#	var temp_vel := velocity
#	temp_vel.y = 0
#
#	var temp_accel: float
#	var target: Vector3 = direction * speed
#	if direction.dot(new_velocity) > 0:
#		temp_accel = acceleration * log(1 + abs(direction.dot(new_velocity)))
#	else:
#		temp_accel = deceleration   # Applying the deceleration curve
#	if not is_on_floor():
#		temp_accel *= air_control
#	temp_vel = temp_vel.lerp(target, temp_accel * delta)
#
#	new_velocity = Vector3(1,0,0).rotated(Vector3(0,1,0), angle) * input_axis.x + new_velocity
#	#take the y input + or - and then use that to modify our angle ( for y input do left/right input)
#	new_velocity = new_velocity.rotated(Vector3(0,1,0), input_axis.y *-1 *deg_to_rad(180*delta)) 
#	new_velocity = new_velocity.clamp(Vector3(-5,-100,-10),Vector3(5,100,10))
#
#	velocity.z = new_velocity.z
#	velocity.x = temp_vel.x

func _on_state_machine_player_transited(from, to):
	current_state = to
