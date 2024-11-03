class_name AIBase
extends Node

## Think period, in seconds
@export_range(0.2, 10.0) var think_period: float = 1.0
## Vision area, in pixels
@export_range(1.0,1000.0) var vision_radius: float = 16.0

var controlling_char: Node2D

var think_cooldown: float = think_period
var target: Vector2

signal sendAction(direction: Vector2)

func setTarget(pos: Vector2) -> void:
	target = pos

func _think():
	var goTo = [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT,
	].pick_random()
	
	sendAction.emit(goTo)

func _ready() -> void:
	# Controlling character. Should be its direct parent.
	controlling_char = get_parent()
	if controlling_char.has_method('_onAction'):
		sendAction.connect(controlling_char._onAction)

func _process(delta: float) -> void:
	if think_cooldown <= 0.0:
		think_cooldown = think_period
		_think()
	else:
		think_cooldown -= delta
