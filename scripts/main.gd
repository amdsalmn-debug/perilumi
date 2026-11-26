extends Node3D

const SAVE := "user://progress.cfg"
const LANGS := ["tr", "en", "es", "pt", "fr", "de", "ar", "ru"]
const SKIES: Array[Color] = [Color("bde6ff"), Color("ffd9ec"), Color("d9d2ff"), Color("ffe8c2"), Color("c8f4e4")]
# Calm and thinking games alternate. Each full round of an age's list is one tier harder.
const GAMES := [
	["animals", "balloons", "peek", "music", "feed", "butterflies"],
	["colors", "balloons", "shapes", "peek", "fruits", "count", "same", "butterflies", "big", "feed", "odd"],
	["same", "howmany", "pairs", "odd", "order", "pattern", "number", "memory", "more", "add"],
]
# "Find the right one" games: three rounds, exactly one target with id == goal.
const PICK := ["colors", "shapes", "fruits", "same", "big", "odd", "howmany", "add", "number", "more", "pattern"]
const AGES := ["1-3", "3-4", "5-6"]

var sound: Sound
var cam: Camera3D
var env: Environment
var fairy: Node3D
var stage: Node3D
var garden: Node3D
var sun_ball: MeshInstance3D
var menu: Control
var privacy: Control
var hud: Control
var dots: HBoxContainer
var hold_bar: ProgressBar
var badge: Button

var age := -1
var level := 0
var tier := 0
var picked: Node3D
var targets: Array[Node3D] = []
var mode := ""
var goal := 0
var step := 0
var rounds := 0
var sequence: Array = []
var prompt: Array = []
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
	var window := DisplayServer.window_get_size()
	var inset := 0.0
	if OS.has_feature("mobile") and window.y > 0:
		inset = maxf(DisplayServer.get_display_safe_area().position.y, 0) * s.y / window.y
	menu.offset_top = inset
	hud.offset_top = inset


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
	row.offset_top = -420
	row.offset_bottom = -70
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	menu.add_child(row)
	for i in 3:
		row.add_child(_age_card(i))

	var info := _button("i", Art.COLORS[2], Vector2(90, 90), 48)
	info.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	info.offset_left = -110
	info.offset_right = -20
	info.offset_top = 20
	info.pressed.connect(func() -> void: privacy.show())
	menu.add_child(info)

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
	badge = _button("", Art.COLORS[1], Vector2(180, 90), 44)
	badge.set_anchors_preset(Control.PRESET_CENTER_TOP)
	badge.offset_left = -90
	badge.offset_right = 90
	badge.offset_top = 60
	badge.offset_bottom = 150
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(badge)
	var replay := _button("♪", Art.COLORS[2], Vector2(110, 110), 60)
	replay.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	replay.offset_left = -138
	replay.offset_right = -28
	replay.offset_top = 50
	replay.pressed.connect(func() -> void: sound.say(prompt))
	hud.add_child(replay)
	dots = HBoxContainer.new()
	dots.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dots.offset_top = -130
	dots.offset_bottom = -70
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	dots.add_theme_constant_override("separation", 18)
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(dots)
	_build_privacy(layer)


# A button showing a 3D child of that age, so the choice is clear without reading.
func _age_card(i: int) -> Button:
	var b := _button("", [Art.COLORS[0], Art.COLORS[3], Art.COLORS[5]][i], Vector2(210, 350), 20)
	b.pressed.connect(start.bind(i))
	var view := SubViewport.new()
	view.size = Vector2i(190, 255)
	view.own_world_3d = true
	view.transparent_bg = true
	view.msaa_3d = Viewport.MSAA_4X
	b.add_child(view)
	var we := WorldEnvironment.new()
	we.environment = Environment.new()
	we.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	we.environment.ambient_light_color = Color("fff4ff")
	we.environment.ambient_light_energy = 0.55
	view.add_child(we)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -25, 0)
	light.light_energy = 0.8
	view.add_child(light)
	var eye := Camera3D.new()
	eye.projection = Camera3D.PROJECTION_ORTHOGONAL
	eye.size = 2.75
	eye.position = Vector3(0, 1.22, 5)
	view.add_child(eye)
	view.add_child(Art.kid(i))
	var back := Panel.new()
	back.position = Vector2(14, 14)
	back.size = Vector2(182, 245)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_theme_stylebox_override("panel", _style(Color("fff4fb"), 46))
	b.add_child(back)
	var picture := TextureRect.new()
	picture.texture = view.get_texture()
	picture.position = Vector2(10, 9)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(picture)
	var text := Label.new()
	text.text = AGES[i]
	text.position = Vector2(0, 262)
	text.size = Vector2(210, 80)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 58)
	text.add_theme_color_override("font_outline_color", Color("4a2a66"))
	text.add_theme_constant_override("outline_size", 12)
	b.add_child(text)
	return b


