extends CanvasLayer

@export_range(1.0, 2.0) var ui_scale = 1.5

@onready var margin_container: MarginContainer = $MarginContainer

@onready var hp_bar: HFlowContainer = $MarginContainer/StatsContainer/HPBar
@onready var sp_bar: HFlowContainer = $MarginContainer/StatsContainer/SPBar
@onready var dp_bar: HFlowContainer = $MarginContainer/StatsContainer/DPBar
@onready var mp_bar: HFlowContainer = $MarginContainer/StatsContainer/MPBar

@onready var inventory_container: GridContainer = $MarginContainer/InventoryContainer
@onready var inv_slot_0: Panel = $MarginContainer/InventoryContainer/InvSlot_0
@onready var inv_slot_1: Panel = $MarginContainer/InventoryContainer/InvSlot_1
@onready var inv_slot_2: Panel = $MarginContainer/InventoryContainer/InvSlot_2
@onready var inv_slot_3: Panel = $MarginContainer/InventoryContainer/InvSlot_3
@onready var inv_slot_4: Panel = $MarginContainer/InventoryContainer/InvSlot_4
@onready var inv_slot_5: Panel = $MarginContainer/InventoryContainer/InvSlot_5
@onready var inv_slot_6: Panel = $MarginContainer/InventoryContainer/InvSlot_6
@onready var inv_slot_7: Panel = $MarginContainer/InventoryContainer/InvSlot_7
@onready var inv_slot_8: Panel = $MarginContainer/InventoryContainer/InvSlot_8

var inv_slots = [
	inv_slot_0,
	inv_slot_1,
	inv_slot_2,
	inv_slot_3,
	inv_slot_4,
	inv_slot_5,
	inv_slot_6,
	inv_slot_7,
	inv_slot_8
]

func update_hp(value: int):
	hp_bar.update_value(value)

func update_sp(value: int):
	sp_bar.update_value(value)

func update_dp(value: int):
	dp_bar.update_value(value)

func update_mp(value: int):
	mp_bar.update_value(value)


func update_inventory(inventory: Array[InventorySystem.InventorySlot]):
	if inv_slots[0]:
		for i in range(len(inv_slots)):
			inv_slots[i].graphic_id = inventory[i].item_id
			inv_slots[i].amount = inventory[i].amount


func update_inv_selected(selected_idx = 4):
	if inv_slots[0]:
		for i in range(len(inv_slots)):
			inv_slots[i].is_selected = selected_idx == i


func _ready() -> void:
	margin_container.size = get_viewport().size / ui_scale
	margin_container.scale = Vector2(1,1) * ui_scale
	
