extends Node

signal FirefliesTurn
signal PlayerTurn

signal PlayerEnteredWrongSequence
signal PlayerEnteredRightSequence

signal BlockInputs
signal AwaitNextInput(sequence_index: int)

signal ScoreChange(new_score: int)
signal LifeLost(remaining_lives: int)
signal LifeGain(remaining_lives: int)

signal GameOver
