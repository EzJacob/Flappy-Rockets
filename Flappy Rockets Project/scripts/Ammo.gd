extends Area2D

signal got_ammo

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_body_entered(body):
	if body.name == "Bird":
		got_ammo.emit()
		$".".queue_free()
