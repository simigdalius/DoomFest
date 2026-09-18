extends Control

@export var data: EnemyMove:
	set(new_data):
		data = new_data
		if is_node_ready():
			update_ui()

@onready var texture_rect = $TextureRect

func _ready() -> void:
	update_ui()

func update_ui() -> void:
	if data and texture_rect and data.texture:
		texture_rect.texture = data.texture
