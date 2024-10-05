extends Node2D

var fireflies = []
var sequence = []

var sequence_index = 0
@export var max_error: int = 3
var count_error: int = 0
var is_lasttry_error: bool = false

# TODO Not sure if this is the right place for this
var score: int = 0
var point: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for node in self.get_children():
        print(node)

        if node is Firefly:
            node.connect("FireflyPlayed", self.handle_player_play)
            fireflies.append(node)

    GameSignals.connect("FirefliesTurn", self.call_sequence)

    # Debug purpose
    #await self.get_tree().create_timer(5).timeout
    GameSignals.emit_signal("FirefliesTurn")

func call_sequence() -> void:
    if self.is_lasttry_error:
        self.is_lasttry_error = false
    else:
        self.sequence.append(fireflies.pick_random())
    print("LET'S GET READY TO RUUUMMBLLEEEEEEEE")
    await self.get_tree().create_timer(3).timeout

    print("I will begin my sequence")
    await self.play_sequence()

    print("My sequence is terminated, asking player to start its turn")
    GameSignals.emit_signal("PlayerTurn")

func play_sequence() -> void:
    for node in self.sequence:
        await node.sing()
        await get_tree().create_timer(.3).timeout

func handle_player_play(id: int) -> void:
    print("Player played firefly #", id)

    if self.sequence[self.sequence_index].id == id:
        print("Player input is right")
        self.sequence_index = self.sequence_index + 1

        if self.sequence_index == self.sequence.size():
            print("Player has finished turn")
            self.sequence_index = 0
            GameSignals.emit_signal("PlayerEnteredRightSequence")
            self.score += self.point
            print("New Score : "+str(self.score))
            # TODO : Maybe add a timer here to wait for the animation to end
            GameSignals.emit_signal("FirefliesTurn")
    else:
        print("Player input is wrong")
        self.count_error += 1
        self.point = max(self.point - 1, 1);
        print("New point value : "+str(self.point))
        print("Error count : "+str(self.count_error))
        if self.count_error < self.max_error:
            self.is_lasttry_error = true
            GameSignals.emit_signal("PlayerEnteredWrongSequence")
            self.sequence_index = 0
            GameSignals.emit_signal("FirefliesTurn")
        else:
            GameSignals.emit_signal("GameOver")
