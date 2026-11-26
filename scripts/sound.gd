class_name Sound
extends Node

const RATE := 22050

var _fx: Array[AudioStreamPlayer] = []
var _next := 0
var _cache := {}
var _voice: AudioStreamPlayer
var _queue: Array[String] = []
var lang := "en"


func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_fx.append(p)
	_voice = AudioStreamPlayer.new()
	_voice.finished.connect(_play_next)
	add_child(_voice)
	var music := AudioStreamPlayer.new()
	add_child(music)
	var notes := [0, 4, 7, 4, 9, 7, 4, 2, 0, 4, 7, 12, 9, 7, 2, 4]
	var data := PackedByteArray()
	for s in notes:
		data.append_array(_tone(261.63 * pow(2.0, s / 12.0), 0.5, 0.5))
	var loop := _wav(data)
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_end = data.size() / 2
	# The mixer reads past loop_end while interpolating; without spare samples Android crashes.
	var padded := data.duplicate()
	padded.append_array(data.slice(0, 64))
	loop.data = padded
	music.stream = loop
	music.volume_db = -22.0
	music.play()


func _tone(freq: float, length: float, vol: float) -> PackedByteArray:
	var count := int(RATE * length)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / RATE
		var env := minf(1.0, t / 0.012) * exp(-5.0 * t / length) * minf(1.0, (length - t) / 0.03)
		var v := sin(TAU * freq * t) + 0.25 * sin(TAU * freq * 2.0 * t)
		data.encode_s16(i * 2, int(clampf(v * env * vol * 0.7, -1.0, 1.0) * 32767))
	return data


func _wav(data: PackedByteArray) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.data = data
	return w


func note(step: int, length := 0.35) -> void:
	var key := "%d_%f" % [step, length]
	if not _cache.has(key):
		_cache[key] = _wav(_tone(523.25 * pow(2.0, step / 12.0), length, 0.8))
	var p := _fx[_next]
	_next = (_next + 1) % _fx.size()
	p.stream = _cache[key]
	p.volume_db = -8.0
	p.play()


func win() -> void:
	for s in [0, 4, 7, 12]:
		note(s)
		await get_tree().create_timer(0.12).timeout


# Recorded clips: res://voice/<lang>/<key>.ogg
func say(keys: Array) -> void:
	_voice.stop()
	_queue.assign(keys)
	_play_next()


func queue(keys: Array) -> void:
	_queue.append_array(keys)
	if not _voice.playing:
		_play_next()


func talking() -> bool:
	return _voice.playing or not _queue.is_empty()


func _play_next() -> void:
	if _queue.is_empty():
		return
	_voice.stream = load("res://voice/%s/%s.ogg" % [lang, _queue.pop_front()])
	_voice.play()
