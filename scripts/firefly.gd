extends Node2D

@onready var tail_light: PointLight2D = $TailLight
@onready var head: AnimatedSprite2D = $Head

# Customisation
@export var singing_light: Color = Color.BLUE_VIOLET
@export var id: int = 0

# Colors definition
const idle_light: Color = Color.GREEN_YELLOW
const wrong_light: Color = Color.CRIMSON
const good_light: Color = Color.DARK_GREEN

# Light intensity
const max_energy: float = 6.0
const min_energy: float = 2.0
const default_energy: float = 3.0
var isPulseUp: bool = true
var isPulsing: bool = true
@export var pulsation_rate: float = 2.0

# Interactable
var clickable: bool = false
@export var delay_idle: float = 0.5

# Positionning
@export var awake_height: int = 150
@export var sleepy_height: int = 550
@export var awake_speed: int = 500
var is_awake: bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.sleep()
    # DEBUG PURPOSE 

    if randi() % 2:
        self.awake()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if self.is_awake && self.position.y > self.awake_height:
        self.position.y -= delta * awake_speed
        
    if !self.is_awake && self.position.y < self.sleepy_height:
        self.position.y += delta * awake_speed
    
    # Placeholder click to test
    if self.clickable && Input.is_action_just_pressed("click"):
        self.activate()
        
    if self.isPulsing:
        if self.isPulseUp:
            self.tail_light.energy += delta * pulsation_rate 
            if self.tail_light.energy >= max_energy :
                self.isPulseUp = false
        else :
            self.tail_light.energy -= delta * pulsation_rate  
            if self.tail_light.energy <= min_energy :
                self.isPulseUp = true    

# For GameEngine to make this firefly active for this level
func awake() -> void:
    self.is_awake = true
    self.idle()
    
func sleep() -> void:
    self.idle() 
    self.head.play("sleep")
    self.is_awake = false
       

# For GameEngine to make this firefly sing in the SimonSequence
func sing() -> void:
    self.head.play("sing")
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = singing_light
    await get_tree().create_timer(delay_idle).timeout
    self.idle()
  
func idle() -> void: 
    self.head.play("idle")
    self.isPulsing = true
    self.isPulseUp = false
    self.tail_light.color = idle_light

# When player has clicked on a firefly    
func activate() -> void:
    self.clickable = false
    print("call to engine to check if "+str(self.id)+" is the right call")
    # FOR DEBUG PURPOSE : 
    self.sing()
    
func wrong() -> void:
    self.head.play("oops")
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = wrong_light
    await get_tree().create_timer(delay_idle).timeout
    self.idle()
    
func right() -> void:
    self.isPulsing = false
    self.tail_light.energy = max_energy
    self.tail_light.color = good_light
    await get_tree().create_timer(delay_idle).timeout
    self.idle()

func _on_area_2d_mouse_entered() -> void:
    self.clickable = true && self.is_awake
    
func _on_area_2d_mouse_exited() -> void:
    self.clickable = false && self.is_awake
