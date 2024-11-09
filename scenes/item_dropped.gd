extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var item: ItemStats:
	set(i):
		item = i
		if (sprite_2d):
			sprite_2d.frame = i.graphicId
