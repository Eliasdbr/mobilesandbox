extends TextureRect

## The type determines the texture to use
enum TYPE { HP, SP, DP, MP }

const tex_dict: Dictionary = {
	"tex_dp_0" = preload("res://graphics/stats_icons/HudStats_DP_0.png"),
	"tex_dp_1" = preload("res://graphics/stats_icons/HudStats_DP_1.png"),
	"tex_dp_2" = preload("res://graphics/stats_icons/HudStats_DP_2.png"),
	"tex_hp_0" = preload("res://graphics/stats_icons/HudStats_HP_0.png"),
	"tex_hp_1" = preload("res://graphics/stats_icons/HudStats_HP_1.png"),
	"tex_hp_2" = preload("res://graphics/stats_icons/HudStats_HP_2.png"),
	"tex_mp_0" = preload("res://graphics/stats_icons/HudStats_MP_0.png"),
	"tex_mp_1" = preload("res://graphics/stats_icons/HudStats_MP_1.png"),
	"tex_mp_2" = preload("res://graphics/stats_icons/HudStats_MP_2.png"),
	"tex_sp_0" = preload("res://graphics/stats_icons/HudStats_SP_0.png"),
	"tex_sp_1" = preload("res://graphics/stats_icons/HudStats_SP_1.png"),
	"tex_sp_2" = preload("res://graphics/stats_icons/HudStats_SP_2.png")
}

const types: Array[String] = [ "hp", "sp", "dp", "mp" ]

@export_enum(
	"Health",
	"Stamina",
	"Armor",
	"Mana"
) var type: int = 0:
	set(t):
		type = t
		update_tex()

@export_range(0,2) var value: int = 0:
	set(v):
		value = v
		update_tex()

func update_tex():
	var key = "tex_%s_%d" % [types[type], value]
	print("key: ", key)
	texture = tex_dict[key]

func _ready() -> void:
	update_tex()
