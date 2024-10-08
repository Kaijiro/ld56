extends Node2D

# Sequences
var fireflies = []
var sequence = []
var sequence_index = 0
var sequence_solved = 0

# Score
@export var max_error: int = 3
var count_error: int = 0
var is_lasttry_error: bool = false
var score: int = 0
var point: int
var is_perfect: bool = true
@export var bonus_trigger: int = 5
var current_bonus_value: int = 0

# Leveling
var current_difficulty = 0
@export var difficulties_awake_number: Array[int] = [3,4,6,8]
@export var difficulties_points: Array[int] = [2,3,5,10]
@export var difficulties_max: Array[int] = [3,5,7,666]

# Some UI
@onready var ld_logo: Sprite2D = $LdLogo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

    if self.is_lasttry_error:
        self.is_lasttry_error = false
    else:
        self.add_note()
        await self.get_tree().create_timer(1).timeout
    await self.play_sequence()

    GameSignals.emit_signal("PlayerTurn")

func add_note() -> void:
    var tmp_selection = self.fireflies.filter(func(node): return node.is_awake).pick_random()
    var invalid_selection = true
    if self.sequence.size() >= 2:
        invalid_selection = self.sequence[self.sequence.size()-1].id == tmp_selection.id && self.sequence[self.sequence.size()-2].id == tmp_selection.id
        while invalid_selection:
            tmp_selection = self.fireflies.filter(func(node): return node.is_awake).pick_random()
            invalid_selection = self.sequence[self.sequence.size()-1].id == tmp_selection.id && self.sequence[self.sequence.size()-2].id == tmp_selection.id
    self.sequence.append(tmp_selection)

func play_sequence() -> void:
    for node in self.sequence:
        await node.sing()
        await get_tree().create_timer(.3).timeout

func sequence_success() -> void:
    self.sequence_index = 0
    self.score += self.point
    GameSignals.emit_signal("ScoreChange", self.score)
    if self.sequence.size() == self.difficulties_max[self.current_difficulty]:
        self.current_difficulty = min(self.current_difficulty + 1, self.difficulties_points.size())
        for n in range(self.difficulties_awake_number[self.current_difficulty - 1], self.difficulties_awake_number[self.current_difficulty]):
            self.fireflies[n].awake();
        self.point = self.difficulties_points[self.current_difficulty]
    if self.current_bonus_value >= self.bonus_trigger:
        self.count_error = max(0,self.count_error - 1)
        self.bonus_trigger += 1
        self.current_bonus_value = 0
        GameSignals.emit_signal("LifeGain",  self.max_error - self.count_error)
    # TODO : Maybe add a timer here to wait for the animation to end
    GameSignals.emit_signal("FirefliesTurn")

func sequence_failure() -> void:
    self.current_bonus_value = 0
    self.is_perfect = false
    var tweener = get_tree().create_tween()
    tweener.set_ease(Tween.EASE_OUT)
    tweener.tween_property(self.ld_logo,"position",Vector2(self.ld_logo.position.x,610),0.8).set_trans(Tween.TRANS_SPRING)
    tweener.tween_property(self.ld_logo,"position",Vector2(self.ld_logo.position.x,750),0.4)
    await get_tree().create_timer(1).timeout
    self.count_error += 1
    self.point = max(self.point - 1, 1);
    GameSignals.emit_signal("LifeLost",  self.max_error - self.count_error)

    if self.count_error < self.max_error:
        self.is_lasttry_error = true
        self.sequence_index = 0
        GameSignals.emit_signal("FirefliesTurn")
    else:
        GameSignals.emit_signal("GameOver")

# TODO Placeholder, probably won't make it to final build
func game_over() -> void:
    GameSignals.emit_signal("BlockInputs")

func handle_player_play(id: int, played_sequence_index: int) -> void:
    if self.sequence[played_sequence_index].id == id:
        self.sequence_solved += 1
        self.sequence_index = self.sequence_index + 1
        if self.sequence_solved == self.sequence.size():
            self.sequence_solved = 0
            if self.is_perfect:
                GameSignals.SequenceIsPerfect.emit()
                self.current_bonus_value += 1
            self.is_perfect = true
            GameSignals.emit_signal("PlayerEnteredRightSequence")
        else:
            GameSignals.emit_signal("AwaitNextInput",self.sequence_index)
    else:
        self.sequence_solved = 0
        GameSignals.emit_signal("PlayerEnteredWrongSequence")
