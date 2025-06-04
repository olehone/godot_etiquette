extends RigidBody3D

@export var deletion_zone_group: String = "head"
@export var attach_zone_group: String = "utensils"
@export var attach_offset: Vector3 = Vector3(0, 0.1, 0)
@export var snap_sound: AudioStream
@export var delete_sound: AudioStream
@export_file("*.tscn") var eating_particles_scene: String  # Path to your particle scene

var is_snapped = false

func _ready() -> void:
	if $Area3D:
		$Area3D.connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group(deletion_zone_group):
		_play_delete_effects()
	elif area.is_in_group(attach_zone_group) and not is_snapped:
		_attach_to_utensil(area)

func _attach_to_utensil(area: Area3D) -> void:
	var utensil = area.get_parent()
	if utensil and utensil is RigidBody3D:
		var attach_point = utensil.get_node_or_null("SnapZone")

		# Decide where to attach (world space)
		var target_transform: Transform3D
		if attach_point:
			target_transform = attach_point.global_transform
		else:
			target_transform = utensil.global_transform.translated(attach_offset)

		# Set as top-level to preserve transform temporarily
		set_as_top_level(true)
		global_transform = target_transform

		# Reparent to utensil and convert position/rotation to local
		utensil.add_child(self)
		set_as_top_level(false)  # Return to normal parenting mode

		# Update transform so it stays visually in the same place
		transform.origin = utensil.to_local(target_transform.origin)
		transform.basis = utensil.global_transform.basis.inverse() * target_transform.basis

		# Make static and play sound
		PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
		is_snapped = true
		_play_snap_sound()



func _play_snap_sound() -> void:
	_play_sound(snap_sound)

func _play_sound(stream: AudioStream) -> void:
	var player = $AudioStreamPlayer3D
	if stream and is_instance_valid(player):
		player.stop()
		player.stream = stream
		player.play()

func _play_delete_effects() -> void:
	PhysicsServer3D.body_set_mode(get_rid(), PhysicsServer3D.BODY_MODE_STATIC)
	collision_layer = 0
	collision_mask = 0

	_play_sound(delete_sound)
	_spawn_eat_particles()
	
	await get_tree().create_timer(1.1).timeout
	queue_free()

func _spawn_eat_particles() -> void:
	if eating_particles_scene == "":
		print("No particles scene file assigned.")
		return
	
	var packed_scene = load(eating_particles_scene)
	if packed_scene and packed_scene is PackedScene:
		var particles = packed_scene.instantiate()
		if particles and particles is GPUParticles3D:
			add_child(particles)
			particles.global_transform = global_transform
			particles.emitting = true

			# Schedule auto-remove after 2.0 seconds
			await get_tree().create_timer(2.0).timeout
			if is_instance_valid(particles):
				particles.queue_free()
		else:
			print("The loaded scene is not a GPUParticles3D node.")
	else:
		print("Failed to load scene from path: %s" % eating_particles_scene)


func print_all_children(node: Node, indent: int = 0) -> void:
	print("  ".repeat(indent) + node.name)
	for child in node.get_children():
		if child is Node:
			print_all_children(child, indent + 1)
