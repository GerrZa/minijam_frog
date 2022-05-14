extends KinematicBody2D

#Light variable
var maxLight := 4
var currentLight = maxLight

#Grid based movement variable
export(int,8,64,8) var gridSize
var moving := false
var moveDirection = {
	"ui_right" : Vector2(1,0),
	"ui_left" : Vector2(-1,0),
	"ui_down" : Vector2(0,1),
	"ui_up" : Vector2(0,-1)
}

#Tongue variable
var tongueActive := false

#Animation variable
onready var animtree = $VisualAchor/Sprite/AnimationTree.get("parameters/playback")

func _ready():
	$TongueArea/TongueTip.visible = false

func _process(delta):
	$TongueLine.set_point_position(0,$VisualAchor.position)
	$TongueLine.set_point_position(1,$TongueArea.position + Vector2(8,-8))
	
	$TongueArea/TongueTip.look_at($VisualAchor.global_position)
	
	if tongueActive:
		animtree.travel("tongue")
	else:
		animtree.travel("idle")

func _input(event):
	if !tongueActive:
		for dir in moveDirection.keys():
			if Input.is_action_just_pressed(dir):
				requestMove(moveDirection[dir])
	elif tongueActive:
		for dir in moveDirection.keys():
			if Input.is_action_just_pressed(dir):
				requestMoveTongue(moveDirection[dir])
				
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
	currentLight -= 1
	if !moving:
		moving = true
		
		$Tween.interpolate_property(self,"position",global_position,global_position + moveDir * gridSize,0.2,Tween.TRANS_CUBIC,Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween,"tween_completed")
		
		moving = false

#Function to check if the player not next to wall will call tongue move functon
func requestMoveTongue(Direction):
	if Direction == Vector2(1,0) && !$WallCheckRight.is_colliding():
		moveTongue(Direction)
	elif Direction == Vector2(-1,0) && !$WallCheckLeft.is_colliding():
		moveTongue(Direction)
	elif Direction == Vector2(0,1) && !$WallCheckDown.is_colliding():
		moveTongue(Direction)
	elif Direction == Vector2(0,-1) && !$WallCheckUp.is_colliding():
		moveTongue(Direction)

func moveTongue(moveDir):
	currentLight -= 1
	if !moving:
		$TongueArea/TongueTip.visible = true
		moving = true
		
		$Tween.interpolate_property($TongueArea,"position",$TongueArea.position,$TongueArea.position + moveDir * gridSize,0.2,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween,"tween_completed")
		
		moving = false

#Function to make frog consume any node that stick to tongue
func TongueTrigger():
	if !moving:
		moving = true
		
		$Tween.interpolate_property($TongueArea,"position",$TongueArea.position,Vector2(0,0),0.2,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
		$Tween.start()
		
		yield($Tween,"tween_completed")
		
		tongueActive = false
		$TongueArea/TongueTip.visible = false
		moving = false
	
