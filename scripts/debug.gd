extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_game_turn_button_pressed() -> void:
    print('This is now fireflies turn')
    GameSignals.emit_signal("FirefliesTurn")

func _on_player_turn_button_pressed() -> void:
    print('This is now player turn')
    GameSignals.emit_signal("PlayerTurn")
