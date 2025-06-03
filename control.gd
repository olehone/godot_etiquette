extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	var scene_base : XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	if not scene_base:
		return
	scene_base.load_scene("res://scenes/restaurant/main.tscn")



func _on_settings_pressed() -> void:
	$Main_Elements.visible = false
	$Settings.visible = true
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	var scene_base : XRToolsStaging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging")
	if not scene_base:
		return
	scene_base.load_scene("res://scenes/main_menu/main_menu.tscn")


func _on_reload_pressed() -> void:
	print("Start pressed")
	var scene_base : XRToolsSceneBase = XRTools.find_xr_ancestor(self, "*", "XRToolsSceneBase")
	if not scene_base:
		print("No base scene")
		return

	# Request loading the next scene
	print("Load next scene")
	#scene_base.load_scene("res://scenes/restaurant/main.tscn")
	scene_base.load_scene("res://scenes/main_menu/main_menu_ui.tscn")
	print("Scene loaded")
	pass # Repl


func _on_back_pressed() -> void:
	$Main_Elements.visible = true
	$Settings.visible = false
	pass # Replace with function body.
