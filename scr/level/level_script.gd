extends Node2D

onready var fireflyGroup = $firefly_group

#Gameover variable
var gameoverBg = AnimatedSprite.new()
var gameoverBgSpriteFrame = preload("res://asset/game_ending/gameoverBgSpriteFrame.tres")
var gameoverFrog = Sprite.new()
var frogTexture = preload("res://asset/frog/spr_frog_sheet.png")
var gameoverSfx = preload("res://asset/audio/sfx/gameover.wav")

#Retry variable
var canRetry := false
var retryLabel = preload("res://asset/font/retryLabel.tscn").instance()

#Win variable
var winLabel = preload("res://asset/font/winLabel.tscn").instance()
var canContinue := false
var winSfx = preload("res://asset/audio/sfx/winsfx.wav")

func _ready():
	$CanvasModulate.visible = true
	
	$CanvasLayer/TextureButton.connect("pressed",self,"toggle_song")
	
	$CanvasLayer/TextureButton.pressed = !Global.songEnabled

func _process(delta):
	if Global.currentFrogLight >= 0:
		$CanvasLayer/FrogLightLeftUI.frame = Global.currentFrogLight
	
	if $firefly_group.get_children().empty():
		win()

func _input(event):
	if canRetry && Input.is_action_just_pressed("ui_tongue"):
		get_tree().reload_current_scene()
	
	if canContinue && Input.is_action_just_pressed("ui_tongue"):
		Global.currentLevel += 1
		get_tree().change_scene("res://scr/level/level"+String(Global.currentLevel)+".tscn")
	
	if Input.is_key_pressed(82):
		get_tree().reload_current_scene()

func gameover():
	#Get frog position 
	var frogPos = get_node("frog/VisualAchor/Sprite").global_position
	
	$AudioStreamPlayer.stream = gameoverSfx
	$AudioStreamPlayer.play()
	
	#Add temporary frog sprite on top 
	add_child(gameoverFrog)
	gameoverFrog.global_position = frogPos
	gameoverFrog.centered = false
	gameoverFrog.texture = frogTexture
	gameoverFrog.hframes = 6
	gameoverFrog.z_index = 5
	
	#Add game over Bg
	add_child(gameoverBg)
	gameoverBg.centered =false
	gameoverBg.z_index = 4
	gameoverBg.frames = gameoverBgSpriteFrame
	gameoverBg.playing = true
	
	#Delete main frog in the scene to prevent winning even already lose
	get_node("frog").queue_free()
	
	#Wait for bg to finish
	yield(gameoverBg,"animation_finished")
	
	#Add retryable text and enable retry
	$CanvasLayer.add_child(retryLabel)
	canRetry = true
	
func win():
	if !canContinue:
		$AudioStreamPlayer.stream = winSfx
		$AudioStreamPlayer.play()
		
		$CanvasLayer.add_child(winLabel)
		canContinue = true
	
func toggle_song():
	Global.songEnabled = !$CanvasLayer/TextureButton.pressed
