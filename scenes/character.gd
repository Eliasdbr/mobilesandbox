extends Node2D

@export var tilemap: TileMapLayer
@export var sprite_texture: Texture2D
@export var stats: CharacterStats

const MOVEMENT_MARGIN = 0.1
# How fast the transition from one tile to another is.
# 0.0 = infinitely slow
# 1.0 = instant
const MOVEMENT_SNAP_CURVE = 0.3

@onready var sprite: Sprite2D = $SpriteAnchor/Sprite2D
@onready var sprite_anchor: Node2D = $SpriteAnchor
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var tile_collision_checker: TileCollisionChecker = $TileCollisionChecker

## --- Movement / Action vars

var isMoving: bool = false
var goBack: bool = false

var tile_pos: Vector2i = Vector2i(8, 8)
var target_tile: Vector2i = Vector2i(8, 8)
var moveFrom: Vector2 = Vector2i(8, 8)
var moveTo: Vector2 = Vector2i(8, 8)

## --- Stats Vars

var health: int
var stamina: int
var armor: int
var mana: int

# Process movement lerp
func process_movement() -> void:
	if isMoving:
		if sprite_anchor.global_position.distance_to(moveTo) > MOVEMENT_MARGIN:
			sprite_anchor.global_position.x = lerpf(
				sprite_anchor.global_position.x, 
				moveTo.x, 
				MOVEMENT_SNAP_CURVE
			)
			sprite_anchor.global_position.y = lerpf(
				sprite_anchor.global_position.y, 
				moveTo.y, 
				MOVEMENT_SNAP_CURVE
			)
		else:
			# If has to go back, swap moveTo and moveFrom
			if goBack:
				goBack = false
				var newMoveTo = moveFrom
				moveFrom = moveTo
				moveTo = newMoveTo
			else:
				tile_pos = target_tile
				position = tilemap.map_to_local(tile_pos)
				sprite_anchor.global_position = position
				isMoving = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets the sprite texture to the exported var
	sprite.texture = sprite_texture
	sprite.hframes = 4
	
	# Sets up the tile collision checker
	tile_collision_checker.tilemap = tilemap
	
	# Gets the position in the tilemap
	position = tilemap.map_to_local(tile_pos)
	animations.speed_scale = MOVEMENT_SNAP_CURVE*4
	
	# Sets up the stats
	health = stats.init_health
	stamina = stats.init_stamina
	armor = stats.init_armor
	mana = stats.init_mana


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	process_movement()
	

# When the character intents to Move/Interact towards a adjacent tile
func _onAction(direction: Vector2) -> void:
	# If its doing something, ignore input
	if isMoving: return
	
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
	var foundCollision = tile_collision_checker.hasCollision(target_tile)
	
	# Animates the sprite movement
	isMoving = true
	moveFrom = tilemap.map_to_local(tile_pos)
	moveTo = tilemap.map_to_local(target_tile)
	var dir = (moveTo - moveFrom).normalized()
	if foundCollision: 
		print("Found collision")
		goBack = true
		moveTo = moveTo - (dir*Tiles.GRID_SIZE/2)
		target_tile = tile_pos
	# sprite_anchor.position = Vector2(moveFrom + moveTo) / 2
	animations.play("Hop")
	
