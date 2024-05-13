extends CharacterBody3D

@onready var label = %Label3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	rename.rpc()
	if not is_multiplayer_authority():
		return
	
	label.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	%Camera3D.current = true

@rpc("call_local")
func rename() -> void:
	label.text = Manager.nick

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


const MOUSE_SPEED = 0.005

func _unhandled_input(event):
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SPEED)
		%Camera3D.rotate_x(-event.relative.y * MOUSE_SPEED)
		%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, -PI/2, PI/2)
	elif event.is_action_pressed("shoot"):
		shoot.rpc()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()


@onready var raycast: RayCast3D = %RayCast3D
@onready var shoot_sound = %ShootSound
@onready var kill_sound = %KillSound

@rpc("call_local")
func shoot():
	%Laser.visible = true
	shoot_sound.play()
	if raycast.is_colliding():
		var hit_player = raycast.get_collider()
		if hit_player == self:
			return
		kill_sound.play()
		hit_player.position = Vector3(0, 5, 0)
	await get_tree().create_timer(0.1).timeout
	%Laser.visible = false
