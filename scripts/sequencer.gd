extends Node2D

# Sequences
var fireflies = []
var sequence = []
var sequence_index = 0

# Score
@export var max_error: int = 3
var count_error: int = 0
var is_lasttry_error: bool = false
var score: int = 0
var point: int

# Leveling
var current_difficulty = 0
@export var difficulties_awake_number: Array[int] = [3,4,6,8]
@export var difficulties_points: Array[int] = [2,3,5,10]
@export var difficulties_max: Array[int] = [3,5,7,666]

# Some UI
@onready var ui_listen: Sprite2D = $UI/Listen
@onready var ui_player_turn: Sprite2D = $UI/PlayerTurn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.ui_listen.visible = false
    self.ui_player_turn.visible = false
    self.point = difficulties_points[self.current_difficulty]
    for node in self.get_children():
        if node is Firefly:
            node.connect("FireflyPlayed", self.handle_player_play)
            fireflies.append(node)

    fireflies.shuffle()
    for i in self.difficulties_awake_number[self.current_difficulty]:
        fireflies[i].awake()
    GameSignals.connect("FirefliesTurn", self.call_sequence)
    GameSignals.connect("PlayerEnteredRightSequence", self.sequence_success)
    GameSignals.connect("PlayerEnteredWrongSequence", self.sequence_failure)
    GameSignals.connect("GameOver", self.game_over)

    # Debug purpose
    #await self.get_tree().create_timer(5).timeout
    GameSignals.emit_signal("FirefliesTurn")

func call_sequence() -> void:    
    self.ui_player_turn.visible = false
    if self.is_lasttry_error:
        self.is_lasttry_error = false
    else:
        self.sequence.append(self.fireflies.filter(func(node): return node.is_awake).pick_random())
        await self.get_tree().create_timer(1).timeout

    print("I will begin my sequence")    
    await self.play_sequence()

    print("My sequence is terminated, asking player to start its turn")
    GameSignals.emit_signal("PlayerTurn")
    self.ui_player_turn.visible = true

func play_sequence() -> void:
    self.ui_listen.visible = true
    for node in self.sequence:
        await node.sing()
        await get_tree().create_timer(.3).timeout
    self.ui_listen.visible = false

func sequence_success() -> void:
    print("Player has finished turn")
    self.sequence_index = 0
    self.score += self.point
    GameSignals.emit_signal("ScoreChange", self.score)
    print("New Score : "+str(self.score))
    if self.sequence.size() == self.difficulties_max[self.current_difficulty]:
        self.current_difficulty = min(self.current_difficulty + 1, self.difficulties_points.size())
        for n in range(self.difficulties_awake_number[self.current_difficulty - 1], self.difficulties_awake_number[self.current_difficulty]):
            self.fireflies[n].awake();
        self.point = self.difficulties_points[self.current_difficulty]
        print("New Difficulty : "+ str(self.current_difficulty))
    # TODO : Maybe add a timer here to wait for the animation to end
    GameSignals.emit_signal("FirefliesTurn")

func sequence_failure() -> void:
    await get_tree().create_timer(1).timeout
    self.count_error += 1
    self.point = max(self.point - 1, 1);
    print("New point value : "+str(self.point))
    print("Error count : "+str(self.count_error))
    GameSignals.emit_signal("LifeLost",  self.max_error - self.count_error)
    if self.count_error < self.max_error:
        self.is_lasttry_error = true
        self.sequence_index = 0
        GameSignals.emit_signal("FirefliesTurn")
    else:
        GameSignals.emit_signal("GameOver")

# TODO Placeholder, probably won't make it to final build
func game_over() -> void:
    print("Final Score : ",self.score)
    print("New Game")
    await get_tree().create_timer(1.5).timeout
    get_tree().reload_current_scene()

func handle_player_play(id: int) -> void:
    if self.sequence[self.sequence_index].id == id:
        print("Player input is right :",id)
        self.sequence_index = self.sequence_index + 1
        if self.sequence_index == self.sequence.size():
            GameSignals.emit_signal("PlayerEnteredRightSequence")
        else:
            GameSignals.emit_signal("AwaitNextInput")
    else:
        print("Player input is wrong :",id)
        GameSignals.emit_signal("PlayerEnteredWrongSequence")
