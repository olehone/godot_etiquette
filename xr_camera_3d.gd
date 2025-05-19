extends XRCamera3D

var is_hmd_connected := false
var sensitivity := 0.007 # Чутливість миші
var rotation_x := 0.0
var rotation_y := 0.0
var max_pitch := 70.0 # Обмеження на вертикальний поворот, в градусах

func _ready() -> void:
	# Перевірка наявності HMD
	var xr_interface = XRServer.find_interface('OpenXR')
	if xr_interface and xr_interface.is_initialized():
		is_hmd_connected = true
		print("HMD connected.")
	else:
		is_hmd_connected = false
		print("No HMD connected, using mouse controls.")
	
	# Якщо немає HMD, дозволяємо рухати камеру мишкою
	"""
	if not is_hmd_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if not is_hmd_connected:
		handle_mouse_look(delta)

# Обробка руху миші для керування камерою
func handle_mouse_look(delta: float) -> void:
	var mouse_delta = Input.get_last_mouse_velocity()
	
	rotation_y -= mouse_delta.x * sensitivity # Поворот по горизонталі
	rotation_x -= mouse_delta.y * sensitivity # Поворот по вертикалі

	# Обмеження вертикального повороту
	rotation_x = clamp(rotation_x, -max_pitch, max_pitch)

	# Оновлення повороту камери
	rotation_degrees = Vector3(rotation_x, rotation_y, 0)
	"""
