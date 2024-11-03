class_name SwipeMovement
extends Node

@export var targetLength = 100.0

var startPos: Vector2
var currPos: Vector2
var isSwiping: bool = false

signal onSwipe(direction: Vector2)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if not isSwiping:
			isSwiping = true
			startPos = get_viewport().get_mouse_position()
			# print("Swipe started")
		
	if Input.is_action_pressed("click") and isSwiping:
		currPos = get_viewport().get_mouse_position()
		if startPos.distance_to(currPos) >= targetLength:
			var swipeVector = currPos - startPos
			# print("Swipe detected")
			# Horizontal Swipe
			if abs(swipeVector.x) > abs(swipeVector.y):
				if swipeVector.x > 0:
					# print("Swipe RIGHT")
					onSwipe.emit(Vector2.RIGHT)
				else:
					# print("Swipe LEFT")
					onSwipe.emit(Vector2.LEFT)
			# Vertical Swipe
			else:
				if swipeVector.y > 0:
					# print("Swipe DOWN")
					onSwipe.emit(Vector2.DOWN)
				else:
					# print("Swipe UP")
					onSwipe.emit(Vector2.UP)
			isSwiping = false
	else:
		isSwiping = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_up"):
		onSwipe.emit(Vector2.UP)
	if event.is_action_pressed("action_down"):
		onSwipe.emit(Vector2.DOWN)
	if event.is_action_pressed("action_left"):
		onSwipe.emit(Vector2.LEFT)
	if event.is_action_pressed("action_right"):
		onSwipe.emit(Vector2.RIGHT)
