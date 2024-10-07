extends Node

@onready var score_value: Label = $ScoreLabel/ScoreValue
@onready var lifes_label: Node = $Lifes
@onready var end_screen: ColorRect = $EndScreen
@onready var combo_label: Label = $ComboLabel
@onready var perfect_sprite: Sprite2D = $Perfect

@export var unhappy_face: Texture
@export var happy_face: Texture

var successive_good_sequence = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    GameSignals.ScoreChange.connect(self._on_score_changed)
    GameSignals.LifeLost.connect(self._on_life_lost)
    GameSignals.LifeGain.connect(self._on_life_gain)
    GameSignals.GameOver.connect(self._on_game_over)
    GameSignals.PlayerEnteredRightSequence.connect(self._on_player_entered_right_sequence)
    GameSignals.PlayerEnteredWrongSequence.connect(self._on_player_entered_wrong_sequence)
    GameSignals.SequenceIsPerfect.connect(self._on_sequence_is_perfect)

func _on_score_changed(new_score: int) -> void:
    score_value.text = str(new_score)

func _on_life_lost(remaining_lifes: int) -> void:
    var life_texture = self.lifes_label.get_children()[remaining_lifes]
    (life_texture as TextureRect).texture = unhappy_face
    (life_texture as TextureRect).self_modulate = Color(.33, .33, .33)

func _on_life_gain(remaining_lifes: int) -> void:
    var life_texture = self.lifes_label.get_children()[remaining_lifes-1]
    (life_texture as TextureRect).texture = happy_face
    (life_texture as TextureRect).self_modulate = Color(1, 1, 1)

func _on_game_over() -> void:
    end_screen.visible = true

func _on_play_again_button_pressed() -> void:
    get_tree().reload_current_scene()

func _on_back_button_pressed() -> void:
    self.get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_player_entered_right_sequence() -> void:
    self.successive_good_sequence = self.successive_good_sequence + 1
    self.combo_label.text = "x" + str(self.successive_good_sequence)

func _on_player_entered_wrong_sequence() -> void:
    self.successive_good_sequence = 0
    self.combo_label.text = "x0"

func _on_sequence_is_perfect() -> void:
    var original_global_position = perfect_sprite.global_position

    perfect_sprite.visible = true
    var tween = get_tree().create_tween().set_parallel(true)
    tween.tween_property(perfect_sprite, "global_position", combo_label.global_position, .4)
    tween.tween_property(perfect_sprite, "scale", Vector2(.2, .2), .5)
    tween.tween_property(perfect_sprite, "modulate", Color(1, 1, 1, 0), .5)
    tween.tween_callback(func():
        perfect_sprite.visible = false
        perfect_sprite.global_position = original_global_position
        perfect_sprite.scale = Vector2(1, 1)
        perfect_sprite.modulate = Color(1, 1, 1 ,1)
    ).set_delay(.7)
