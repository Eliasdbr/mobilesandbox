class_name GameWorld
extends Node2D

@export var player: Node2D
@export var terrain_generator: TerrainGenerator
@export var render_boundary: Area2D
@export var render_boundary_collision: CollisionShape2D
@export var camera: Camera2D

var cameraViewHeight: float
var cameraViewWidth: float

## key: Vector2i, value: instance_id
var loadedCharacters: Dictionary = {}

func _onRenderBoundaryExit(exitingArea: Area2D) -> void:
	#print("viewport height: ", cameraViewHeight)
	var newPos = exitingArea.global_position
	#print("newPos: ", newPos)
	# Gets a vector from the center of the current boundary area, to the point 
	# where the player exited the area. This is to get a direction in which to
	# generate the next chunks
	var directionFromCenter = (newPos - (render_boundary.global_position + Vector2(1,1) * 128)).normalized()
	if abs(directionFromCenter.x) > abs(directionFromCenter.y):
		directionFromCenter = Vector2(sign(directionFromCenter.x), 0)
	else:
		directionFromCenter = Vector2(0, sign(directionFromCenter).y)
	#print("directionFromCenter: ", directionFromCenter)
	# repositions the boundary
	render_boundary.global_position += directionFromCenter * 256
	# loads new chunks
	terrain_generator.loadChunksAreaAt(render_boundary.global_position, cameraViewHeight * 2)
	# unloads the furthest chunks
	terrain_generator.unloadFurthestChunksFrom(newPos, cameraViewHeight * 2)
	#print("Area exited", newPos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Sets the camera view height for the rendering
	cameraViewWidth = camera.get_viewport_rect().size.x / camera.zoom.x
	cameraViewHeight = camera.get_viewport_rect().size.y / camera.zoom.y
	
	# Sets the correct render boundary
	#render_boundary_collision.shape.set("size", Vector2(cameraViewWidth / 2, cameraViewHeight / 2) )
	
	# Generates first chunks
	terrain_generator.loadChunksAreaAt(Vector2.ZERO, cameraViewHeight * 2)

	# Positions the player at the center of chunk 0,0
	#var spawnPoint = Vector2(1,1) * terrain_generator.CHUNK_SIZE * terrain_generator.TILE_SIZE / 2
	#player.position = spawnPoint
	#render_boundary.global_position = spawnPoint


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
