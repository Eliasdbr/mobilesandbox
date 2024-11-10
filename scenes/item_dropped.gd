extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var tilemap: TileMapLayer

@export var item: ItemStats:
	set(i):
		item = i
		update_sprite()

@export var amount: int = 1

@export var spawn_pos: Vector2i

func update_sprite():
	if (sprite_2d):
			sprite_2d.frame = item.graphicId

func _ready() -> void:
	if tilemap:
		global_position = tilemap.map_to_local(spawn_pos)
	update_sprite()
