extends Area3D

@export var group_to_delete: String = "food"

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(group_to_delete):
		if body.has_method("drop"):
			body.drop()
		body.queue_free()
