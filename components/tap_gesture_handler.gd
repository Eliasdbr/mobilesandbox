class_name TapGestureHandler
extends Node

## Time window to check for a second tap
@export var double_press_time: float = 0.5
## Time window for the tap to be considered long tap
@export var long_press_time: float = 1.0
## Limit distance (in pixels) in which it is considered a swipe and not a tap
@export var swipe_distance_limit: float = 50.0

var second_press_timer: Timer = Timer.new() 
var long_press_timer: Timer = Timer.new()

var press_started: bool = false
var presses: int = 0

# For swipe detecting
var startPos: Vector2
var currPos: Vector2

signal oneTap()
signal doubleTap()
signal longTap()

func onOneTap() -> void:
	print("Single Tap Detected!	.")
	press_started = false
	presses = 0
	oneTap.emit()

func onDoubleTap() -> void:
	print("Double Tap Detected!	..")
	doubleTap.emit()

func onLongTap() -> void:
	currPos = get_viewport().get_mouse_position()
	if startPos.distance_to(currPos) >= swipe_distance_limit:
		currPos = startPos
		return
	
	presses = 1
	print("Long Tap Detected!	-")
	longTap.emit()

func onSwipeDetected():
	print("Swipe Detected!		>")
	second_press_timer.stop()
	long_press_timer.stop()

func _ready() -> void:
	second_press_timer.autostart = false
	second_press_timer.one_shot = true
	second_press_timer.wait_time = double_press_time
	second_press_timer.timeout.connect(onOneTap)
	add_child(second_press_timer)
	long_press_timer.autostart = false
	long_press_timer.one_shot = true
	long_press_timer.wait_time = long_press_time
	long_press_timer.timeout.connect(onLongTap)
	add_child(long_press_timer)

func _input(event: InputEvent) -> void:
	## On any press
	if event.is_action_pressed("click"):
		#print("Click pressed")
		if press_started: return
		press_started = true
		currPos = get_viewport().get_mouse_position()
		startPos = currPos
		## check if it's the first click
		#print("Second press timer time left: ", second_press_timer.time_left)
		if presses < 1:
			# First click
			long_press_timer.start()
		else:
			# Second click
			second_press_timer.stop()
			long_press_timer.stop()
			onDoubleTap()
	## on any release
	if event.is_action_released("click"):
		#print("Click released")
		press_started = false
		currPos = get_viewport().get_mouse_position()
		# It's not a long press anymore
		long_press_timer.stop()
		# if there's a swipe, abort
		if startPos.distance_to(currPos) >= swipe_distance_limit:
			onSwipeDetected()
			return
		# else, start the timer for the second press
		if presses < 1:
			second_press_timer.start()
			presses += 1
		else:
			presses = 0
			second_press_timer.stop()
			long_press_timer.stop()
		# resets the swipe detecting
		currPos = startPos
