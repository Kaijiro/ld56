extends Node

signal FirefliesTurn
signal PlayerTurn

signal PlayerEnteredWrongSequence
signal PlayerEnteredRightSequence

signal ScoreChange(new_score: int)
signal LifeLost(remaining_lives: int)

signal GameOver
