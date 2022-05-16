extends AudioStreamPlayer

var songList = [
	preload("res://asset/audio/song/y2mate.com - 2053  Carnoustie Path.mp3"),
	preload("res://asset/audio/song/y2mate.com - 2064  Townsend Bridge.mp3"),
	preload("res://asset/audio/song/y2mate.com - 2094  Underwood Road.mp3"),
	preload("res://asset/audio/song/y2mate.com - Ward RidgewayRoyalty Free Music.mp3")
]

var testArray = [1,2,3,4,5,6]

func _ready():
	randomsong()
	
func randomsong():
	randomize()
	songList.shuffle()
	stream = songList[0]
	play()
	
func _on_AudioStreamPlayer_finished():
	randomsong()
