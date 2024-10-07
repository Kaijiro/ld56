extends Node2D

@onready var point_light_2d: PointLight2D = $PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var new_scale = randf_range(0.4,0.9)
    self.apply_scale(Vector2(new_scale,new_scale))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
