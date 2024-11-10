class_name Character
extends Node2D

@export var tilemap: TileMapLayer
@export var sprite_texture: Texture2D
@export var stats: CharacterStats
@export var spawn_pos: Vector2i = Vector2i(0, 0)

const MOVEMENT_MARGIN = 0.1
# How fast the transition from one tile to another is.
# 0.0 = infinitely slow
# 1.0 = instant
const MOVEMENT_SNAP_CURVE = 0.3

@onready var sprite: Sprite2D = $SpriteAnchor/Sprite2D
@onready var sprite_anchor: Node2D = $SpriteAnchor
@onready var anim_ch1: AnimationPlayer = $AnimationPlayer1
@onready var anim_ch2: AnimationPlayer = $AnimationPlayer2
@onready var tile_collision_checker: TileCollisionChecker = $TileCollisionChecker
@onready var char_collision_checker: CharacterCollisionChecker = $CharacterCollisionChecker
@onready var inventory_system: InventorySystem = $InventorySystem
@onready var world: GameWorld = $".."
@onready var pickup_detector: Area2D = $PickupDetector

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

## Stamina regeneration period in seconds per point regenerated
var stamina_cooldown: float = 1.0

signal healthChanged(health: int)
signal staminaChanged(stamina: int)
signal armorChanged(armor: int)
signal manaChanged(mana: int)


## Get Hit
func getHit(damage: int) -> void:
	print("Character ", get_instance_id(), " got hit: ", damage)
	anim_ch2.play("Hurt")
	health -= damage
	healthChanged.emit(health)

## Spend stamina
func useEnergy(cost: int) -> void:
	stamina -= cost
	staminaChanged.emit(stamina)

# Process movement lerp
func process_movement() -> void:
	## Movement
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
				sprite_anchor.global_position = position
				isMoving = false

## Process the stamina regeneration
func process_stamina(delta: float) -> void:
	if stamina >= stats.max_stamina: return
	
	if stamina_cooldown <= 0.0:
		stamina += 1
		stamina_cooldown = stats.regen_stamina
		#print("cooldown time: ", stats.regen_stamina)
		
		staminaChanged.emit(stamina)
	else:
		stamina_cooldown -= delta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets the sprite texture to the exported var
	sprite.texture = sprite_texture
	sprite.hframes = 4
	
	# Sets up the tile collision checker
	tile_collision_checker.tilemap = tilemap
	# Sets up the character collision checker
	char_collision_checker.world = world
	
	# Gets the position in the tilemap
	tile_pos = spawn_pos
	position =  tilemap.map_to_local(tile_pos)
	anim_ch1.speed_scale = MOVEMENT_SNAP_CURVE*4
	
	# Sets up the stats
	health = stats.init_health
	stamina = stats.init_stamina
	armor = stats.init_armor
	mana = stats.init_mana
	print("Initial stamina regen: ", stats.regen_stamina)
	stamina_cooldown = stats.regen_stamina
	
	# Add to the characters dictionary
	world.loadedCharacters[tile_pos] = get_instance_id()

## Before removing this character
func _exit_tree() -> void:
	# Deletes this character from the world's character dictionary
	world.loadedCharacters.erase(tile_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_stamina(delta)
	process_movement()

# When the character intents to Move/Interact towards a adjacent tile
func _onAction(direction: Vector2) -> void:
	# If its doing something or is tired, ignore input
	if isMoving or stamina <= 0: return
	
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
	var foundTileCollision = tile_collision_checker.hasCollision(target_tile)
	var foundCharCollision = char_collision_checker.hasCollision(target_tile)
	
	# Animates the sprite movement
	isMoving = true
	moveFrom = tilemap.map_to_local(tile_pos)
	moveTo = tilemap.map_to_local(target_tile)
	var dir = (moveTo - moveFrom).normalized()
	if foundTileCollision or foundCharCollision: 
		print("Found collision")
		# Attack the other character
		if foundCharCollision:
			char_collision_checker.getCollidingCharacter(target_tile).getHit(1)
			# Attacking costs 2 stamina
			useEnergy(2)
		goBack = true
		moveTo = moveTo - (dir*Tiles.GRID_SIZE/2)
		target_tile = tile_pos
	else:
		# Updates the world's character pos
		world.loadedCharacters.erase(tile_pos)
		world.loadedCharacters[target_tile] = get_instance_id()
		tile_pos = target_tile
		position = tilemap.map_to_local(tile_pos)
		sprite_anchor.global_position = moveFrom
		# Moving costs 1 stamina
		useEnergy(1)
	# sprite_anchor.position = Vector2(moveFrom + moveTo) / 2
	anim_ch1.play("Hop")
	

## Pickup/Drop action
func onPickUpDrop() -> void:
	## Can't pickup or drop an item if it's moving.
	if isMoving: return
	
	## Get if an item is below the character
	var item_areas = pickup_detector.get_overlapping_areas()
	## If there's an item on the floor:
	if len(item_areas) > 0:
		print("Picking up")
		var dropped_item = item_areas[0].get_parent()
		var canPickUp = inventory_system.pickUp(dropped_item.item.item_id, dropped_item.amount)
		if not canPickUp:
			## makes a copy of the held item
			var mainItem: InventorySystem.InventorySlot = InventorySystem.InventorySlot.new()
			mainItem.item_id = inventory_system.inventory_slots[4].item_id
			mainItem.amount = inventory_system.inventory_slots[4].amount
			## updates the held item with the dropped item data
			inventory_system.inventory_slots[4].item_id = dropped_item.item.item_id
			inventory_system.inventory_slots[4].amount = dropped_item.amount
			## updates the dropped item data with the copy's data
			## TODO: Check if item_id is -1
			if mainItem.item_id > -1:
				var itemStatPath = "res://resources/items/item_%d.tres" % mainItem.item_id
				print("Item path: ", itemStatPath)
				dropped_item.item = load(itemStatPath)
				dropped_item.amount = mainItem.amount
		else:
			dropped_item.queue_free()
		
	## if there isn't an item on the floor:
	else:
		print("Dropping down")
		## Attempt to drop the item in the main slot, if it has one
		inventory_system.drop(tile_pos)

### Detects an item on the floor
#func _on_pickup_detector_area_entered(area: Area2D) -> void:
	#var dropped_item = area.get_parent()
	#print(dropped_item.item)
