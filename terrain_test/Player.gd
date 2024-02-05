extends CharacterBody3D

@export var mouse_sensitivity = 0.002

@onready var camera = get_node("Camera3D")
@onready var globals = get_node("/root/Globals")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var flying_mode = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	
	var speed
	
	if flying_mode:
		speed = SPEED * 2
	else:
		speed = SPEED
	# Add the gravity.
	if not flying_mode:
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# print("direction: ", direction, ", camera.rotation: ", camera.rotation)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if flying_mode:
			if Input.is_action_pressed("forward"):
				velocity.y = camera.rotation.x * speed
			if Input.is_action_pressed("backwards"):
				velocity.y = (camera.rotation.x - 2 * camera.rotation.x) * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if Input.is_action_pressed("left") and not Input.is_action_pressed("look"):
		rotate_y(0.025)
		
	if Input.is_action_pressed("right") and not Input.is_action_pressed("look"):
		rotate_y(-0.025)
		
	if flying_mode:
		if Input.is_action_pressed("rise"):
			velocity.y = speed
		elif Input.is_action_pressed("fall"):
			velocity.y = speed - (speed * 2)
		elif not direction:			
			velocity.y = move_toward(velocity.y, 0, speed)
		
	if position.y < -2:
		position = Vector3(0, 2, 0)
		
	move_and_slide()	
		
		

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("look"):
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y  * mouse_sensitivity)
		
