class_name ItemStats
extends Resource

@export_category("Info")
## Name for the item
@export var name: String = ""
## Description for the item
@export_multiline var description: String = ""
## Tile ID for the graphic to use for the item (check the ItemSet graphic)
@export_range(0,255) var graphicId: int = 0

@export_category("Stats")
## If the character can use this item to do something.
@export var isUsable: bool = false
## If using this item once destroys it.
@export var isConsumable: bool = false
## If the character can hold more than one of this item.
@export var isStackable: bool = true
## Amount of uses this item can have before being destroyed. (Ignored if isConsumable or isStackable is true)
@export_range(1,INF) var health: int = 1

## When used, it allows the character to place a tile on the world.
@export var isPlaceable: bool = false
## If isPlaceable is true, the tile ID to be placed
@export var placeableTile: int = 0
## A list of Tile IDs on which the character can place this placeable item
@export var canBePlacedOn: Array[int] = [0]

## Function that executes when used.
@export var onUse: Callable = func(char: Character): pass
