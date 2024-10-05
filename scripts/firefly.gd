extends Node2D

@onready var tail_light: PointLight2D = $TailLight

@export var singing_light: Color = Color.BLUE_VIOLET

# Colors definition
const idle_light: Color = Color.GREEN_YELLOW
const wrong_light: Color = Color.CRIMSON
const good_light: Color = Color.DARK_GREEN

# Light intensity
const max_energy: float = 4.0
const min_energy: float = 2.0
const default_energy: float = 3.0
var isPulseUp: bool = true
var isPulsing: bool = true
var pulsation_rate: float = 1.5

# Interactable
var clickable: bool = false
const delay_idle: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    idle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    # Placeholder click to test
    if self.clickable && Input.is_action_just_pressed("click"):
        activate()
        
    if self.isPulsing:
        if self.isPulseUp:
            self.tail_light.energy += delta * pulsation_rate 
            if self.tail_light.energy >= max_energy :
                self.isPulseUp = false
        else :
            self.tail_light.energy -= delta * pulsation_rate  
            if self.tail_light.energy <= min_energy :
                self.isPulseUp = true    

func sing() -> void:
    print("Singing")
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = singing_light
    await get_tree().create_timer(delay_idle).timeout
    self.idle()
    
func idle() -> void: 
    print("I'm idle")
    self.isPulsing = true
    self.isPulseUp = false
    self.tail_light.color = idle_light
    
func activate() -> void:
    self.clickable = false
    print("call to engine to check if this is the right call")
    # FOR DEBUG PURPOSE : 
    right()
    
func wrong() -> void:
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = wrong_light
    await get_tree().create_timer(delay_idle).timeout
    idle()
    
func right() -> void:
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = good_light
    await get_tree().create_timer(delay_idle).timeout
    idle()

func _on_area_2d_mouse_entered() -> void:
    print("clickable")
    self.clickable = true
    
func _on_area_2d_mouse_exited() -> void:
    print("non-clickable")
    self.clickable = false