# Families policy: the privacy policy must be readable inside the app. Text only, no links.
func _build_privacy(layer: CanvasLayer) -> void:
	var back := ColorRect.new()
	back.color = Color("fff4fb")
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	privacy = back
	layer.add_child(privacy)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 40
	scroll.offset_right = -40
	scroll.offset_top = 150
	scroll.offset_bottom = -40
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	privacy.add_child(scroll)
	var text := Label.new()
	text.text = Privacy.TEXT[sound.lang]
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_PASS
	text.add_theme_font_size_override("font_size", 32)
	text.add_theme_color_override("font_color", Color("3a2352"))
	if sound.lang == "ar":
		text.text_direction = Control.TEXT_DIRECTION_RTL
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	scroll.add_child(text)
	var close := _button("X", Art.COLORS[4], Vector2(110, 110), 48)
	close.position = Vector2(28, 20)
	close.pressed.connect(func() -> void: privacy.hide())
	privacy.add_child(close)
	privacy.hide()


func _dots(total: int, filled: int) -> void:
	for c in dots.get_children():
		dots.remove_child(c)
		c.queue_free()
	var d := 56 if total <= 8 else 40
	for i in total:
		var p := Panel.new()
		p.custom_minimum_size = Vector2(d, d)
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_theme_stylebox_override("panel", _style(Art.COLORS[1] if i < filled else Color(1, 1, 1, 0.45), d / 2))
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
	picked = null
	_dots(0, 0)
	var games: Array = GAMES[age]
	mode = games[level % games.size()]
	tier = mini(level / games.size(), 3)
	badge.text = "★ %d" % (level + 1)
	match mode:
		"animals": _level_animals()
		"balloons", "butterflies": _level_catch()
		"peek": _level_peek()
		"feed": _level_feed()
		"music": _level_music()
		"count": _level_count()
		"memory": _level_memory()
		"order": _level_order()
		"pairs": _level_pairs()
		_: _pick_round()


func _grow_garden() -> void:
	for c in garden.get_children():
		garden.remove_child(c)
		c.queue_free()
	var r := RandomNumberGenerator.new()
	r.seed = 7 + age
	for i in mini(level, 24):
		var f := Art.flower(Art.COLORS[r.randi() % 6])
		var side := -1.0 if i % 2 == 0 else 1.0
		f.position = Vector3(side * r.randf_range(3.2, 4.6), -0.35, r.randf_range(-4.5, -2.0))
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
		8: [Vector3(-2.25, 2.1, -0.4), Vector3(-0.75, 2.1, -0.4), Vector3(0.75, 2.1, -0.4), Vector3(2.25, 2.1, -0.4), Vector3(-2.25, 0, 1.2), Vector3(-0.75, 0, 1.2), Vector3(0.75, 0, 1.2), Vector3(2.25, 0, 1.2)],
	}
	var s: Array = all[count].duplicate()
	s.shuffle()
	return s


func _ask(keys: Array, hint: Node3D = null, praise := false) -> void:
	prompt = keys
	busy = false
	idle = 0.0
	sound.say(["praise_%d" % (randi() % 3)] + keys if praise else keys)
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


func _level_animals() -> void:
	var count: int = [3, 4, 6, 6][tier]
	var kinds := _pick(count, 6)
	var slots := _slots(count)
	for i in count:
		_add(Art.animal(kinds[i]), kinds[i], slots[i])
	sequence = kinds.slice(0, mini(count, 4))
	sequence.shuffle()
	goal = sequence.size()
	_dots(goal, 0)
	_ask(["animals_%d" % sequence[0]], Art.animal(sequence[0]))


