extends Node3D

@onready var videos = [
	preload("res://models/video/finishing_position.ogv"),
	preload("res://models/video/no_phones.ogv"),
	preload("res://models/video/offer_others_first.ogv"),
	preload("res://models/video/resting_position.ogv"),
	preload("res://models/video/wait_for_others.ogv")
]
#Main/Scene/videos/Node3D/projector screen/Sceen/SubViewport/SubViewportContainer/VideoStreamPlayer
@onready var player = $Sceen/SubViewport/SubViewportContainer/VideoStreamPlayer


var index := 0
var is_inside:= false;

func print_all_children(node: Node, indent: int = 0) -> void:
	var prefix = "  ".repeat(indent)
	print(prefix + str(node.name) + " <" + str(node.get_class()) + ">")
	for child in node.get_children():
		print_all_children(child, indent + 1)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	if !is_inside:
		index = (index + 1) % videos.size()
		player.stream = videos[index]
		player.play()
		is_inside = true


func _on_interactable_area_button_button_released(button: Variant) -> void:
	is_inside= false # Replace with function body.
