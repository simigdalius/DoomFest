extends Node2D

@onready var timer_main: Timer = $Timer
@onready var timer_bar: Timer = $Timer2
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var is_timer_active: bool = false

func _ready() -> void:
	Turns.turn_changed.connect(_on_turn_changed)
	timer_main.one_shot = true
	timer_main.wait_time = 5.0
	timer_main.timeout.connect(_on_timer_timeout)
	
	set_process(false) 

func _process(_delta: float) -> void:
	if is_timer_active and not timer_main.is_stopped():
		progress_bar.value = timer_main.time_left

func _on_turn_changed(is_player_turn: bool) -> void:
	if is_player_turn:
		progress_bar.max_value = timer_main.wait_time
		progress_bar.value = timer_main.wait_time
		
		is_timer_active = true
		set_process(true) 
		timer_main.start()
	else:
		stop_timer()

func stop_timer() -> void:
	is_timer_active = false
	set_process(false)
	timer_main.stop()

func _on_timer_timeout() -> void:
	stop_timer()
	progress_bar.value = 0
	EventBus.tzoub.emit(15, 0.4)
	sprite.play("timeout")
	await sprite.animation_finished
	sprite.play("default")
	EventBus.enemy_attacked.emit(10)
	if Turns.has_method("end_player_turn"):
		Turns.end_player_turn()
	elif Turns.has_method("start_turn"):
		Turns.start_turn(false)
