extends Node2D

@export var terrain_generator: TerrainGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generates 4 contigous chunks
	terrain_generator.generateChunk(Vector2i(0,0))
	terrain_generator.generateChunk(Vector2i(0,-1))
	terrain_generator.generateChunk(Vector2i(-1,0))
	terrain_generator.generateChunk(Vector2i(-1,-1))
	terrain_generator.generateChunk(Vector2i(0,1))
	terrain_generator.generateChunk(Vector2i(1,0))
	terrain_generator.generateChunk(Vector2i(1,1))
	terrain_generator.generateChunk(Vector2i(1,-1))
	terrain_generator.generateChunk(Vector2i(-1,1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
