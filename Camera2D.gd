extends Camera2D


onready var target : KinematicBody2D = get_node("/root/MainScene/Player")

func _process(delta):
	position = target.position
