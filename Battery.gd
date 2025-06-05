extends Sprite2D

func _ready():
	Global.get_tilemap_manager().battery_list.append(self)
