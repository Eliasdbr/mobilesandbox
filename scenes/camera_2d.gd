extends Camera2D


@export var nodeToFollow: Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (nodeToFollow):
		position = nodeToFollow.position
