extends Node3D

const SAVE := "user://progress.cfg"
const LANGS := ["tr", "en", "es", "pt", "fr", "de", "ar", "ru"]
const SKIES: Array[Color] = [Color("bde6ff"), Color("ffd9ec"), Color("d9d2ff"), Color("ffe8c2"), Color("c8f4e4")]

var sound: Sound
var cam: Camera3D
var env: Environment
var fairy: Node3D
var stage: Node3D
var garden: Node3D
var sun_ball: MeshInstance3D
var menu: Control
var hud: Control
var dots: HBoxContainer
var hold_bar: ProgressBar

var age := -1
var level := 0
var targets: Array[Node3D] = []
var mode := ""
var goal := 0
var step := 0
var rounds := 0
var sequence: Array = []
var prompt := ""
var busy := true
var idle := 0.0
var holding := false
var token := 0
var time := 0.0
var hop := 0.0


func _ready() -> void:
	var code := OS.get_locale_language()
	sound = Sound.new()
	sound.lang = code if code in LANGS else "en"
	add_child(sound)
	_build_world()
	_build_ui()
	get_viewport().size_changed.connect(_fit)
	_fit()
	show_menu()


func _build_world() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = SKIES[0]
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("fff4ff")
	env.ambient_light_energy = 0.55
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 0.8
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 34.0
	add_child(cam)
	cam.look_at_from_position(Vector3(0, 5.2, 12), Vector3(0, 2.25, 0))
	Art.ball(self, Color("78cf70"), Vector3(0, -3.2, -2), Vector3(60, 6, 16))
	Art.ball(self, Color("9ade8a"), Vector3(-6, -1, -9), Vector3(14, 6, 6))
	for x in [-19.0, 19.0]:
		Art.ball(self, Color("9ade8a"), Vector3(x, -1.4, -9.5), Vector3(18, 6, 6))
	Art.ball(self, Color("8bd57f"), Vector3(6, -1.5, -10), Vector3(14, 7, 6))
	sun_ball = Art.ball(self, Color("ffe27a"), Vector3(3.2, 7.2, -10), Vector3.ONE * 1.8)
	for p in [Vector3(-3, 6.4, -8), Vector3(1, 7.8, -12)]:
		for i in 3:
			Art.ball(self, Color.WHITE, p + Vector3(i * 0.7, 0.25 if i == 1 else 0.0, 0), Vector3(1.2, 0.9 if i == 1 else 0.7, 0.6))
	garden = Node3D.new()
	add_child(garden)
	stage = Node3D.new()
	add_child(stage)
	fairy = Art.fairy()
	add_child(fairy)


func _fit() -> void:
	var s := get_viewport().get_visible_rect().size
	if s.x / s.y > 0.5625:
		cam.keep_aspect = Camera3D.KEEP_HEIGHT
		cam.fov = 57.0
	else:
		cam.keep_aspect = Camera3D.KEEP_WIDTH
		cam.fov = 34.0


