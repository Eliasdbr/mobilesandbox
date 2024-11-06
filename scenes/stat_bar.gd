extends HFlowContainer

const stat_icon_scene: PackedScene = preload("res://scenes/stat_icon.tscn")

## Determines which icon to show
@export_enum(
	"Health",
	"Stamina",
	"Armor",
	"Mana"
) var type: int = 0

## Max possible stat value. Should be an even number
@export_range(2,20,2,"hide_slider") var max_value: int = 10:
	set(m_v):
		max_value = m_v
		## Deletes previous icons
		for child in get_children():
			child.queue_free()
		## And starts again
		create_icons()

## Current stat value. Shouldn't be greater than max_value. 
@export_range(0,20) var value: int = 5:
	set(v):
		value = v
		update_icons()


## Updates the current icons
func update_icons():
	visible = (value < max_value and value > 0)
	var i = 0
	for child in get_children():
		if value >= i*2+2:
			child.value = 2
		elif value == i*2+1:
			child.value = 1
		else:
			child.value = 0
		i+=1

## Creates a StatIcon for each 2 points of max_value.
func create_icons() -> void:
	visible = (value < max_value and value > 0)
	for i in range(max_value / 2):
		var instance = stat_icon_scene.instantiate()
		
		instance.type = type
		
		if value >= i*2+2:
			instance.value = 2
		elif value == i*2+1:
			instance.value = 1
		else:
			instance.value = 0
			
		add_child(instance)

## Changes its maximum value
func update_max_value(val: int) -> void:
	max_value = val

## Changes its value
func update_value(val: int) -> void:
	value = val

func _ready() -> void:
	create_icons()
