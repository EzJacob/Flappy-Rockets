extends Node

@export var pipe_scene : PackedScene
const ammopath = preload("res://scenes/ammo.tscn")


var game_running : bool
var game_over : bool
var scroll # will be used to move the images on the screen smoothly
var score # score of the game
const SCROLL_SPEED : int = 4 # will make the game slower or faster
var screen_size : Vector2i
var ground_height : int
var pipes : Array
var ammo_array : Array
var ammo_count : int = 0
# values for pipe generation
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

const AMMO_RND_RANGE_X_MIN : int = 100
const AMMO_RND_RANGE_X_MAX : int = 300
const AMMO_RND_RANGE_Y : int = 300

var game_paused : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()


func new_game():
	# reset all values
	game_running = false
	game_over = false
	score = 0
	ammo_count = 0
	scroll = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	$AmmoLabel.text = "AMMO: " + str(ammo_count)
	$AmmoLabel.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	for a in ammo_array:
		if a != null:
			a.queue_free()
	ammo_array.clear()
	generate_pipes_ammo() # generate starting pipes
	$Bird.reset()
	$RulesLabel.add_theme_color_override("font_color", Color(1, 1 ,1 ,1))
	


func _input(event):
	# Handle flapping
	if game_over == false:
		if Input.is_action_just_pressed("ui_select"):
			if game_running == false:
					start_game()
					$RulesLabel.add_theme_color_override("font_color", Color(1, 1 ,1 ,0))
			else:
				if $Bird.flying:
					$Bird.flap()
					check_top()
	
	# Handle shooting
	if game_over == false and game_running and ammo_count > 0:
		if shooting_button(event):
			$Bird.shoot()
			$ShootSound.play()
			ammo_count -= 1
			$AmmoLabel.text = "AMMO: " + str(ammo_count)
			if ammo_count == 0:
				var red_color = Color(1, 0, 0, 1)
				$AmmoLabel.add_theme_color_override("font_color", red_color)
				
				
	# Handle restart game with 'R' key
	if game_over:
		if Input.is_action_just_pressed("KEY_R"):
				new_game()

func shooting_button(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			return true
	elif Input.is_action_just_pressed("KEY_S"):
		return true
	elif Input.is_action_just_pressed("KEY_ENTER"):
		return true
	return false

func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		
		# reset scroll
		if scroll >= screen_size.x:
			scroll = 0
			
		# move ground node
		$Ground.position.x = -scroll
		
		# move pipes and ammo
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED
			
		for a in ammo_array:
			if a != null:
				a.position.x -= SCROLL_SPEED
			


func _on_pipe_timer_timeout():
	generate_pipes_ammo()


func generate_pipes_ammo():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2  + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)
	
	var random_int_range = randi_range(1, 100)
	if random_int_range < 50:
		var rocket = ammopath.instantiate()
		rocket.position.x = pipe.position.x + randi_range(AMMO_RND_RANGE_X_MIN, AMMO_RND_RANGE_X_MAX)
		rocket.position.y = pipe.position.y + randi_range(-AMMO_RND_RANGE_Y, AMMO_RND_RANGE_Y)
		rocket.got_ammo.connect(ammoed)
		add_child(rocket)
		ammo_array.append(rocket)
		
		

func ammoed():
	ammo_count += 1
	$AmmoLabel.text = "AMMO: " + str(ammo_count)
	$AmmoSound.play()
	var green_color = Color(0, 1, 0, 1)
	$AmmoLabel.add_theme_color_override("font_color", green_color)

func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)
	$CoinSound.play()

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()


func stop_game():
	$PipeTimer.stop()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true
	$DeathSound.play()
	


func bird_hit():
	$Bird.falling = true
	stop_game()


func _on_ground_hit():
	$Bird.falling = false
	stop_game()


func _on_game_over_restart():
	new_game()
