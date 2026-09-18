extends Control

@export var data: CardData

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO
var original_z_index: int = 0

@onready var texture_rect = $TextureRect
@onready var name_label = $Label

func _ready() -> void:
	update_card_ui()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_card_ui() -> void:
	if data == null: return
	if texture_rect and data.texture: texture_rect.texture = data.texture
	if name_label and data.card_name: name_label.text = data.card_name

func _gui_input(event: InputEvent) -> void:
	if not Turns.is_player_turn():
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drag()
		else:
			if is_dragging:
				end_drag()

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func start_drag() -> void:
	is_dragging = true
	original_position = global_position
	original_z_index = z_index
	z_index = 100 
	drag_offset = get_global_mouse_position() - global_position

func end_drag() -> void:
	is_dragging = false
	z_index = original_z_index
	var screen_size = get_viewport_rect().size
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.y < (screen_size.y / 2.0 +((screen_size.y / 2.0)/2.0 )):
		play_card()
	else:
		return_to_hand()

func play_card() -> void:
	if data == null:
		return

	print("Παίχτηκε η κάρτα: ", data.card_name)
	
	# Αποθηκεύουμε τον τύπο του buff πριν κάνουμε queue_free()
	var buff_type = data.get("BUFF") if data.get("BUFF") != null else 0
	
	
	if data.get("DAMAGE") != null and data.DAMAGE > 0:
		var element = data.get("element_id") if data.get("element_id") != null else 1
		EventBus.player_attacked.emit(data.DAMAGE, element)
			
	if data.get("HEAL") != null and data.HEAL > 0:
		EventBus.player_healed.emit(data.HEAL)
			
	if buff_type > 0:
		# Στέλνουμε το buff_type (1: Shuffle, 2: Joker, 3: +10 Atk)
		EventBus.player_buffed.emit(buff_type)

	# 2. Hide / Animate
	var hand = get_parent()
	if hand and hand.has_method("hide_other_cards"):
		hand.hide_other_cards(self)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	
	await tween.finished
	
	# 3. Ενημέρωση του Turn Manager ΠΡΙΝ το queue_free()
	if buff_type != 1: 
		Turns.card_played()
		
	queue_free()

func return_to_hand() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", original_position, 0.15)
	tween.tween_property(self, "position:y", 0.0, 0.15)
	
func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", -20.0, 0.1)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0.0, 0.1)
