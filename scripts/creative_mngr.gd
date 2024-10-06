extends Node2D

# Sequences
var fireflies = []
var sequence = []
var sequence_index = 0


# Some UI
@onready var ui_listen: Sprite2D = $UI/Listen
@onready var ui_player_turn: Sprite2D = $UI/PlayerTurn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.ui_listen.visible = false
    self.ui_player_turn.visible = false
    for node in self.get_children():
        if node is Firefly:
            node.awake()
            node.is_creative = true
    GameSignals.emit_signal("PlayerTurn")
