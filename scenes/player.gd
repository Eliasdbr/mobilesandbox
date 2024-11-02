extends Node2D

@export var sprite: Sprite2D
@export var sprite_anchor: Node2D
@export var tile_collision_checker: TileCollisionChecker
@export var tilemap: TileMapLayer
@export var animations: AnimationPlayer

@export var MOVEMENT_DISTANCE = 16.0

const MOVEMENT_MARGIN = 0.1
# How fast the transition from one tile to another is.
# 0.0 = infinitely slow
# 1.0 = instant
const MOVEMENT_SNAP_CURVE = 0.3

var isMoving: bool = false

var tile_pos: Vector2i = Vector2i.ZERO
var target_tile: Vector2i = Vector2i.ZERO

# Process movement lerp
func process_movement() -> void:
	if sprite_anchor.global_position.distance_to(position) > MOVEMENT_MARGIN:
		sprite_anchor.global_position.x = lerpf(
			sprite_anchor.global_position.x, 
			position.x, 
			MOVEMENT_SNAP_CURVE
		)
		sprite_anchor.global_position.y = lerpf(
			sprite_anchor.global_position.y, 
			position.y, 
			MOVEMENT_SNAP_CURVE
		)
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Gets the position in the tilemap
	position = tilemap.map_to_local(tile_pos)
	animations.speed_scale = MOVEMENT_SNAP_CURVE*4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	process_movement()
	

func _onSwipe(direction: Vector2) -> void:
	# Get the position of the next tile
	target_tile = tile_pos + Vector2i(direction)
	
	# Turns the sprite
	if sprite:
		match(direction):
			Vector2.DOWN:
				sprite.frame = 0
			Vector2.UP:
				sprite.frame = 1
			Vector2.RIGHT:
				sprite.frame = 2
			Vector2.LEFT:
				sprite.frame = 3
	
	# Checks for tile collision
	if tile_collision_checker.hasCollision(target_tile):
		print("Found collision")
		return
	
	# Animates the sprite movement
	var moveFrom = tilemap.map_to_local(tile_pos)
	var moveTo = tilemap.map_to_local(target_tile)
	sprite_anchor.position = Vector2(moveFrom - moveTo)
	animations.play("Hop")
	
	# If there is no collision tile ahead, move
	tile_pos = target_tile
	position = tilemap.map_to_local(tile_pos)
	