func _level_catch() -> void:
	goal = [4, 4, 6, 8][tier] if mode == "balloons" else [3, 4, 6, 6][tier]
	var slots := _slots(goal)
	for i in goal:
		var c: Color = Art.COLORS[(i + level) % 6]
		var n := Art.balloon(c) if mode == "balloons" else Art.butterfly(c)
		n.set_meta("phase", i * 1.7)
		_add(n, i, slots[i])
	_dots(goal, 0)
	_ask([mode])


func _level_peek() -> void:
	goal = [3, 3, 4, 6][tier]
	var kinds := _pick(goal, 6)
	var slots := _slots(goal)
	for i in goal:
		var n := Node3D.new()
		var friend := Art.animal(kinds[i])
		friend.name = "Friend"
		friend.position = Vector3(0, 0.15, -0.45)
		friend.scale = Vector3.ONE * 0.8
		n.add_child(friend)
		var bush := Art.bush()
		bush.name = "Bush"
		n.add_child(bush)
		_add(n, i, slots[i])
	_dots(goal, 0)
	_ask(["peek"])


func _level_feed() -> void:
	goal = [3, 4, 5, 6][tier]
	var friend := Art.animal(0)
	friend.name = "Friend"
	friend.position = Vector3(0, 0.35, 0.6)
	friend.scale = Vector3.ONE * 1.1
	stage.add_child(friend)
	var spots := [Vector3(-1.8, 2.2, 0), Vector3(1.8, 2.2, 0), Vector3(-1.9, 0.7, 0.8), Vector3(1.9, 0.7, 0.8), Vector3(-1.0, -0.45, 1.9), Vector3(1.0, -0.45, 1.9)]
	spots.shuffle()
	for i in goal:
		_add(Art.fruit(5), i, spots[i])
	_dots(goal, 0)
	_ask(["feed"])


func _level_music() -> void:
	goal = [6, 8, 10, 12][tier]
	var slots := _slots(6)
	for i in 6:
		_add(Art.flower(Art.COLORS[i]), i, slots[i])
	_dots(goal, 0)
	_ask(["music"])


