extends Node

var currentFrogLight : float

var frogTongue = null

var currentLevel = 1

var songEnabled := true

func _process(delta):
	MusicPlayer.stream_paused = !songEnabled
