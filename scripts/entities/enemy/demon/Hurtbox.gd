# Hurtbox.gd
extends Area2D

signal damaged(amount: int)

func take_damage(amount: int) -> void:
	damaged.emit(amount)
