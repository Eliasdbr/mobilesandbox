class_name CharacterCollisionChecker
extends Node

@export var world: GameWorld

func hasCollision(tile_pos: Vector2i) -> bool: 
	# Checks for character collision
	return world.loadedCharacters.has(tile_pos)

func getCollidingCharacter(tile_pos: Vector2i) -> Character:
	var char_id = world.loadedCharacters.get(tile_pos)
	if (char_id != null):
		return instance_from_id(char_id)
	else:
		return null
