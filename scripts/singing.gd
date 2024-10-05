extends Node
class_name Singing

@export
var id: int

signal FireflyPlayed(id)

var clickable = false
var is_player_turn = false

@onready
var audioNode = $AudioStreamPlayer

func _ready() -> void:
    GameSignals.PlayerTurn.connect(self._on_player_turn_start)
    GameSignals.FirefliesTurn.connect(self._on_fireflies_turn_start)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.clickable and self.is_player_turn and Input.is_action_just_pressed("click"):
        self.audioNode.play()
        self.emit_signal("FireflyPlayed", self.id)

func _on_mouse_entered() -> void:
    self.clickable = true

func _on_mouse_exited() -> void:
    self.clickable = false

func play() -> Signal:
    self.audioNode.play()
    return self.audioNode.finished

func _on_player_turn_start() -> void:
    self.is_player_turn = true

func _on_fireflies_turn_start() -> void:
    self.is_player_turn = false
