extends GPUParticles3D
signal start_particles

func _ready() -> void:
	connect("start_particles", Callable(self, "_on_start_particles"))
	emitting = false

func _on_start_particles() -> void:
	emitting = true
