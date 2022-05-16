extends KinematicBody2D

#Light variable
var maxLight := 3
var currentLight = maxLight

#Grid based movement variable
export(int,8,64,8) var gridSize
export(bool) var moving := false
var moveDirection = {
	"ui_right" : Vector2(1,0),
	"ui_left" : Vector2(-1,0),
	"ui_down" : Vector2(0,1),
	"ui_up" : Vector2(0,-1)
}
var moveSfx = preload("res://asset/audio/sfx/jump_sfx.wav")

#Tongue variable
var tongueActive := false
var tongueMoveSfx = preload("res://asset/audio/sfx/tongueMove.wav")
var tongueSfx = preload("res://asset/audio/sfx/tongue.wav")

#Animation variable
onready var animtree = $VisualAchor/Sprite/AnimationTree.get("parameters/playback")

func _ready():
	$TongueArea/TongueTip.visible = false
	
	Global.frogTongue = $TongueArea/TongueTip

func _exit_tree():
	Global.frogTongue = null

func _process(delta):
	$TongueLine.set_point_position(0,$VisualAchor.position)
	$TongueLine.set_point_position(1,$TongueArea.position + Vector2(8,-8))
	
	$TongueArea/TongueTip.look_at($VisualAchor.global_position)
	
	if tongueActive:
		animtree.travel("tongue")
	else:
		animtree.travel("idle")
	
	match currentLight:
		3:
			$Light2D.texture_scale = 0.43
			$Light2D.energy = 1.52
		2:
			$Light2D.texture_scale = 0.23
			$Light2D.energy = 1.38
		1:
			$Light2D.texture_scale = 0.14
			$Light2D.energy = 1.14
		0:
			$Light2D.texture_scale = 0
			$Light2D.energy = 0
		-1:
			get_tree().current_scene.gameover()
			
	Global.currentFrogLight = currentLight

func _input(event):
	#Move frog in the given direction
	if !get_tree().current_scene.canContinue:
		if !tongueActive:
			for dir in moveDirection.keys():
				if Input.is_action_just_pressed(dir):
					requestMove(moveDirection[dir])
		elif tongueActive:
			for dir in moveDirection.keys():
				if Input.is_action_just_pressed(dir):
					requestMoveTongue(moveDirection[dir])
				
		#Enable and confirm tongue
		if Input.is_action_just_pressed("ui_tongue") && !tongueActive:
			tongueActive = true
		elif Input.is_action_just_pressed("ui_tongue") && tongueActive:
			TongueTrigger()

func requestMove(Direction):
	if Direction == Vector2(1,0) && !$WallCheckRight.is_colliding():
		moveFrog(Direction)
	elif Direction == Vector2(-1,0) && !$WallCheckLeft.is_colliding():
		moveFrog(Direction)
	elif Direction == Vector2(0,1) && !$WallCheckDown.is_colliding():
		moveFrog(Direction)
	elif Direction == Vector2(0,-1) && !$WallCheckUp.is_colliding():
		moveFrog(Direction)

func moveFrog(moveDir):
	if !moving:
		$AudioStreamPlayer.stream = moveSfx
		$AudioStreamPlayer.play()
		
		moving = true
		currentLight -= 1
		
		$Tween.interpolate_property(self,"position",global_position,global_position + moveDir * gridSize,0.2,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween,"tween_completed")
		
		moving = false

#Function to check if the player not next to wall will call tongue move functon
func requestMoveTongue(Direction):
	if Direction == Vector2(1,0) && !$TongueArea/TongueCheckRight.is_colliding():
		moveTongue(Direction)
	elif Direction == Vector2(-1,0) && !$TongueArea/TongueCheckLeft.is_colliding():
		moveTongue(Direction)
	elif Direction == Vector2(0,1) && !$TongueArea/TongueCheckDown.is_colliding():
		moveTongue(Direction)
	elif Direction == Vector2(0,-1) && !$TongueArea/TongueCheckUp.is_colliding():
		moveTongue(Direction)

func moveTongue(moveDir):
	if !moving:
		$AudioStreamPlayer.stream = tongueMoveSfx
		$AudioStreamPlayer.play()
		
		$TongueArea/TongueTip.visible = true
		moving = true
		currentLight -= 1
		
		$Tween.interpolate_property($TongueArea,"position",$TongueArea.position,$TongueArea.position + moveDir * gridSize,0.2,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween,"tween_completed")
		
		moving = false

#Function to make frog consume any node that stick to tongue
func TongueTrigger():
	if !moving:
		moving = true
		$AudioStreamPlayer.stream = tongueSfx
		$AudioStreamPlayer.play()
		
		for node in $TongueArea.get_overlapping_areas():
			node.getTongue()
		
		$Tween.interpolate_property($TongueArea,"position",$TongueArea.position,Vector2(0,0),0.2,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween,"tween_completed")
		
		tongueActive = false
		$TongueArea/TongueTip.visible = false
		moving = false
	
func refill():
	$Particles2D.emitting = true
	currentLight = maxLight
	$consumeSfxPlayer.play()
