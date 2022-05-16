extends Node2D

var normal_speed = 20
var skip_speed = 80
var current_speed = 100

var can_play_again = false

func _ready():
	$Label.visible = false

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		current_speed = skip_speed
	else:
		current_speed = normal_speed
	
	$labelAnchor.global_position.y -= current_speed * delta
	
	if Input.is_action_just_pressed("ui_tongue") && can_play_again:
		Global.currentLevel = 1
		get_tree().change_scene("res://scr/level/level1.tscn")


func _on_VisibilityNotifier2D_screen_entered():
	$Label.visible = true
	can_play_again = true