func _pick_round() -> void:
	for c in stage.get_children():
		stage.remove_child(c)
		c.queue_free()
	targets.clear()
	_dots(3, rounds)
	var count: int = [3, 4, 6, 6][tier]
	match mode:
		"colors", "fruits":
			var kinds := _pick(count, 6)
			var slots := _slots(count)
			for i in count:
				_add(Art.flower(Art.COLORS[kinds[i]]) if mode == "colors" else Art.fruit(kinds[i]), kinds[i], slots[i])
			goal = kinds.pick_random()
			var hint := Art.flower(Art.COLORS[goal], false) if mode == "colors" else Art.fruit(goal)
			_ask(["%s_%d" % [mode, goal]], hint)
		"shapes":
			count = mini(count, 4)
			var kinds := _pick(count, 5)
			var slots := _slots(count)
			var tint: Color = Art.COLORS.pick_random()
			for i in count:
				_add(Art.shape(kinds[i], tint), kinds[i], slots[i])
			goal = kinds.pick_random()
			_ask(["shapes_%d" % goal], Art.shape(goal, tint))
		"same":
			# id = shape * 6 + color; later tiers add look-alikes sharing one of the two.
			goal = randi() % 30
			var ids := [goal]
			while ids.size() < count:
				var id := randi() % 30
				if tier > 0 and randf() < 0.7:
					id = (goal / 6) * 6 + randi() % 6 if randf() < 0.5 else (randi() % 5) * 6 + goal % 6
				if not id in ids:
					ids.append(id)
			var slots := _slots(count)
			for i in count:
				_add(Art.shape(ids[i] / 6, Art.COLORS[ids[i] % 6]), ids[i], slots[i])
			_ask(["same"], Art.shape(goal / 6, Art.COLORS[goal % 6]))
		"big":
			count = [3, 4, 4, 6][tier]
			var want := randi() % 2
			var ratio: float = [0.6, 0.66, 0.72, 0.78][tier]
			var kind := randi() % 5
			var c: Color = Art.COLORS.pick_random()
			var slots := _slots(count)
			for i in count:
				var large := (i == 0) == (want == 0)
				_add(Art.shape(kind, c), 1 if i == 0 else 0, slots[i], 1.15 if large else 1.15 * ratio)
			goal = 1
			_ask(["big_%d" % want])
		"odd":
			var kinds := _pick(2, 5)
			var colors := _pick(2, 6)
			var other_kind := true
			var other_color := tier == 0
			if tier > 1 and randf() < 0.5:
				other_kind = false
				other_color = true
			var slots := _slots(count)
			for i in count:
				var k: int = kinds[1 if i == 0 and other_kind else 0]
				var c: int = colors[1 if i == 0 and other_color else 0]
				_add(Art.shape(k, Art.COLORS[c]), 1 if i == 0 else 0, slots[i])
			goal = 1
			_ask(["odd"])
		"howmany":
			var top: int = [5, 6, 8, 10][tier]
			goal = randi_range(1, top)
			for i in goal:
				var in_row := mini(5, goal - (i / 5) * 5)
				var a := Art.apple()
				a.position = Vector3((i % 5 - (in_row - 1) / 2.0) * 1.0, 2.1 - (i / 5) * 1.1, 0)
				a.scale = Vector3.ONE * 0.8
				stage.add_child(a)
			_tiles(_choices(goal, top))
			_ask(["howmany"])
		"add":
			var top: int = [5, 6, 8, 10][tier]
			var left := randi_range(1, top - 1)
			var right := randi_range(1, top - left)
			goal = left + right
			for side in [[left, -1.5], [right, 1.5]]:
				var g := _group(side[0])
				g.position = Vector3(side[1], 1.1, 0)
				stage.add_child(g)
			Art.label(stage, "+", 200, Vector3(0, 1.85, 0))
			_tiles(_choices(goal, top))
			_ask(["add"])
		"number":
			var top: int = [5, 10, 10, 10][tier]
			var values := _pick(count, top)
			var slots := _slots(count)
			for i in count:
				var v: int = values[i] + 1
				_add(Art.tile(str(v), Art.COLORS[v % 6]), v, slots[i])
			goal = values.pick_random() + 1
			var hint: Node3D = Art.tile(str(goal), Art.COLORS[goal % 6]) if tier == 0 else null
			_ask(["number", "numbers_%d" % (goal - 1)], hint)
		"more":
			var gap: int = [3, 2, 1, 1][tier]
			var low := randi_range(1, [5, 6, 8, 9][tier] - gap)
			var sides := [-1.55, 1.55]
			sides.shuffle()
			for i in 2:
				var g := _group(low + gap * i)
				Art.ball(g, Color("fff4fb"), Vector3(0, 0.75, -0.55), Vector3(2.5, 2.5, 0.1))
				_add(g, i, Vector3(sides[i], 0.8, 0))
			goal = 1
			_ask(["more"])
		"pattern":
			var unit: Array = [[0, 1], [0, 0, 1], [0, 1, 2], [0, 1, 1, 2]][tier]
			var kinds := _pick(3, 5)
			var colors := _pick(3, 6)
			var shown := 6 if unit.size() == 4 else 5
			var gap := 4.5 / shown
			for i in shown:
				var j: int = unit[i % unit.size()]
				var n := Art.shape(kinds[j], Art.COLORS[colors[j]])
				n.position = Vector3(-2.25 + i * gap, 2.2, 0)
				n.scale = Vector3.ONE * 0.55
				stage.add_child(n)
			Art.label(stage, "?", 150, Vector3(2.25, 2.55, 0))
			var xs := [-1.6, 0.0, 1.6]
			xs.shuffle()
			for j in 3:
				_add(Art.shape(kinds[j], Art.COLORS[colors[j]]), j, Vector3(xs[j], -0.2, 1.0))
			goal = unit[shown % unit.size()]
			_ask(["pattern"])


