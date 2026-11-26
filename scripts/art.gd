class_name Art

const COLORS: Array[Color] = [Color("ff5c6c"), Color("ffd23f"), Color("3f9dff"), Color("4fc66a"), Color("ff86c8"), Color("a66bff")]

static var _mats := {}


static func mat(c: Color) -> StandardMaterial3D:
	if not _mats.has(c):
		var m := StandardMaterial3D.new()
		m.albedo_color = c
		m.roughness = 0.6
		m.rim_enabled = true
		m.rim = 0.25
		_mats[c] = m
	return _mats[c]


static func part(parent: Node3D, mesh: Mesh, c: Color, pos := Vector3.ZERO, scl := Vector3.ONE, rot := Vector3.ZERO) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.material_override = mat(c)
	n.position = pos
	n.scale = scl
	n.rotation_degrees = rot
	parent.add_child(n)
	return n


static func ball(parent: Node3D, c: Color, pos: Vector3, size: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = 0.5
	m.height = 1.0
	return part(parent, m, c, pos, size, rot)


static func tube(parent: Node3D, c: Color, pos: Vector3, top: float, bottom: float, h: float, rot := Vector3.ZERO) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.top_radius = top
	m.bottom_radius = bottom
	m.height = h
	return part(parent, m, c, pos, Vector3.ONE, rot)


static func _eyes(n: Node3D, y: float, z: float, gap: float) -> void:
	for s in [-1.0, 1.0]:
		ball(n, Color("2b1d3a"), Vector3(s * gap, y, z), Vector3(0.13, 0.15, 0.08))
		ball(n, Color.WHITE, Vector3(s * gap + 0.025, y + 0.03, z + 0.04), Vector3.ONE * 0.045)
		ball(n, Color("ff9aa8"), Vector3(s * (gap + 0.14), y - 0.15, z - 0.04), Vector3(0.13, 0.08, 0.05))


# 0 bunny, 1 cat, 2 chick, 3 frog, 4 bear, 5 pig
static func animal(kind: int) -> Node3D:
	var n := Node3D.new()
	var c: Color = [Color("fff6f0"), Color("ffae57"), Color("ffe14d"), Color("6fd36a"), Color("b9825a"), Color("ffb0c4")][kind]
	ball(n, c, Vector3(0, 0.4, 0), Vector3(0.9, 0.8, 0.75))
	ball(n, c, Vector3(0, 1.05, 0.1), Vector3(0.95, 0.85, 0.8))
	for s in [-1.0, 1.0]:
		ball(n, c.darkened(0.12), Vector3(s * 0.3, 0.07, 0.25), Vector3(0.3, 0.18, 0.4))
	_eyes(n, 1.12, 0.49, 0.18)
	for s in [-1.0, 1.0]:
		match kind:
			0:
				ball(n, c, Vector3(s * 0.22, 1.72, 0), Vector3(0.24, 0.8, 0.18), Vector3(0, 0, -s * 12))
				ball(n, Color("ffb7c5"), Vector3(s * 0.22, 1.72, 0.08), Vector3(0.12, 0.55, 0.06), Vector3(0, 0, -s * 12))
			1:
				tube(n, c, Vector3(s * 0.3, 1.52, 0.05), 0.0, 0.19, 0.38, Vector3(0, 0, -s * 25))
			3:
				ball(n, c, Vector3(s * 0.2, 1.43, 0.3), Vector3.ONE * 0.34)
				ball(n, Color("2b1d3a"), Vector3(s * 0.2, 1.47, 0.47), Vector3.ONE * 0.14)
			4:
				ball(n, c, Vector3(s * 0.37, 1.45, 0.05), Vector3(0.34, 0.34, 0.2))
			5:
				tube(n, c.darkened(0.1), Vector3(s * 0.32, 1.46, 0.1), 0.0, 0.2, 0.32, Vector3(25, 0, -s * 35))
	match kind:
		2:
			tube(n, Color("ff8a1f"), Vector3(0, 0.93, 0.58), 0.0, 0.12, 0.22, Vector3(90, 0, 0))
			ball(n, c, Vector3(0, 1.52, 0.1), Vector3(0.14, 0.3, 0.14))
		4:
			ball(n, Color("f0d2b0"), Vector3(0, 0.9, 0.45), Vector3(0.38, 0.28, 0.2))
			ball(n, Color("2b1d3a"), Vector3(0, 0.96, 0.56), Vector3(0.12, 0.08, 0.06))
		5:
			ball(n, Color("ff8fac"), Vector3(0, 0.93, 0.48), Vector3(0.34, 0.24, 0.18))
		_:
			ball(n, Color("ff7d96"), Vector3(0, 0.94, 0.5), Vector3(0.11, 0.08, 0.06))
	return n


static func flower(c: Color, stem := true) -> Node3D:
	var n := Node3D.new()
	if stem:
		tube(n, Color("3f9e49"), Vector3(0, 0.4, -0.08), 0.06, 0.07, 0.9)
		ball(n, Color("55bd5c"), Vector3(0.22, 0.3, -0.05), Vector3(0.42, 0.14, 0.2), Vector3(0, 0, 28))
	for i in 6:
		var a := TAU * i / 6.0
		ball(n, c, Vector3(cos(a) * 0.34, 1.0 + sin(a) * 0.34, 0), Vector3(0.42, 0.42, 0.2))
	ball(n, Color("fff2b0") if c != COLORS[1] else Color("ff9f1c"), Vector3(0, 1.0, 0.1), Vector3(0.4, 0.4, 0.25))
	return n


static func balloon(c: Color) -> Node3D:
	var n := Node3D.new()
	ball(n, c, Vector3(0, 0.9, 0), Vector3(0.95, 1.15, 0.95))
	ball(n, c.lightened(0.6), Vector3(-0.2, 1.15, 0.42), Vector3(0.16, 0.26, 0.08), Vector3(0, 0, -25))
	tube(n, c, Vector3(0, 0.3, 0), 0.02, 0.1, 0.12)
	tube(n, Color("8a8a99"), Vector3(0, -0.1, 0), 0.012, 0.012, 0.7)
	return n


static func apple() -> Node3D:
	var n := Node3D.new()
	ball(n, Color("f0364a"), Vector3(0, 0.45, 0), Vector3(0.75, 0.7, 0.7))
	tube(n, Color("6b4226"), Vector3(0, 0.86, 0), 0.03, 0.04, 0.22, Vector3(0, 0, -15))
	ball(n, Color("55bd5c"), Vector3(0.17, 0.88, 0), Vector3(0.3, 0.12, 0.16), Vector3(0, 0, 25))
	return n


static func _prism(points: PackedVector2Array, depth: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var idx := Geometry2D.triangulate_polygon(points)
	var h := depth / 2.0
	for side in [1.0, -1.0]:
		for i in range(0, idx.size(), 3):
			var t := [idx[i], idx[i + 1], idx[i + 2]]
			var a := points[t[0]]
			var b := points[t[1]]
			var c := points[t[2]]
			if ((b - a).cross(c - a) > 0.0) == (side > 0.0):
				t.reverse()
			for k in t:
				st.add_vertex(Vector3(points[k].x, points[k].y, side * h))
	var cw := Geometry2D.is_polygon_clockwise(points)
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		if not cw:
			var tmp := a
			a = b
			b = tmp
		for v in [Vector3(a.x, a.y, h), Vector3(b.x, b.y, h), Vector3(b.x, b.y, -h), Vector3(a.x, a.y, h), Vector3(b.x, b.y, -h), Vector3(a.x, a.y, -h)]:
			st.add_vertex(v)
	st.generate_normals()
	return st.commit()


# 0 ball, 1 cube, 2 triangle, 3 star, 4 heart
static func shape(kind: int, c: Color) -> Node3D:
	var n := Node3D.new()
	var p := PackedVector2Array()
	match kind:
		0:
			ball(n, c, Vector3(0, 0.6, 0), Vector3.ONE * 1.05)
			return n
		1:
			var box := BoxMesh.new()
			box.size = Vector3(0.9, 0.9, 0.5)
			part(n, box, c, Vector3(0, 0.6, 0))
			return n
		2:
			p = PackedVector2Array([Vector2(0, 0.65), Vector2(0.62, -0.45), Vector2(-0.62, -0.45)])
		3:
			for i in 10:
				var a := PI / 2.0 + TAU * i / 10.0
				var r := 0.68 if i % 2 == 0 else 0.31
				p.append(Vector2(cos(a), sin(a)) * r)
		4:
			for i in 32:
				var t := TAU * i / 32.0
				p.append(Vector2(16.0 * pow(sin(t), 3), 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)) * 0.038)
	var m := part(n, _prism(p, 0.4), c, Vector3(0, 0.6, 0))
	var own := mat(c).duplicate() as StandardMaterial3D
	own.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.material_override = own
	return n


static func fairy() -> Node3D:
	var n := Node3D.new()
	var skin := Color("ffd2b0")
	var hair := Color("7a4a32")
	for s in [-1.0, 1.0]:
		var w := Node3D.new()
		w.name = "WingL" if s < 0 else "WingR"
		w.position = Vector3(s * 0.15, 0.75, -0.25)
		n.add_child(w)
		ball(w, Color("e6d4ff"), Vector3(s * 0.55, 0.25, 0), Vector3(1.0, 0.65, 0.08), Vector3(0, 0, s * 30))
		ball(w, Color("c9f0ff"), Vector3(s * 0.4, -0.25, 0), Vector3(0.65, 0.42, 0.08), Vector3(0, 0, -s * 25))
		ball(n, skin, Vector3(s * 0.16, -0.05, 0), Vector3(0.14, 0.45, 0.14))
		ball(n, Color("ff86c8"), Vector3(s * 0.16, -0.27, 0.06), Vector3(0.2, 0.14, 0.28))
		ball(n, skin, Vector3(s * 0.4, 0.65, 0.05), Vector3(0.13, 0.5, 0.13), Vector3(0, 0, s * 40))
		ball(n, hair, Vector3(s * 0.52, 1.35, -0.05), Vector3(0.4, 0.55, 0.4))
	tube(n, Color("a66bff"), Vector3(0, 0.45, 0), 0.18, 0.52, 0.8)
	ball(n, hair, Vector3(0, 1.45, -0.1), Vector3(1.15, 1.1, 0.95))
	ball(n, skin, Vector3(0, 1.35, 0.12), Vector3(0.92, 0.86, 0.82))
	ball(n, hair, Vector3(-0.15, 1.72, 0.3), Vector3(0.68, 0.28, 0.45), Vector3(0, 0, 18))
	_eyes(n, 1.37, 0.52, 0.18)
	ball(n, Color("d9536a"), Vector3(0, 1.13, 0.5), Vector3(0.16, 0.07, 0.05)).name = "Mouth"
	var crown := shape(3, Color("ffd23f"))
	crown.scale = Vector3.ONE * 0.32
	crown.position = Vector3(0.28, 1.72, 0.45)
	n.add_child(crown)
	return n


static func label(parent: Node3D, text: String, size: int, pos: Vector3, c := Color("4a2a66")) -> void:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.pixel_size = 0.006
	l.modulate = c
	l.outline_modulate = Color.WHITE
	l.outline_size = 24
	l.position = pos
	parent.add_child(l)


static func box(parent: Node3D, c: Color, pos: Vector3, size: Vector3) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = size
	return part(parent, m, c, pos)


static func tile(text: String, c: Color) -> Node3D:
	var n := Node3D.new()
	box(n, c, Vector3(0, 0.7, 0), Vector3(1.15, 1.25, 0.2))
	box(n, Color("fff8ff"), Vector3(0, 0.7, 0.1), Vector3(0.95, 1.05, 0.06))
	label(n, text, 120, Vector3(0, 0.7, 0.16))
	return n


# Memory card: "Front" shows the animal, "Back" shows a star.
static func card(kind: int) -> Node3D:
	var n := Node3D.new()
	var front := Node3D.new()
	front.name = "Front"
	n.add_child(front)
	box(front, Color("fff8ff"), Vector3(0, 0.75, 0), Vector3(1.15, 1.45, 0.1))
	var friend := animal(kind)
	friend.scale = Vector3.ONE * 0.52
	friend.position = Vector3(0, 0.2, 0.3)
	front.add_child(friend)
	var back := Node3D.new()
	back.name = "Back"
	back.visible = false
	n.add_child(back)
	box(back, Color("a66bff"), Vector3(0, 0.75, 0), Vector3(1.15, 1.45, 0.12))
	var star := shape(3, Color("ffd23f"))
	star.scale = Vector3.ONE * 0.6
	star.position = Vector3(0, 0.39, 0.2)
	back.add_child(star)
	return n


static func butterfly(c: Color) -> Node3D:
	var n := Node3D.new()
	var dark := Color("4a2a66")
	for s in [-1.0, 1.0]:
		var w := Node3D.new()
		w.name = "WingL" if s < 0 else "WingR"
		w.position = Vector3(s * 0.05, 0.75, 0)
		n.add_child(w)
		ball(w, c, Vector3(s * 0.38, 0.18, 0), Vector3(0.72, 0.58, 0.08), Vector3(0, 0, s * 25))
		ball(w, c.lightened(0.35), Vector3(s * 0.3, -0.25, 0), Vector3(0.5, 0.42, 0.08), Vector3(0, 0, -s * 20))
		ball(w, Color.WHITE, Vector3(s * 0.45, 0.22, 0.05), Vector3(0.18, 0.18, 0.04))
		tube(n, dark, Vector3(s * 0.12, 1.38, 0), 0.015, 0.015, 0.3, Vector3(0, 0, -s * 30))
		ball(n, dark, Vector3(s * 0.2, 1.52, 0), Vector3.ONE * 0.08)
	ball(n, dark, Vector3(0, 0.7, 0.03), Vector3(0.16, 0.65, 0.16))
	ball(n, Color("ffd2b0"), Vector3(0, 1.12, 0.05), Vector3.ONE * 0.34)
	for s in [-1.0, 1.0]:
		ball(n, dark, Vector3(s * 0.07, 1.15, 0.22), Vector3.ONE * 0.06)
	return n


static func bush() -> Node3D:
	var n := Node3D.new()
	var greens := [Color("3fae52"), Color("55c465"), Color("48b95a")]
	var spots := [Vector3(-0.42, 0.38, 0), Vector3(0.42, 0.38, 0), Vector3(0, 0.66, 0), Vector3(0, 0.3, 0.12)]
	for i in 4:
		ball(n, greens[i % 3], spots[i], Vector3(1.0, 0.9, 0.7))
	for p in [Vector3(-0.5, 0.55, 0.36), Vector3(0.45, 0.28, 0.4), Vector3(0.1, 0.85, 0.38), Vector3(-0.12, 0.25, 0.5)]:
		ball(n, Color("ff86c8"), p, Vector3.ONE * 0.13)
	return n


# 0 apple, 1 banana, 2 strawberry, 3 orange, 4 grapes, 5 carrot
static func fruit(kind: int) -> Node3D:
	if kind == 0:
		return apple()
	var n := Node3D.new()
	var leaf := Color("4fb856")
	match kind:
		1:
			for i in 11:
				var a := -1.0 + i * 0.2
				var w := 0.36 - absf(a) * 0.16
				ball(n, Color("ffd91f"), Vector3(sin(a) * 0.62, 1.05 - cos(a) * 0.58, 0), Vector3(w, w, w))
			ball(n, Color("6b4226"), Vector3(0.56, 0.76, 0), Vector3.ONE * 0.11)
		2:
			tube(n, Color("ee2f4b"), Vector3(0, 0.45, 0), 0.4, 0.04, 0.72)
			ball(n, Color("ee2f4b"), Vector3(0, 0.8, 0), Vector3(0.8, 0.38, 0.8))
			for p in [Vector3(-0.17, 0.68, 0.37), Vector3(0.17, 0.68, 0.37), Vector3(0, 0.52, 0.3), Vector3(-0.08, 0.34, 0.2), Vector3(0.1, 0.4, 0.23)]:
				ball(n, Color("ffe27a"), p, Vector3(0.06, 0.08, 0.06))
			for s in [-1.0, 0.0, 1.0]:
				ball(n, leaf, Vector3(s * 0.2, 1.02, 0.1), Vector3(0.32, 0.12, 0.18), Vector3(0, 0, s * 25))
		3:
			ball(n, Color("ff9416"), Vector3(0, 0.55, 0), Vector3.ONE * 0.9)
			ball(n, leaf, Vector3(0.14, 1.04, 0), Vector3(0.36, 0.14, 0.18), Vector3(0, 0, 25))
			ball(n, Color("6b4226"), Vector3(0, 0.99, 0), Vector3.ONE * 0.1)
		4:
			var rows := [4, 3, 2, 1]
			for r in 4:
				for i in rows[r]:
					ball(n, Color("8e44d6"), Vector3((i - (rows[r] - 1) / 2.0) * 0.27, 0.9 - r * 0.24, 0.04 * (r % 2)), Vector3.ONE * 0.33)
			tube(n, Color("6b4226"), Vector3(0, 1.14, 0), 0.03, 0.04, 0.24)
			ball(n, leaf, Vector3(0.2, 1.12, 0), Vector3(0.34, 0.14, 0.18), Vector3(0, 0, 20))
		5:
			tube(n, Color("ff7d1a"), Vector3(0, 0.48, 0), 0.27, 0.02, 0.9)
			ball(n, Color("ff7d1a"), Vector3(0, 0.93, 0), Vector3(0.54, 0.22, 0.54))
			for s in [-1.0, 0.0, 1.0]:
				ball(n, leaf, Vector3(s * 0.15, 1.18, 0), Vector3(0.13, 0.45, 0.13), Vector3(0, 0, -s * 30))
	return n


# Age pictures for the menu: 0 baby, 1 toddler, 2 child.
static func kid(kind: int) -> Node3D:
	var n := Node3D.new()
	var skin := Color("ffd2b0")
	var hair := Color("7a4a32")
	var pink := Color("ff5fae")
	if kind == 0:
		var suit := Color("ffb6dc")
		ball(n, suit, Vector3(0, 0.36, 0), Vector3(0.74, 0.62, 0.55))
		for s in [-1.0, 1.0]:
			ball(n, suit, Vector3(s * 0.28, 0.14, 0.24), Vector3(0.32, 0.24, 0.46))
			ball(n, skin, Vector3(s * 0.28, 0.13, 0.5), Vector3.ONE * 0.19)
			ball(n, skin, Vector3(s * 0.42, 0.42, 0.1), Vector3(0.17, 0.36, 0.17), Vector3(0, 0, s * 40))
		ball(n, skin, Vector3(0, 1.0, 0.05), Vector3(0.9, 0.84, 0.76))
		ball(n, hair, Vector3(0.03, 1.45, 0.15), Vector3(0.24, 0.16, 0.14), Vector3(0, 0, 30))
		_eyes(n, 1.06, 0.41, 0.17)
		ball(n, Color("5fb8ff"), Vector3(0, 0.82, 0.42), Vector3(0.3, 0.22, 0.1))
		ball(n, Color("ffd23f"), Vector3(0, 0.82, 0.49), Vector3.ONE * 0.1)
		return n
	var tall := kind == 2
	var leg := 0.72 if tall else 0.4
	var dress := Color("a66bff") if tall else Color("ffd23f")
	var skirt := 0.78 if tall else 0.62
	var body := leg + skirt / 2.0 - 0.05
	var head := leg + skirt + (0.3 if tall else 0.28)
	for s in [-1.0, 1.0]:
		ball(n, skin, Vector3(s * 0.15, leg / 2.0 + 0.03, 0), Vector3(0.16, leg + 0.08, 0.16))
		ball(n, pink, Vector3(s * 0.16, 0.06, 0.08), Vector3(0.23, 0.15, 0.32))
		ball(n, skin, Vector3(s * 0.38, body + 0.05, 0.05), Vector3(0.13, skirt * 0.72, 0.13), Vector3(0, 0, s * 36))
	tube(n, dress, Vector3(0, body, 0), 0.17, 0.46, skirt)
	ball(n, hair, Vector3(0, head - (0.05 if tall else -0.07), -0.14), Vector3(0.9, 1.08 if tall else 0.86, 0.66))
	ball(n, skin, Vector3(0, head, 0.06), Vector3(0.76, 0.72, 0.66))
	ball(n, hair, Vector3(-0.12, head + 0.29, 0.2), Vector3(0.58, 0.24, 0.4), Vector3(0, 0, 16))
	_eyes(n, head + 0.02, 0.39, 0.15)
	ball(n, Color("d9536a"), Vector3(0, head - 0.2, 0.37), Vector3(0.16, 0.07, 0.05))
	for s in [-1.0, 1.0]:
		if not tall:
			ball(n, hair, Vector3(s * 0.5, head + 0.22, -0.02), Vector3.ONE * 0.34)
		ball(n, pink, Vector3((s * 0.37) if not tall else (0.22 + s * 0.12), head + 0.33, 0.22), Vector3(0.2, 0.15, 0.1), Vector3(0, 0, s * 25))
	return n
