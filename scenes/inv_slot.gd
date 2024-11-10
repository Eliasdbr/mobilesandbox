extends Button

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var amount_label: Label = $AmountLabel

@export_range(-1,255) var graphic_id: int = -1:
	set(gid):
		graphic_id = gid
		update_slot()

@export_range(0,255) var amount: int = 0:
	set(a):
		amount = a
		update_slot()

@export var is_selected: bool = false:
	set(s):
		is_selected = s
		update_slot()

@export var slot_id: int = 0

## Clicked this button and selected this item
signal selectedSlot(slot_index: int)

## Updates all the graphics based on property changes
func update_slot() -> void:
	if (not sprite_2d or not amount_label): return
	# Item icon and label visibility
	sprite_2d.visible = graphic_id >= 0 and amount > 0
	amount_label.visible = graphic_id >= 0 and amount > 1
	
	# Updates selected state
	if is_selected:
		self_modulate = Color(3.0, 3.0, 3.0)
	else:
		self_modulate = Color(1.0, 1.0, 1.0)
	
	# If there's no item, return
	if graphic_id <= -1 and amount <= 0: return
	
	# Updates sprite frame
	sprite_2d.frame = graphic_id
	
	# Updates the label number
	amount_label.text = str(amount)
	
func _ready() -> void:
	update_slot()

func _pressed() -> void:
	selectedSlot.emit(slot_id)