# A cluster of apples centred 0.75 above its origin.
func _group(count: int) -> Node3D:
	var n := Node3D.new()
	var lines := (count + 2) / 3
	for i in count:
		var in_row := mini(3, count - (i / 3) * 3)
		var a := Art.apple()
		a.position = Vector3((i % 3 - (in_row - 1) / 2.0) * 0.6, 0.45 + (lines - 1) * 0.3 - (i / 3) * 0.6, 0)
		a.scale = Vector3.ONE * 0.65
		n.add_child(a)
	return n


# The right number plus two different wrong ones, in random order.
func _choices(right: int, top: int) -> Array:
	var others := range(1, top + 1)
	others.erase(right)
	others.shuffle()
	var all := [right, others[0], others[1]]
	all.shuffle()
	return all


func _tiles(values: Array) -> void:
	for i in values.size():
		var v: int = values[i]
		_add(Art.tile(str(v), Art.COLORS[v % 6]), v, Vector3((i - 1) * 1.6, -0.5, 2.0))


func _level_count() -> void:
	goal = randi_range(1, [3, 3, 4, 5][tier])
	var slots := _slots(6)
	for i in 6:
		_add(Art.apple(), i, slots[i])
	_dots(goal, 0)
	_ask(["count_%d" % (goal - 1)])


func _level_memory() -> void:
	var count: int = [3, 3, 4, 4][tier]
	var kinds := _pick(count, 6)
	var slots := _slots(count)
	for i in count:
		_add(Art.flower(Art.COLORS[kinds[i]]), i, slots[i])
	goal = [2, 3, 3, 4][tier]
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
	prompt = ["watch"]
	sound.say(prompt)
	await get_tree().create_timer(2.2).timeout
	for id in sequence:
		if mine != token:
			return
		sound.note(id * 4)
		_bounce(targets[id], 1.45)
		await get_tree().create_timer(0.9).timeout
	if mine == token:
		_ask(["repeat"])


func _level_order() -> void:
	goal = [3, 3, 4, 4][tier]
	var slots := _slots(goal)
	var c: Color = Art.COLORS.pick_random()
	var kind := randi() % 5
	for i in goal:
		_add(Art.shape(kind, c), i, slots[i], 0.55 + i * 0.28)
	_dots(goal, 0)
	_ask(["order"])


# Cards are shown face up for a moment, then turned over.
func _level_pairs() -> void:
	goal = [2, 3, 4, 4][tier]
	var kinds := _pick(goal, 6)
	var slots := _slots(goal * 2)
	for i in goal * 2:
		var n := Art.card(kinds[i % goal])
		n.set_meta("up", true)
		_add(n, kinds[i % goal], slots[i])
	_dots(goal, 0)
	busy = true
	prompt = ["pairs"]
	sound.say(prompt)
	var mine := token
	await get_tree().create_timer(3.5).timeout
	if mine != token:
		return
	for t in targets:
		_flip(t, false)
	busy = false
	idle = 0.0


