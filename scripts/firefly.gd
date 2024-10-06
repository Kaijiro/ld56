class_name Firefly extends Node2D


@onready var tail_light: PointLight2D = $TailLight
@onready var head: AnimatedSprite2D = $Head

# Customisation
@export var singing_light: Color = Color.BLUE_VIOLET
@export var id: int = 0
signal FireflyPlayed(id)

# Colors definition
const idle_light: Color = Color.GREEN_YELLOW
const wrong_light: Color = Color.DARK_RED
const good_light: Color = Color.DARK_GREEN

# Light intensity
const max_energy: float = 6.0
const min_energy: float = 2.0
const default_energy: float = 3.0
var isPulseUp: bool = true
var isPulsing: bool = true
@export var pulsation_rate: float = 2.0

# Sound
@export var note: AudioStreamMP3
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Interactable
var is_mouse_on: bool = false
var is_player_turn: bool = false
var is_game_await: bool = false
@export var delay_idle: float = 0.5

# Positionning
@export var awake_height: int = 150
@export var sleepy_height: int = 530
@export var awake_speed: int = 500
var is_awake: bool = false
const flying_speed: int = 300
const flying_distance: int = 100
var flying_up = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.audio_stream_player.stream = note

    GameSignals.PlayerEnteredRightSequence.connect(self.right)
    GameSignals.PlayerEnteredWrongSequence.connect(self.wrong)
    GameSignals.PlayerTurn.connect(self._on_player_turn_start)
    GameSignals.FirefliesTurn.connect(self._on_fireflies_turn_start)
    GameSignals.AwaitNextInput.connect(self._on_await_next_input)
    GameSignals.BlockInputs.connect(self._on_block_inputs)

    self.sleep()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.is_awake :
        if self.position.y > self.awake_height:
            self.position.y -= delta * awake_speed

    if !self.is_awake && self.position.y > self.sleepy_height:
        self.position.y -= delta * awake_speed

    # Placeholder click to test
    if self.is_clickable() && Input.is_action_just_pressed("click"):
        self.activate()

    if self.isPulsing:
        if self.isPulseUp:
            self.tail_light.energy += delta * pulsation_rate
            if self.tail_light.energy >= max_energy :
                self.isPulseUp = false
        else :
            self.tail_light.energy -= delta * pulsation_rate
            if self.tail_light.energy <= min_energy :
                self.isPulseUp = true

# For GameEngine to make this firefly active for this level
func awake() -> void:
    self.is_awake = true
    self.idle()

func sleep() -> void:
    self.idle()
    self.head.play("sleep")
    self.is_awake = false


# For GameEngine to make this firefly sing in the SimonSequence
func sing() -> void:
    self.head.play("sing")
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = singing_light

    self.audio_stream_player.play()
    await self.audio_stream_player.finished

    self.idle()

func idle() -> void:
    self.head.play("idle")
    self.isPulsing = true
    self.isPulseUp = false
    self.tail_light.color = idle_light

# When player has clicked on a firefly
func activate() -> void:
    if not self.is_clickable():
        return

    GameSignals.emit_signal("BlockInputs")
    self.is_game_await = false
    await self.sing()
    self.emit_signal("FireflyPlayed", self.id)

func wrong() -> void:
    if self.is_awake:
        self.head.play("oops")
        self.isPulsing = false
        self.tail_light.energy = max_energy
        self.tail_light.color = wrong_light
        await get_tree().create_timer(delay_idle).timeout
        self.idle()

func right() -> void:
    if self.is_awake:
        await get_tree().create_timer(self.id * 0.06).timeout
        self.head.play("happy")
        self.position.y -= 50
        self.isPulsing = false
        self.tail_light.energy = max_energy
        self.tail_light.color = good_light
        await get_tree().create_timer(delay_idle).timeout
        self.position.y += 50
        self.idle()

func _on_area_2d_mouse_entered() -> void:
    self.is_mouse_on = true

func _on_area_2d_mouse_exited() -> void:
    self.is_mouse_on = false

func _on_player_turn_start() -> void:
    self.is_game_await = true
    self.is_player_turn = true

func _on_fireflies_turn_start() -> void:
    self.is_player_turn = false
    self.is_game_await = false

func _on_await_next_input() -> void:
    self.is_game_await = true

func _on_block_inputs() -> void:
    self.is_game_await = false

func is_clickable() -> bool:
    return self.is_mouse_on && self.is_awake && self.is_player_turn && self.is_game_await
