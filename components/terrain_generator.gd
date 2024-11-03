class_name TerrainGenerator
extends Node

# Initial seed
@export var SEED: int = 0

# Tile size, in pixels
const TILE_SIZE: int = Tiles.GRID_SIZE

# Chunk size, in squared tiles
@export var CHUNK_SIZE: int = 16

# Terrain thresholds
@export_range(-1,1) var WATER_THRESHOLD: float = -0.1
@export_range(-1,1) var SAND_THRESHOLD: float = -0.05
@export_range(-1,1) var GRASS_THRESHOLD: float = 0.1
@export_range(-1,1) var FOREST_THRESHOLD: float = 0.25

@export var terrain_node: TileMapLayer
@export var noise: FastNoiseLite

var terrain_data = [
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0],
	[0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0],
	[0,1,1,1,0,3,0,0,0,0,0,4,0,0,0,0],
	[0,3,1,4,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,4,0,1,0,0,0,0,0,0],
	[0,0,0,0,0,4,0,0,4,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
]

## key: Vector2i, value: bool?
var loadedChunks: Dictionary = {}

## Gets the current chunk based on a position in the world
func getChunkPosition(pos: Vector2) -> Vector2i:
	var chunkPos = terrain_node.local_to_map(pos) / CHUNK_SIZE
	return chunkPos

## Generate a chunk at a certain chunk coordinate
func generateChunkAt(chunkCoord: Vector2i) -> void:
	#print(loadedChunks)
	# If the chunk is already loaded, return.
	if loadedChunks.has(chunkCoord):
		#print("Chunk already loaded")
		return
	
	loadedChunks[chunkCoord] = true
	
	# Gets the noise values for the tile_data
	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			var noiseValue = noise.get_noise_2d(
				x + (chunkCoord.x * CHUNK_SIZE),
				y + (chunkCoord.y * CHUNK_SIZE),
			)
			#print(noiseValue)
			if noiseValue <= WATER_THRESHOLD:
				# water
				terrain_data[y][x] = 7
			elif noiseValue <= SAND_THRESHOLD:
				# sand
				terrain_data[y][x] = 5
			elif noiseValue <= GRASS_THRESHOLD:
				# grass
				terrain_data[y][x] = [1,1,2,1,1].pick_random()
			elif noiseValue <= FOREST_THRESHOLD:
				# forest (grass, trees)
				terrain_data[y][x] = [1,2,3,4,1,2].pick_random()
			else:
				# mountains (stone)
				terrain_data[y][x] = 8
	
	# Maps the terrain data into the tilemap
	for y in range(len(terrain_data)):
		for x in range(len(terrain_data[y])):
			terrain_node.set_cell(
				Vector2i(
					x + (chunkCoord.x * CHUNK_SIZE),
					y + (chunkCoord.y * CHUNK_SIZE)),
				0,
				Vector2i(terrain_data[y][x],0)
			)

## Loads a chunk area from a position
func loadChunksAreaAt(pos: Vector2, squaredArea: float) -> void:
	var chunkSquaredArea = roundi(squaredArea / CHUNK_SIZE / TILE_SIZE)
	var chunksRange = range(-chunkSquaredArea/2, chunkSquaredArea/2)
	#print("Chunk Squared Area: ", chunkSquaredArea)
	#print(chunksRange)
	for y in chunksRange:
		for x in chunksRange:
			generateChunkAt(getChunkPosition(pos) + Vector2i( x, y))
	print("Loaded Chunks: ", len(loadedChunks))

## Unloads a chunk with the given coordinates
func unloadChunkAt(chunkCoord: Vector2i) -> void:
	# If the chunk is not loaded, return.
	if not loadedChunks.has(chunkCoord):
		#print("No need to unload chunk")
		return
		
	loadedChunks.erase(chunkCoord)
	
	# Erases the tile data
	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			terrain_node.erase_cell(
				Vector2i(x,y) + (chunkCoord * CHUNK_SIZE)
			)

## Unloads furthest chunks
func unloadFurthestChunksFrom(pos: Vector2, distance: float = 512) -> void:
	#print("---unloadFurthestChunks---")
	#print("loadedChunks: ", loadedChunks)
	for currentChunk in loadedChunks.keys():
		var currChunkPos = (
			Vector2(currentChunk * CHUNK_SIZE * TILE_SIZE)
			# Center of the chunk, instead of top-left corner
			+ Vector2(CHUNK_SIZE * TILE_SIZE / 2, CHUNK_SIZE * TILE_SIZE / 2)
		)
		var currentChunkDistance = currChunkPos.distance_to(pos)
		#print("Current chunk pos: ", currChunkPos, " distance: ", currentChunkDistance)
		if currentChunkDistance > distance:
			unloadChunkAt(currentChunk)

func _ready() -> void:
	noise.seed = SEED
