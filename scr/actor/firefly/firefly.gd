extends Area2D

var tonguedSfx = preload("res://asset/audio/sfx/tongue.wav")

func _process(delta):
	
	if !get_overlapping_bodies().empty():
		get_node("../../frog").refill()
		queue_free()

func getTongue():
	$AudioStreamPlayer.stream = tonguedSfx
	$AudioStreamPlayer.play()
	
	$Tween.interpolate_property(self,"global_position",global_position,get_node("../../frog").global_position,0.2,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
