extends CanvasLayer

@export_range(1.0, 2.0) var ui_scale = 1.5

@onready var margin_container: MarginContainer = $MarginContainer

@onready var hp_bar: HFlowContainer = $MarginContainer/StatsContainer/HPBar
@onready var sp_bar: HFlowContainer = $MarginContainer/StatsContainer/SPBar
@onready var dp_bar: HFlowContainer = $MarginContainer/StatsContainer/DPBar
@onready var mp_bar: HFlowContainer = $MarginContainer/StatsContainer/MPBar

func update_hp(value: int):
	hp_bar.update_value(value)

func update_sp(value: int):
	sp_bar.update_value(value)

func update_dp(value: int):
	dp_bar.update_value(value)

func update_mp(value: int):
	mp_bar.update_value(value)

func update_inventory(inventory: Array[InventorySystem.InventorySlot]):
	pass

func _ready() -> void:
	margin_container.size = get_viewport().size / ui_scale
	margin_container.scale = Vector2(1,1) * ui_scale
	
