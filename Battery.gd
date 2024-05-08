extends Sprite2D
@onready var tilemap : TileMap = get_tree().get_first_node_in_group("tilemap")

func _ready():
	ElectricityManager.battery_list.append(self)
	ElectricityManager.transmit()
