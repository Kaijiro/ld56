extends Node

@onready var score_value: Label = $ScoreLabel/ScoreValue
@onready var lifes_label: Node = $Lifes
@onready var end_screen: ColorRect = $EndScreen
@onready var combo_label: Label = $ComboLabel
@onready var perfect_sprite: Sprite2D = $Perfect
@onready var listen_sprite: Sprite2D = $Listen
@onready var player_turn_sprite: Sprite2D = $PlayerTurn

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
    GameSignals.FirefliesTurn.connect(self._on_fireflies_turn)
    GameSignals.PlayerTurn.connect(self._on_player_turn)

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
    self.player_turn_sprite.visible = false
    self.end_screen.visible = true

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
    var original_global_position = self.perfect_sprite.global_position

    self.perfect_sprite.visible = true
    await get_tree().create_timer(.4).timeout
    var tween = get_tree().create_tween().set_parallel(true)
    tween.tween_property(self.perfect_sprite, "global_position", self.combo_label.global_position, .4)
    tween.tween_property(self.perfect_sprite, "scale", Vector2(.2, .2), .5)
    tween.tween_property(self.perfect_sprite, "modulate", Color(1, 1, 1, 0), .5)
    tween.tween_callback(func():
        self.perfect_sprite.visible = false
        self.perfect_sprite.global_position = original_global_position
        self.perfect_sprite.scale = Vector2(1, 1)
        self.perfect_sprite.modulate = Color(1, 1, 1 ,1)
    ).set_delay(.7)

func _on_player_turn() -> void:
    var original_global_position = self.player_turn_sprite.global_position

    var tween = get_tree().create_tween().set_parallel(true)
    tween.tween_property(self.listen_sprite, "global_position", Vector2(1350, 131), 0.3)
    tween.tween_property(self.player_turn_sprite, "global_position", Vector2(563, 131), 0.3)

func _on_fireflies_turn() -> void:
    var original_global_position = self.listen_sprite.global_position

    var tween = get_tree().create_tween().set_parallel(true)
    tween.tween_property(self.player_turn_sprite, "global_position", Vector2(-250, 131), 0.3)
    tween.tween_property(self.listen_sprite, "global_position", Vector2(563, 131), 0.3)
