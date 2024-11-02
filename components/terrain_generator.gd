class_name TerrainGenerator
extends Node

# Chunk size, in squared tiles
@export var CHUNK_SIZE: int = 16

# Terrain thresholds
@export_range(-1,1) var WATER_THRESHOLD: float = -0.1
@export_range(-1,1) var SAND_THRESHOLD: float = -0.05
@export_range(-1,1) var GRASS_THRESHOLD: float = 1

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

# Generate a chunk at a certain chunk coordinate
func generateChunk(chunkCoord: Vector2i) -> void:
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
			else:
				# grass
				terrain_data[y][x] = 1
	
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
