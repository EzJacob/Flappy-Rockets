extends Area2D


signal hit
signal scored


func _on_body_entered(body):
	if body.name == "Bird":
		hit.emit()
	else:
		if $".".global_position.y < body.global_position.y:
			delete_bodies($Lower, $CollisionShape2D, $CollisionShape2D2)
		else:
			delete_bodies($Upper, $CollisionShape2D3 ,$CollisionShape2D4)
		body.queue_free()
		$AudioStreamPlayer.play()
		
func delete_bodies(body1, body2, body3):
	if body1 != null:
		body1.queue_free()
	if body2 != null:
		body2.queue_free()
	if body3 != null:
		body3.queue_free()  


func _on_score_area_body_entered(body):
	if body.name == "Bird":
		scored.emit()
		
	
