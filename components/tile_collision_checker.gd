class_name TileCollisionChecker
extends Node

@export var tilemap: TileMapLayer

func hasCollision(tile_pos: Vector2i) -> bool:
	var tile = tilemap.get_cell_tile_data(tile_pos)
	if tile == null: return false
	return tile.get_custom_data('isObstacle')
	
