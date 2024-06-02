extends CharacterBody2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600 # max velocity for fall speed
const FLAP_SPEED : int = -500 # how much the bird will jump up
var flying : bool = false
var falling : bool = false
const START_POS = Vector2(100, 400)
const bulletpath = preload("res://scenes/bullet.tscn")
const bullet_start_factor : int = 50
var bullets : Array
# Called when the node enters the scene for the first time.
func _ready():
	reset()


func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	for body in bullets:
		if body != null:
			body.queue_free()
	bullets.clear()


# Called every frame. 'delta' is the elasped time since the previous frame.
func _physics_process(delta):
	
	# Add the gravity.
	if flying or falling:
		velocity.y += GRAVITY * delta
		
		# terminal velocity
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
	
	
		# if brid is flying
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play()
		# if bird is falling
		elif falling: 
			set_rotation(PI / 2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
		
	else:
		$AnimatedSprite2D.stop()


# Handle Jump.
func flap():
	velocity.y = FLAP_SPEED

# Handle Shooting.
func shoot():
	var bullet = bulletpath.instantiate()
	
	get_parent().add_child(bullet)
	bullets.append(bullet)
	
	bullet.position = $Weapon.global_position
	bullet.position.x += bullet_start_factor
	
