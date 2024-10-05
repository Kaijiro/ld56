extends Node

var clickable = false

@onready
var audioNode = $AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.clickable and Input.is_action_just_pressed("click"):
        self.audioNode.play()

func _on_mouse_entered() -> void:
    self.clickable = true

func _on_mouse_exited() -> void:
    self.clickable = false

func play() -> void:
    self.audioNode.play()
