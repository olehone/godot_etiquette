@tool
class_name XRToolsSnapZone
extends Area3D

@export var accepted_group: String = "food"

signal has_picked_up(what)
signal has_dropped
signal highlight_updated(pickable, enable)
signal close_highlight_updated(pickable, enable)

enum SnapMode {
	DROPPED,
	RANGE,
}

@export var enabled : bool = true: set = _set_enabled
@export var stash_sound : AudioStream
@export var grab_distance : float = 0.3: set = _set_grab_distance
@export var snap_mode : SnapMode = SnapMode.DROPPED: set = _set_snap_mode
@export var snap_require : String = ""
@export var snap_exclude : String = ""
@export var grab_require : String = ""
@export var grab_exclude : String = ""
@export var initial_object : NodePath

var closest_object : Node3D = null
var picked_up_object : Node3D = null
var picked_up_ranged : bool = true

var _object_in_grab_area = Array()

# For restoring collisions
var _original_collision_layer: int = 1
var _original_collision_mask: int = 1

func is_xr_class(name : String) -> bool:
	return name == "XRToolsSnapZone"

func _ready():
	if has_node("CollisionShape3D") and "radius" in $CollisionShape3D.shape:
		$CollisionShape3D.shape.radius = grab_distance

	if not body_entered.is_connected(_on_snap_zone_body_entered):
		body_entered.connect(_on_snap_zone_body_entered)
	if not body_exited.is_connected(_on_snap_zone_body_exited):
		body_exited.connect(_on_snap_zone_body_exited)

	_update_snap_mode()

	if not Engine.is_editor_hint():
		_initial_object_check.call_deferred()

func _process(_delta):
	if Engine.is_editor_hint() or not enabled:
		return
	if snap_mode != SnapMode.RANGE:
		return
	if is_instance_valid(picked_up_object):
		return

	for o in _object_in_grab_area:
		if not o.can_pick_up(self):
			continue
		pick_up_object(o)
		return

func can_pick_up(by: Node3D) -> bool:
	if not enabled:
		return false
	if not is_instance_valid(picked_up_object):
		return false
	if not grab_require.is_empty() and not by.is_in_group(grab_require):
		return false
	if not grab_exclude.is_empty() and by.is_in_group(grab_exclude):
		return false
	return true

func is_picked_up() -> bool:
	return false

func action():
	pass

func request_highlight(from : Node, on : bool = true) -> void:
	if is_instance_valid(picked_up_object):
		picked_up_object.request_highlight(from, on)

func pick_up(_by: Node3D) -> void:
	pass

func let_go(_by: Node3D, _p_linear_velocity: Vector3, _p_angular_velocity: Vector3) -> void:
	pass

func drop_object() -> void:
	if not is_instance_valid(picked_up_object):
		return

	if picked_up_object.is_in_group(accepted_group) and picked_up_object.has_method("set_collision_layer"):
		picked_up_object.collision_layer = _original_collision_layer
		picked_up_object.collision_mask = _original_collision_mask

	picked_up_object.let_go(self, Vector3.ZERO, Vector3.ZERO)
	picked_up_object = null
	has_dropped.emit()
	highlight_updated.emit(self, enabled)

func _initial_object_check() -> void:
	if initial_object:
		pick_up_object(get_node(initial_object))
	else:
		highlight_updated.emit(self, enabled)

func _on_snap_zone_body_entered(target: Node3D) -> void:
	if _object_in_grab_area.find(target) >= 0:
		return
	if not target.has_method('pick_up'):
		return
	if not snap_require.is_empty() and not target.is_in_group(snap_require):
		return
	if not snap_exclude.is_empty() and target.is_in_group(snap_exclude):
		return
	if target is XRToolsClimbable:
		return

	_object_in_grab_area.push_back(target)

	if snap_mode == SnapMode.DROPPED and target.has_signal("dropped"):
		target.connect("dropped", _on_target_dropped, CONNECT_DEFERRED)

	if not is_instance_valid(picked_up_object):
		close_highlight_updated.emit(self, enabled)

func _on_snap_zone_body_exited(target: Node3D) -> void:
	_object_in_grab_area.erase(target)

	if target.has_signal("dropped") and target.is_connected("dropped", _on_target_dropped):
		target.disconnect("dropped", _on_target_dropped)

	if _object_in_grab_area.is_empty():
		close_highlight_updated.emit(self, false)

func has_snapped_object() -> bool:
	return is_instance_valid(picked_up_object)

func pick_up_object(target: Node3D) -> void:
	if is_instance_valid(picked_up_object):
		if picked_up_object == target:
			return
		drop_object()

	if not is_instance_valid(target):
		return

	if target.is_in_group(accepted_group) and target.has_method("set_collision_layer"):
		_original_collision_layer = target.collision_layer
		_original_collision_mask = target.collision_mask
		target.collision_layer = 0
		target.collision_mask = 0

	picked_up_object = target

	if has_node("AudioStreamPlayer3D"):
		var player = get_node("AudioStreamPlayer3D")
		if is_instance_valid(player):
			if player.playing:
				player.stop()
			player.stream = stash_sound
			player.play()

	target.pick_up(self)

	if is_instance_valid(picked_up_object):
		has_picked_up.emit(picked_up_object)
		highlight_updated.emit(self, false)

func _set_enabled(p_enabled: bool) -> void:
	enabled = p_enabled
	if is_inside_tree:
		highlight_updated.emit(self, enabled and not is_instance_valid(picked_up_object))

func _set_grab_distance(new_value: float) -> void:
	grab_distance = new_value
	if is_inside_tree() and $CollisionShape3D:
		$CollisionShape3D.shape.radius = grab_distance

func _set_snap_mode(new_value: SnapMode) -> void:
	snap_mode = new_value
	if is_inside_tree():
		_update_snap_mode()

func _update_snap_mode() -> void:
	match snap_mode:
		SnapMode.DROPPED:
			set_process(false)
			for o in _object_in_grab_area:
				o.connect("dropped", _on_target_dropped, CONNECT_DEFERRED)
		SnapMode.RANGE:
			set_process(true)
			for o in _object_in_grab_area:
				o.disconnect("dropped", _on_target_dropped)

func _on_target_dropped(target: Node3D) -> void:
	if not enabled:
		return
	if is_instance_valid(picked_up_object):
		return
	if not is_instance_valid(target):
		return
	if target.can_pick_up(self):
		pick_up_object(target)
