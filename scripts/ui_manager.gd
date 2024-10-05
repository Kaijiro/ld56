extends Node

@onready var score_value: Label = $ScoreLabel/ScoreValue
@onready var lifes_label: Label = $LifesLabel

@export var unhappy_face: Texture

var life_lost = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GameSignals.connect("ScoreChange", self._on_score_changed)
    GameSignals.connect("PlayerEnteredWrongSequence", self._on_player_entered_wrong_sequence)

func _on_score_changed(new_score: int) -> void:
    score_value.text = str(new_score)

func _on_player_entered_wrong_sequence() -> void:
    self.life_lost = self.life_lost + 1
    var life_texture = self.lifes_label.get_children()[self.lifes_label.get_child_count() - self.life_lost]
    (life_texture as TextureRect).texture = unhappy_face
    (life_texture as TextureRect).self_modulate = Color(.33, .33, .33)
