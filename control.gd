extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	print("Start pressed")
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	print("Settigns pressed")
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	print("Quit pressed")
	get_tree().quit()
	pass # Replace with function body.
