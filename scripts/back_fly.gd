extends Node2D

@onready var point_light_2d: PointLight2D = $PointLight2D
var isPulseUp: bool = true
const max_energy: float = 2.0
const min_energy: float = 1.0
var pulsation_rate: float = 0.8
const max_x_amplitude: float = 100
const min_x_amplitude: float = 50
const max_y_amplitude: float = 50
const min_y_amplitude: float = 20
var x_target: float = 0
var y_target: float = 0
var x_direction: float = 1
var y_direction: float = 1
var x_speed: float = 50
var y_speed: float = 50
var initial_x: float = 0
var initial_y: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var new_scale = randf_range(0.2,0.9)
    self.pulsation_rate = randf_range(0.5,1.0)
    self.apply_scale(Vector2(new_scale,new_scale))
    self.initial_x = self.position.x
    self.initial_y = self.position.y
    if randi()%2 == 0:
        self.x_direction = -1.0
    if randi()%2 == 1:
        self.y_direction = -1.0
    self.x_target = self.initial_x + randf_range(min_x_amplitude,max_x_amplitude) * self.x_direction
    self.y_target = self.initial_y + randf_range(min_y_amplitude,max_y_amplitude) * self.y_direction
    self.x_speed = randf_range(25,50)
    self.y_speed = randf_range(10,20)
    
      

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.x_direction > 0:
        if self.position.x < self.x_target:
            self.position.x += delta * self.x_speed
        else: 
            print("Current Position "+str(self.position.x))
            self.x_direction = -1.0
            self.x_target = self.initial_x + randf_range(min_x_amplitude,max_x_amplitude) * self.x_direction
            print("New Target "+str(self.x_target))
    if self.x_direction < 0:
        if self.position.x > self.x_target:
            self.position.x -= delta * self.x_speed
        else: 
            self.x_direction = 1.0
            self.x_target = self.initial_x + randf_range(min_x_amplitude,max_x_amplitude) * self.x_direction
    
    if self.y_direction > 0:
        if self.position.y < self.y_target:
            self.position.y += delta * self.y_speed
        else: 
            print("Current Position "+str(self.position.y))
            self.y_direction = -1.0
            self.y_target = self.initial_y + randf_range(min_y_amplitude,max_y_amplitude) * self.y_direction
            print("New Target "+str(self.y_target))
    if self.y_direction < 0:
        if self.position.y > self.y_target:
            self.position.y -= delta * self.y_speed
        else: 
            self.y_direction = 1.0
            self.y_target = self.initial_y + randf_range(min_y_amplitude,max_y_amplitude) * self.y_direction
    
    if self.isPulseUp:
        self.point_light_2d.energy += delta * pulsation_rate
        if self.point_light_2d.energy >= max_energy :
            self.isPulseUp = false
    else :
        self.point_light_2d.energy -= delta * pulsation_rate
        if self.point_light_2d.energy <= min_energy :
            self.isPulseUp = true
