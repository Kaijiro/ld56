extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for node in self.get_children():
        if node is Firefly:
            node.awake()
            node.is_creative = true

    GameSignals.emit_signal("PlayerTurn")
