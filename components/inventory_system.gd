class_name InventorySystem
extends Node

class InventorySlot:
	var item_id: int
	var amount: int

const MAX_SLOTS: int = 9

const dropped_item_scene: PackedScene = preload("res://scenes/item_dropped.tscn")

@onready var world: Node2D = $"../.."

## The inventory will look like this:
## [0][1][2]
## [3][4][5]	The center slot will be the main slot.
## [6][7][8]
var inventory_slots: Array[InventorySlot] = []

signal inventoryChanged(inventory: Array[InventorySlot])

## Gets the ItemStats resource from an item_id
func getResourceFromID(id: int) -> ItemStats:
	if id < 0: return null
	
	var itemStatPath = "res://resources/items/item_%d.tres" % id
	var item = load(itemStatPath)
	
	if item: return item
	else: return null

## Swaps the current item the character is holding with the one 
## indicated on the parameter "index".
## If the main slot and the selected slot share the same item_id,
## Combine the two amounts into the main slot.
func swapWithMainSlot(index: int) -> void:
	# If the index is not valid, return
	if index < 0 or index > 8: return
	
	# If they both share the same ID, add the amount of the selected item to
	# the main item (unless they are not stackable!!)
	## TODO: Check for item stackability
	if inventory_slots[4].item_id == inventory_slots[index].item_id:
		inventory_slots[4].amount += inventory_slots[index].amount
		inventory_slots[index].item_id = -1
		inventory_slots[index].amount = 0
	
	# If they are different item_ids, simply swap them
	var oldMain = inventory_slots[4]	# 4 is the center slot (main)
	inventory_slots[4] = inventory_slots[index]
	inventory_slots[index] = oldMain
	
	# Emit signal that inventory changed
	inventoryChanged.emit(inventory_slots)


## Asks to pick up an item. If the item can be stored, returns true.
## Otherwise, returns false.
func pickUp(item_id: int, amount: int) -> bool:
	print("Picking up ", amount, " of Item ID:", item_id)
	var canBeStored: bool = false
	## First, search for slot with the same type of item
	## TODO: Check for item stackability
	for i in range(len(inventory_slots)):
		if inventory_slots[i].item_id == item_id:
			inventory_slots[i].amount += amount
			canBeStored = true
	
	## Then, search for an empty slot
	for i in range(len(inventory_slots)):
		if inventory_slots[i].item_id == -1:
			inventory_slots[i].item_id = item_id
			inventory_slots[i].amount = amount
			canBeStored = true
			break
	
	# Emit signal that inventory changed
	inventoryChanged.emit(inventory_slots)
	
	## Finally, if everything fails, return false
	print("Could be stored?: ", canBeStored)
	return canBeStored

## Drops the item in the main slot, if empty, return null.
func drop(pos: Vector2i) -> InventorySlot:
	if inventory_slots[4].item_id == -1: return null
	
	var item = inventory_slots[4]
	
	## Place an item in the world
	var item_instance = dropped_item_scene.instantiate()
	var item_res: ItemStats = getResourceFromID(item.item_id)
	item_instance.item = item_res
	item_instance.amount = item.amount
	item_instance.spawn_pos = pos
	world.add_child(item_instance)
	
	inventory_slots[4].item_id = -1
	inventory_slots[4].amount = 0
	
	# Emit signal that inventory changed
	inventoryChanged.emit(inventory_slots)
	
	return item


## Initializes the inventory system
func _ready() -> void:
	## Initialize the inventory
	for i in range(MAX_SLOTS):
		var slot = InventorySlot.new()
		slot.item_id = -1	# empty slot
		slot.amount = 0		# also empty slot
		inventory_slots.append(slot)
