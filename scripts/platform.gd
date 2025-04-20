extends StaticBody2D

func _on_hitbox_body_entered(body) -> void:
	self.queue_free()
