extends Node

@onready var score_value: Label = $ScoreLabel/ScoreValue
@onready var lifes_label: Label = $LifesLabel

@export var unhappy_face: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GameSignals.connect("ScoreChange", self._on_score_changed)
    GameSignals.connect("LifeLost", self._on_life_lost)

func _on_score_changed(new_score: int) -> void:
    score_value.text = str(new_score)

func _on_life_lost(remaining_lifes: int) -> void:
    var life_texture = self.lifes_label.get_children()[remaining_lifes]
    (life_texture as TextureRect).texture = unhappy_face
    (life_texture as TextureRect).self_modulate = Color(.33, .33, .33)
