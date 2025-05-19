# File: addons/separate_importer/separate_importer.gd
tool
extends EditorScript

func _run():
	var base_scene_path := "res://path_to_your_scene/your_scene.tscn"
	var save_folder := "res://separated_parts/"

	var scene := load(base_scene_path)
	if not scene:
		push_error("Failed to load scene.")
		return

	var scene_instance := scene.instantiate()
	if not scene_instance:
		push_error("Failed to instantiate scene.")
		return

	DirAccess.make_dir_recursive_absolute(save_folder)

	for child in scene_instance.get_children():
		if not (child is Node):
			continue

		var new_scene := PackedScene.new()
		var new_node := child.duplicate()
		new_scene.pack(new_node)

		var clean_name := child.name.replace(" ", "_").strip_edges()
		var save_path := save_folder + clean_name + ".tscn"

		var error := ResourceSaver.save(new_scene, save_path)
		if error != OK:
			push_error("Failed to save: " + save_path)

	print("Export complete.")