func _style(c: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(radius)
	s.set_border_width_all(8)
	s.border_color = Color.WHITE
	return s


func _button(text: String, c: Color, size: Vector2, font: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = size
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font)
	for k in ["font_color", "font_pressed_color", "font_hover_color"]:
		b.add_theme_color_override(k, Color.WHITE)
	b.add_theme_color_override("font_outline_color", Color("4a2a66"))
	b.add_theme_constant_override("outline_size", 12)
	b.add_theme_stylebox_override("normal", _style(c, 60))
	b.add_theme_stylebox_override("hover", _style(c, 60))
	b.add_theme_stylebox_override("pressed", _style(c.darkened(0.2), 60))
	return b


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	menu = Control.new()
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(menu)
	var title := Label.new()
	title.text = "Perilumi"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 90
	title.add_theme_font_size_override("font_size", 132)
	title.add_theme_color_override("font_color", Color("ff5fae"))
	title.add_theme_color_override("font_outline_color", Color.WHITE)
	title.add_theme_constant_override("outline_size", 28)
	menu.add_child(title)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	row.offset_top = -330
	row.offset_bottom = -110
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	menu.add_child(row)
	var labels := ["1-2", "3", "4-5"]
	var colors := [Art.COLORS[0], Art.COLORS[3], Art.COLORS[5]]
	for i in 3:
		var b := _button(labels[i], colors[i], Vector2(200, 200), 70)
		b.pressed.connect(start.bind(i))
		row.add_child(b)

	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	var home := _button("⌂", Art.COLORS[4], Vector2(110, 110), 60)
	home.position = Vector2(28, 50)
	home.button_down.connect(func() -> void: holding = true)
	home.button_up.connect(func() -> void: holding = false)
	hud.add_child(home)
	hold_bar = ProgressBar.new()
	hold_bar.position = Vector2(28, 170)
	hold_bar.size = Vector2(110, 14)
	hold_bar.show_percentage = false
	hold_bar.max_value = 1.0
	hud.add_child(hold_bar)
	var replay := _button("♪", Art.COLORS[2], Vector2(110, 110), 60)
	replay.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	replay.offset_left = -138
	replay.offset_right = -28
	replay.offset_top = 50
	replay.pressed.connect(func() -> void: sound.say([prompt]))
	hud.add_child(replay)
	dots = HBoxContainer.new()
	dots.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dots.offset_top = -130
	dots.offset_bottom = -70
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	dots.add_theme_constant_override("separation", 18)
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(dots)


func _dots(total: int, filled: int) -> void:
	for c in dots.get_children():
		dots.remove_child(c)
		c.queue_free()
	for i in total:
		var p := Panel.new()
		p.custom_minimum_size = Vector2(56, 56)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_theme_stylebox_override("panel", _style(Art.COLORS[1] if i < filled else Color(1, 1, 1, 0.45), 28))
		dots.add_child(p)


func _clear() -> void:
	token += 1
	targets.clear()
	for c in stage.get_children():
		stage.remove_child(c)
		c.queue_free()


func show_menu() -> void:
	_clear()
	age = -1
	busy = true
	holding = false
	menu.show()
	sun_ball.hide()
	hud.hide()
	fairy.position = Vector3(0, 1.7, 1)
	fairy.scale = Vector3.ONE * 1.35
	for i in 6:
		var f := Art.flower(Art.COLORS[i])
		f.position = Vector3(-2.2 + i * 0.88, 0.25, 0.4 if i % 2 else 1.4)
		f.scale = Vector3.ONE * 0.8
		stage.add_child(f)


func start(index: int) -> void:
	age = index
	var cfg := ConfigFile.new()
	cfg.load(SAVE)
	level = cfg.get_value("level", str(age), 0)
	menu.hide()
	sun_ball.show()
	hud.show()
	fairy.scale = Vector3.ONE * 0.85
	fairy.position = Vector3(0, 4.0, 0)
	new_level()


func new_level() -> void:
	_clear()
	env.background_color = SKIES[level % SKIES.size()]
	_grow_garden()
	idle = 0.0
	step = 0
	rounds = 0
	_dots(0, 0)
	if age == 0:
		_level_touch()
	elif age == 1:
		_level_find()
	else:
		match level % 3:
			0: _level_count()
			1: _level_memory()
			_: _level_order()


func _grow_garden() -> void:
	for c in garden.get_children():
		garden.remove_child(c)
		c.queue_free()
	var r := RandomNumberGenerator.new()
	r.seed = 7 + age
	for i in mini(level, 24):
		var f := Art.flower(Art.COLORS[r.randi() % 6])
		var side := -1.0 if i % 2 == 0 else 1.0
		f.position = Vector3(side * r.randf_range(2.4, 4.4), -0.35, r.randf_range(-4.5, -2.0))
		f.scale = Vector3.ONE * r.randf_range(0.35, 0.55)
		garden.add_child(f)


func _pick(count: int, from: int) -> Array:
	var a := range(from)
	a.shuffle()
	return a.slice(0, count)


func _add(node: Node3D, id: int, pos: Vector3, scl := 1.0) -> void:
	node.position = pos
	node.scale = Vector3.ZERO
	node.set_meta("id", id)
	node.set_meta("home", pos)
	node.set_meta("size", scl)
	stage.add_child(node)
	targets.append(node)
	node.create_tween().tween_property(node, "scale", Vector3.ONE * scl, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(targets.size() * 0.08)


func _slots(count: int) -> Array:
	var all := {
		3: [Vector3(-1.6, 0.4, 0.8), Vector3(0, 2.1, -0.4), Vector3(1.6, 0.4, 0.8)],
		4: [Vector3(-1.2, 2.0, -0.4), Vector3(1.2, 2.0, -0.4), Vector3(-1.2, -0.1, 1.2), Vector3(1.2, -0.1, 1.2)],
		6: [Vector3(-1.7, 2.1, -0.4), Vector3(0, 2.1, -0.4), Vector3(1.7, 2.1, -0.4), Vector3(-1.7, 0, 1.2), Vector3(0, 0, 1.2), Vector3(1.7, 0, 1.2)],
	}
	var s: Array = all[count].duplicate()
	s.shuffle()
	return s


func _ask(key: String, hint: Node3D = null, praise := false) -> void:
	prompt = key
	busy = false
	idle = 0.0
	sound.say(["praise_%d" % (randi() % 3), key] if praise else [key])
	if hint:
		hint.name = "Hint"
		hint.position = Vector3(1.55, 3.9, 0.5)
		hint.scale = Vector3.ONE * 0.65
		stage.add_child(hint)


func _drop_hint() -> void:
	var h := stage.get_node_or_null("Hint")
	if h:
		stage.remove_child(h)
		h.queue_free()


func _level_touch() -> void:
	mode = "animals" if level % 2 == 0 else "balloons"
	goal = 4
	var slots := _slots(4)
	var kinds := _pick(4, 6)
	for i in 4:
		if mode == "animals":
			_add(Art.animal(kinds[i]), kinds[i], slots[i])
		else:
			_add(Art.balloon(Art.COLORS[kinds[i]]), kinds[i], slots[i])
	_dots(goal, 0)
	if mode == "animals":
		sequence = kinds
		_ask("animals_%d" % sequence[0], Art.animal(sequence[0]))
	else:
		_ask("balloons")


func _level_find() -> void:
	for c in targets:
		stage.remove_child(c)
		c.queue_free()
	targets.clear()
	_drop_hint()
	mode = "colors" if level % 2 == 0 else "shapes"
	var count := 3 if level < 6 else 4
	var kinds := _pick(count, 6 if mode == "colors" else 5)
	var slots := _slots(count)
	var tint: Color = Art.COLORS.pick_random()
	for i in count:
		var n := Art.flower(Art.COLORS[kinds[i]]) if mode == "colors" else Art.shape(kinds[i], tint)
		_add(n, kinds[i], slots[i])
	goal = kinds.pick_random()
	_dots(3, rounds)
	var hint := Art.flower(Art.COLORS[goal], false) if mode == "colors" else Art.shape(goal, tint)
	_ask("%s_%d" % [mode, goal], hint)


func _level_count() -> void:
	mode = "count"
	goal = randi_range(1, clampi(2 + level / 3, 2, 5))
	var slots := _slots(6)
	for i in 6:
		_add(Art.apple(), i, slots[i])
	_dots(goal, 0)
	_ask("count_%d" % (goal - 1))


func _level_memory() -> void:
	mode = "memory"
	var count := 3 if level < 9 else 4
	var kinds := _pick(count, 6)
	var slots := _slots(count)
	for i in count:
		_add(Art.flower(Art.COLORS[kinds[i]]), i, slots[i])
	goal = clampi(2 + level / 6, 2, 4)
	sequence.clear()
	for i in goal:
		var next := randi() % count
		while not sequence.is_empty() and next == sequence.back():
			next = randi() % count
		sequence.append(next)
	_show_sequence()


func _show_sequence() -> void:
	busy = true
	step = 0
	_dots(goal, 0)
	var mine := token
	prompt = "watch"
	sound.say([prompt])
	await get_tree().create_timer(2.2).timeout
	for id in sequence:
		if mine != token:
			return
		sound.note(id * 4)
		_bounce(targets[id], 1.45)
		await get_tree().create_timer(0.9).timeout
	if mine == token:
		_ask("repeat")


func _level_order() -> void:
	mode = "order"
	goal = 3 if level < 9 else 4
	var slots := _slots(goal)
	var c: Color = Art.COLORS.pick_random()
	var kind := randi() % 5
	for i in goal:
		_add(Art.shape(kind, c), i, slots[i], 0.55 + i * 0.28)
	_dots(goal, 0)
	_ask("order")


func _unhandled_input(event: InputEvent) -> void:
	if busy or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var best: Node3D
	var screen := get_viewport().get_visible_rect().size
	var best_d := minf(screen.x, screen.y * 0.5625) * 0.17
	for t in targets:
		var center := t.global_position + Vector3(0, 0.75 * t.scale.y, 0)
		var d: float = cam.unproject_position(center).distance_to(event.position)
		if d < best_d:
			best = t
			best_d = d
	if best:
		tap(best)


func tap(t: Node3D) -> void:
	idle = 0.0
	var id: int = t.get_meta("id")
	match mode:
		"animals":
			sound.note(id * 2)
			if id != sequence[step]:
				_wrong(t)
				return
			_collect(t)
			step += 1
			_dots(goal, step)
			if step == goal:
				_win()
			else:
				_drop_hint()
				_cheer()
				_ask("animals_%d" % sequence[step], Art.animal(sequence[step]), true)
		"balloons":
			sound.note(step * 3)
			_burst(t.global_position + Vector3(0, 0.9, 0), 30)
			targets.erase(t)
			t.queue_free()
			step += 1
			_dots(goal, step)
			_cheer()
			if step == goal:
				_win()
		"colors", "shapes":
			if id != goal:
				_wrong(t)
				return
			sound.note(7)
			_burst(t.global_position + Vector3(0, 0.8, 0), 30)
			_bounce(t, 1.4)
			rounds += 1
			_dots(3, rounds)
			_cheer()
			sound.say(["yes"])
			if rounds == 3:
				_win()
			else:
				busy = true
				var mine := token
				await get_tree().create_timer(1.8).timeout
				if mine == token:
					_level_find()
		"count":
			sound.say(["numbers_%d" % step])
			_cheer()
			sound.note(step * 2)
			_collect(t)
			step += 1
			_dots(goal, step)
			if step == goal:
				_win()
		"memory":
			sound.note(id * 4)
			if id != sequence[step]:
				_wrong(t)
				busy = true
				var mine := token
				await get_tree().create_timer(3.0).timeout
				if mine == token:
					_show_sequence()
				return
			_bounce(t, 1.4)
			_cheer()
			step += 1
			_dots(goal, step)
			if step == goal:
				_win()
		"order":
			if id != step:
				_wrong(t)
				return
			sound.note(step * 4)
			_collect(t)
			_cheer()
			step += 1
			_dots(goal, step)
			if step == goal:
				_win()


func _bounce(t: Node3D, amount: float) -> void:
	var s: float = t.get_meta("size")
	var tw := t.create_tween()
	tw.tween_property(t, "scale", Vector3.ONE * s * amount, 0.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(t, "scale", Vector3.ONE * s, 0.35).set_trans(Tween.TRANS_BOUNCE)


# No failing: a gentle wiggle and the instruction again.
func _wrong(t: Node3D) -> void:
	var tw := t.create_tween()
	for a in [0.25, -0.25, 0.15, 0.0]:
		tw.tween_property(t, "rotation:z", a, 0.09)
	_encourage()


func _cheer() -> void:
	var mouth: Node3D = fairy.get_node("Mouth")
	var tw := fairy.create_tween()
	tw.tween_property(self, "hop", 0.55, 0.22).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(mouth, "scale", Vector3(0.28, 0.17, 0.06), 0.2)
	tw.tween_property(self, "hop", 0.0, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(mouth, "scale", Vector3(0.16, 0.07, 0.05), 0.3)
	_burst(fairy.position + Vector3(0, 1.4, 0.8), 14)


# The fairy is never sad: she nods, smiles and invites another try.
func _encourage() -> void:
	var tw := fairy.create_tween()
	for a in [0.18, -0.18, 0.1, 0.0]:
		tw.tween_property(fairy, "rotation:z", a, 0.22).set_trans(Tween.TRANS_SINE)
	var again := "retry_%d" % (randi() % 2)
	sound.say([again] if mode == "memory" else [again, prompt])


func _collect(t: Node3D) -> void:
	targets.erase(t)
	_burst(t.global_position + Vector3(0, 0.7, 0), 20)
	var tw := t.create_tween().set_parallel()
	tw.tween_property(t, "position", fairy.position, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(t, "scale", Vector3.ZERO, 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.chain().tween_callback(t.queue_free)


func _burst(pos: Vector3, amount: int) -> void:
	var p := CPUParticles3D.new()
	var m := SphereMesh.new()
	m.radius = 0.08
	m.height = 0.16
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.vertex_color_use_as_albedo = true
	m.material = glow
	p.mesh = m
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
	ramp.colors = PackedColorArray(Art.COLORS)
	p.color_initial_ramp = ramp
	p.amount = amount
	p.one_shot = true
	p.explosiveness = 0.95
	p.lifetime = 1.1
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = 1.5
	p.initial_velocity_max = 4.0
	p.gravity = Vector3(0, -5, 0)
	p.position = pos
	add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


func _win() -> void:
	busy = true
	_drop_hint()
	var mine := token
	await get_tree().create_timer(0.7).timeout
	if mine != token:
		return
	sound.win()
	_cheer()
	sound.queue(["praise_%d" % (randi() % 3)])
	for x in [-1.8, 0.0, 1.8]:
		_burst(Vector3(x, 3.2, 0.5), 60)
	fairy.create_tween().tween_property(fairy, "rotation:y", TAU, 1.0).from(0.0)
	level += 1
	var cfg := ConfigFile.new()
	cfg.load(SAVE)
	cfg.set_value("level", str(age), level)
	cfg.save(SAVE)
	await get_tree().create_timer(2.6).timeout
	while mine == token and sound.talking():
		await get_tree().process_frame
	if mine == token:
		new_level()


func _process(delta: float) -> void:
	time += delta
	fairy.position.x = sin(time * 0.8) * (0.0 if age < 0 else 0.35)
	fairy.position.y = (1.7 if age < 0 else 4.0) + sin(time * 2.2) * 0.12 + hop
	var flap := sin(time * 9.0) * 0.45
	fairy.get_node("WingL").rotation.y = flap
	fairy.get_node("WingR").rotation.y = -flap
	if age < 0:
		return
	hold_bar.visible = holding
	hold_bar.value = hold_bar.value + delta / 1.5 if holding else 0.0
	if hold_bar.value >= 1.0:
		hold_bar.value = 0.0
		show_menu()
		return
	if not busy:
		idle += delta
		if idle > 8.0 and not sound.talking():
			idle = 0.0
			sound.say([prompt])
			_help()


func _help() -> void:
	for t in targets:
		var id: int = t.get_meta("id")
		var right := mode == "balloons" or mode == "count"
		right = right or (mode in ["animals", "memory"] and id == sequence[step])
		right = right or (mode in ["colors", "shapes"] and id == goal) or (mode == "order" and id == step)
		if right:
			_bounce(t, 1.3)
			return


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if age < 0:
			get_tree().quit()
		else:
			show_menu()