func _flip(t: Node3D, up: bool) -> void:
	t.set_meta("up", up)
	var s: float = t.get_meta("size")
	var tw := t.create_tween()
	tw.tween_property(t, "scale:x", s * 0.05, 0.14)
	tw.tween_callback(func() -> void:
		t.get_node("Front").visible = up
		t.get_node("Back").visible = not up)
	tw.tween_property(t, "scale:x", s, 0.14)


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
	if mode in PICK:
		_tap_pick(t, id)
		return
	match mode:
		"animals":
			sound.note(id * 2)
			if id != sequence[step]:
				_wrong(t)
				return
			_collect(t)
			if _advance():
				return
			_drop_hint()
			_cheer()
			_ask(["animals_%d" % sequence[step]], Art.animal(sequence[step]), true)
		"balloons":
			sound.note(step * 2)
			_burst(t.global_position + Vector3(0, 0.9, 0), 30)
			targets.erase(t)
			t.queue_free()
			_cheer()
			_advance()
		"butterflies":
			sound.note(step * 2)
			_collect(t)
			_cheer()
			_advance()
		"peek":
			sound.note(step * 3)
			targets.erase(t)
			_burst(t.global_position + Vector3(0, 1.0, 0.5), 20)
			var friend: Node3D = t.get_node("Friend")
			var bush: Node3D = t.get_node("Bush")
			var tw := t.create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(friend, "position", Vector3(0, 0.45, 0.4), 0.5)
			tw.tween_property(friend, "scale", Vector3.ONE, 0.5)
			tw.tween_property(bush, "position", Vector3(0, -0.2, 0), 0.4)
			tw.tween_property(bush, "scale", Vector3.ONE * 0.6, 0.4)
			_cheer()
			_advance()
		"feed":
			sound.note(step * 2)
			targets.erase(t)
			var bunny: Node3D = stage.get_node("Friend")
			var tw := t.create_tween().set_parallel()
			tw.tween_property(t, "position", bunny.position + Vector3(0, 0.7, 0.8), 0.5).set_trans(Tween.TRANS_SINE)
			tw.tween_property(t, "scale", Vector3.ONE * 0.1, 0.5).set_ease(Tween.EASE_IN)
			tw.chain().tween_callback(t.queue_free)
			var munch := bunny.create_tween()
			munch.tween_interval(0.45)
			munch.tween_property(bunny, "scale", Vector3(1.32, 0.95, 1.2), 0.15)
			munch.tween_property(bunny, "scale", Vector3.ONE * 1.1, 0.3).set_trans(Tween.TRANS_BOUNCE)
			_cheer()
			_advance()
		"music":
			sound.note([0, 2, 4, 7, 9, 12][id], 0.6)
			_bounce(t, 1.45)
			_burst(t.global_position + Vector3(0, 1.0, 0.3), 8)
			if step % 3 == 2:
				_cheer()
			_advance()
		"count":
			sound.say(["numbers_%d" % step])
			_cheer()
			sound.note(step * 2)
			_collect(t)
			_advance()
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
			_advance()
		"order":
			if id != step:
				_wrong(t)
				return
			sound.note(step * 4)
			_collect(t)
			_cheer()
			_advance()
		"pairs":
			_tap_card(t, id)


# One more correct tap; wins the level when the goal is reached.
func _advance() -> bool:
	step += 1
	_dots(goal, step)
	if step < goal:
		return false
	_win()
	return true


func _tap_pick(t: Node3D, id: int) -> void:
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
		return
	busy = true
	var mine := token
	await get_tree().create_timer(1.8).timeout
	if mine == token:
		_pick_round()


func _tap_card(t: Node3D, id: int) -> void:
	if t.get_meta("up"):
		return
	sound.note(id * 2)
	_flip(t, true)
	if picked == null:
		picked = t
		return
	var first := picked
	picked = null
	busy = true
	var same: bool = first.get_meta("id") == id
	var mine := token
	await get_tree().create_timer(0.8 if same else 1.5).timeout
	if mine != token:
		return
	if same:
		_collect(first)
		_collect(t)
		_cheer()
		if _advance():
			return
	else:
		_flip(first, false)
		_flip(t, false)
		_encourage()
	busy = false


func _right(t: Node3D) -> bool:
	var id: int = t.get_meta("id")
	if mode in PICK:
		return id == goal
	match mode:
		"animals", "memory":
			return id == sequence[step]
		"order":
			return id == step
		"pairs":
			return picked == null or (t != picked and id == picked.get_meta("id"))
	return true


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
	sound.say([again] if mode == "memory" else [again] + prompt)


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
	# Write beside the save first, so a closed app never leaves half a file.
	if cfg.save(SAVE + ".tmp") == OK:
		DirAccess.rename_absolute(SAVE + ".tmp", SAVE)
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
	if mode == "balloons" or mode == "butterflies":
		var sway := 0.35 if mode == "butterflies" else 0.1
		for t in targets:
			var p: float = t.get_meta("phase")
			t.position = t.get_meta("home") + Vector3(sin(time * 1.3 + p) * sway, sin(time * 2.1 + p) * sway * 0.6, 0)
			if mode == "butterflies":
				t.get_node("WingL").rotation.y = sin(time * 11.0 + p) * 0.7
				t.get_node("WingR").rotation.y = -sin(time * 11.0 + p) * 0.7
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
			sound.say(prompt)
			_help()


func _help() -> void:
	for t in targets:
		if _right(t):
			_bounce(t, 1.3)
			return


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if privacy.visible:
			privacy.hide()
		elif age < 0:
			get_tree().quit()
		else:
			show_menu()
