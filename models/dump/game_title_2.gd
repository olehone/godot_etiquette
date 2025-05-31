extends Label

func _ready():
	var tween = get_tree().create_tween()
	tween.set_loops() # infinite loop
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(Callable(self, "_update_font_size"), 90.0, 100.0, 0.25)
	tween.tween_method(Callable(self, "_update_font_size"), 100.0, 90.0, 0.25)


func _update_font_size(size):
	var font = preload("res://fonts/joystix/joystix_font.tres").duplicate()
	self.add_theme_font_override("font", font)
	self.add_theme_font_size_override("font_size", int(size))
