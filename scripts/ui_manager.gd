extends Node

@onready var score_value: Label = $ScoreLabel/ScoreValue
@onready var end_score_value: Label = $EndScreen/ScoreLabel/ScoreValue
@onready var lifes_label: Label = $LifesLabel
@onready var end_screen: ColorRect = $EndScreen

@export var unhappy_face: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GameSignals.connect("ScoreChange", self._on_score_changed)
    GameSignals.connect("LifeLost", self._on_life_lost)
    GameSignals.connect("GameOver", self._on_game_over)

func _on_score_changed(new_score: int) -> void:
    score_value.text = str(new_score)
    end_score_value.text = str(new_score)

func _on_life_lost(remaining_lifes: int) -> void:
    var life_texture = self.lifes_label.get_children()[remaining_lifes]
    (life_texture as TextureRect).texture = unhappy_face
    (life_texture as TextureRect).self_modulate = Color(.33, .33, .33)

func _on_game_over() -> void:
    end_screen.visible = true

func _on_play_again_button_pressed() -> void:
    print('An other !')
    get_tree().reload_current_scene()
