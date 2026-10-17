extends Node2D
## META-RPG (Godot 4.2+): Undertale tarzı mekanikler, tamamen orijinal içerik.
## Online için SERVER'a bilgisayarındaki server.js adresini yaz (ws://IP:3000). Solo: bot/canavarlarla oynanır.
const SERVER = "ws://192.168.1.10:3000"
const ROOM = "oda1"
const COST = [20, 50]
const HERO = ["..HHHH..", ".HHHHHH.", ".HSSSSH.", ".SKSSKS.", ".SSSSSS.", "..OOOO..", ".OOAAOO.", "SOOOOOOS", "..OOOO..", "..K..K.."]
const LONG = ["..HHHH..", ".HHHHHH.", "HHSSSSHH", "HSKSSKSH", "HSSSSSSH", "HHOOOOHH", ".OOAAOO.", "SOOOOOOS", "..OOOO..", "..K..K.."]
const OB = [Rect2(110, 120, 32, 32), Rect2(338, 120, 32, 32), Rect2(224, 158, 40, 24)]
const NPC = [Vector2(70, 84), Vector2(400, 84), Vector2(70, 206), Vector2(400, 206)]
const NPAL = [["#f7a", "#a3a"], ["#fa0", "#a60"], ["#3d3", "#183"], ["#ccc", "#555"]]
const FL = ["Hava gerilimle dolu.", "Rakip seni inceliyor.", "Kalbin hızlı atıyor.", "Bu dövüşü hatırlayacaksın."]
const TAUNT = {"gojo|sukuna": "Tarihin en güçlüsü mü? Hangisi?", "goku|saitama": "Biri ciddi, biri bıkmış.", "itachi|naruto": "Gölgenin ardındaki hesaplaşma.", "levi|light": "Defter mi, bıçak mı?", "goku|luffy": "Kauçuk mu, Saiyan mı?"}

var CH = []
var MON = []
var mem = {"dark": 0, "fair": 0, "runs": 0, "kill": 0, "spare": 0, "exp": 0, "last": "", "hid": 0}
var mode = "menu"
var tt = 0.0
var mi = 0
var sel = 0
var logo = 0
var egg = 0
var me = {}
var op = {}
var slot = 0
var st = null
var md = false
var od = false
var ws = null
var joined = false
var os = 0
var Q = {}
var loc = false
var pve = false
var info = ""
var D = null
var wp = Vector2(240, 200)
var used = [false, false, false, false]
var steps = 0.0
var npc_i = 0
var si = 0
var wm = false
var msub = ""
var mm = 0
var si2 = 0
var cur = 0.0
var cdir = 1.0
var ft = ""
var ti = 0.0
var ftl = 0.0
var ai = 0.0
var ehp = 0.0
var slash = 0.0
var bl = []
var qq = []
var T = 0.0
var dur = 0.0
var hits = 0
var inv = 0.0
var ht = Vector2(0.5, 0.5)
var pp = Vector2(0.5, 0.5)
var vy = 0.0
var blue = false
var mv = false
var jump = false
var bw = 400.0
var bh = 80.0
var shr = 1.0
var shrT = 1.0
var rotc = 0.0
var rotT = 0.0
var exv = 0.0
var exT = 0.0
var invM = false
var blindM = false
var fastM = 1.0
var shake = 0.0
var gl = 0.0
var bn_s = ""
var bn_t = 0.0
var bub = ""
var bub_t = 0.0
var floats = []
var touch_v = Vector2.ZERO
var drag_o = Vector2.ZERO
var drag_d = 0.0
var dragging = false
var font

func _ready():
	randomize()
	font = ThemeDB.fallback_font
	var f = FileAccess.open("res://chars.json", FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text())
	CH = d.chars
	MON = d.mons
	var m = FileAccess.open("user://mem.json", FileAccess.READ)
	if m != null:
		var x = JSON.parse_string(m.get_as_text())
		if x is Dictionary:
			mem.merge(x, true)
	var map = {"ok": [KEY_Z, KEY_ENTER], "back": [KEY_X, KEY_SHIFT], "menu": [KEY_C, KEY_CTRL], "left": [KEY_LEFT, KEY_A], "right": [KEY_RIGHT, KEY_D], "up": [KEY_UP, KEY_W], "down": [KEY_DOWN, KEY_S]}
	var jb = {"ok": JOY_BUTTON_A, "back": JOY_BUTTON_B, "menu": JOY_BUTTON_Y, "left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT, "up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN}
	for a in map:
		InputMap.add_action(a)
		for k in map[a]:
			var e = InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(a, e)
		var j = InputEventJoypadButton.new()
		j.button_index = jb[a]
		InputMap.action_add_event(a, j)
	var ax = {"left": [JOY_AXIS_LEFT_X, -1.0], "right": [JOY_AXIS_LEFT_X, 1.0], "up": [JOY_AXIS_LEFT_Y, -1.0], "down": [JOY_AXIS_LEFT_Y, 1.0]}
	for a in ax:
		var e = InputEventJoypadMotion.new()
		e.axis = ax[a][0]
		e.axis_value = ax[a][1]
		InputMap.action_add_event(a, e)

# ---------- yardımcılar ----------
func save_mem():
	var f = FileAccess.open("user://mem.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(mem))
func lv(): return 1 + int(mem.exp / 8)
func aln(): return mem.dark + mem.kill > mem.fair + mem.spare
func vis(): return CH.filter(func(c): return not c.get("hid", false) or mem.hid > 0)
func byid(i):
	for c in CH + MON:
		if c.i == i: return c
	return CH[0]
func col(s): return Color.html(s)
func pal(c): return {"H": col(c.h), "S": Color.html("#fca"), "O": col(c.o), "A": col(c.a), "K": Color.html("#111")}
func bn(s, t): bn_s = s; bn_t = t
func wr(s, n):
	var o = []
	var l = ""
	for w in s.split(" "):
		if (l + w).length() > n:
			o.append(l.strip_edges())
			l = ""
		l += w + " "
	o.append(l.strip_edges())
	return o
func tx(s, x, y, c = Color.WHITE, z = 8, a = 0):
	if a == 0: draw_string(font, Vector2(x, y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, z, c)
	elif a == 1: draw_string(font, Vector2(x - 300, y), s, HORIZONTAL_ALIGNMENT_CENTER, 600, z, c)
	else: draw_string(font, Vector2(x - 600, y), s, HORIZONTAL_ALIGNMENT_RIGHT, 600, z, c)
func heart(x, y, s, c):
	draw_colored_polygon(PackedVector2Array([Vector2(x, y + s * 0.5), Vector2(x - s * 0.6, y - s * 0.1), Vector2(x - s * 0.35, y - s * 0.5), Vector2(x, y - s * 0.2), Vector2(x + s * 0.35, y - s * 0.5), Vector2(x + s * 0.6, y - s * 0.1)]), c)
func spr(r, x, y, s, p, flip = false):
	for j in r.size():
		for i in r[j].length():
			var h = r[j][i]
			if h != ".": draw_rect(Rect2(x + (7 - i if flip else i) * s, y + j * s, s, s), p[h])
func box(r, c):
	draw_rect(r, Color.BLACK)
	draw_rect(r, c, false, 3.0)
func btn(l, x, y, w, h, on, c):
	draw_rect(Rect2(x, y, w, h), c if on else Color.html("#555"), false, 2.0)
	tx(l, x + w / 2, y + h / 2 + 3, c if on else Color.html("#555"), 8, 1)

# ---------- ağ + yerel sunucu (aynı protokol) ----------
func send(o):
	if loc: loc_send(o)
	elif ws != null and ws.get_ready_state() == WebSocketPeer.STATE_OPEN: ws.send_text(JSON.stringify(o))
func net_poll():
	if ws == null: return
	ws.poll()
	var s = ws.get_ready_state()
	if s == WebSocketPeer.STATE_OPEN:
		if not joined:
			joined = true
			send({"t": "join", "room": ROOM})
		while ws.get_available_packet_count() > 0:
			var m = JSON.parse_string(ws.get_packet().get_string_from_utf8())
			if not loc: on_msg(m)
	elif s == WebSocketPeer.STATE_CLOSED:
		info = "BAĞLANTI KOPTU (" + SERVER + ")"
		ws = null
		joined = false
		if mode == "online": mode = "menu"
func emit(m): get_tree().create_timer(0.0).timeout.connect(on_msg.bind(m.duplicate(true)))
func after(sec, fn): get_tree().create_timer(sec).timeout.connect(_fire.bind(Q.get("id", -1), fn))
func _fire(qid, fn):
	if loc and Q.get("id", -2) == qid: fn.call()
func stm(): return {"t": "state", "turn": Q.turn, "phase": Q.ph, "sp": Q.sp, "hp": [Q.p[0].hp, Q.p[1].hp], "en": [Q.p[0].en, Q.p[1].en], "items": [Q.p[0].it, Q.p[1].it]}
func loc_start(bot):
	loc = true
	os = slot
	slot = 0
	Q = {"p": [{"hp": 100, "en": 30, "it": 3}, {"hp": 100, "en": 30, "it": 3}], "sp": [0, 0], "turn": 0, "ph": "choose", "bot": bot, "id": randi(), "dt": 0}
	emit({"t": "arena", "chars": [me.i, bot.i], "dark": [md, false], "last": [mem.last, ""], "turn": 0})
	emit(stm())
func loc_over(w):
	Q.ph = "over"
	emit(stm())
	emit({"t": "over", "winner": w})
func loc_next():
	Q.turn = 1 - Q.turn
	Q.ph = "choose"
	Q.p[Q.turn].en = min(100, Q.p[Q.turn].en + 10)
	emit(stm())
	if Q.turn == 1: after(1.1, bot_act)
func loc_endd(h):
	if Q.ph != "dodge": return
	Q.dt += 1
	var a = Q.turn
	var d = 1 - a
	var dm = 8 + (3 if (a == 0 and md) else 0)
	Q.p[d].hp = max(0, Q.p[d].hp - clampi(int(h), 0, 8) * dm)
	if Q.p[d].hp <= 0: loc_over(a)
	else: loc_next()
func loc_go(kind, h):
	Q.ph = "dodge"
	emit(stm())
	emit({"t": "fx", "n": kind})
	var tok = Q.dt
	after(h[0], _dodge_to.bind(tok, h[1]))
func _dodge_to(tok, hh):
	if Q.dt == tok: loc_endd(hh)
func bot_act():
	if Q.ph != "choose" or Q.turn != 1: return
	var b = Q.p[1]
	var bot = Q.bot
	var r = randf()
	if b.hp < 30 and b.it > 0 and r < 0.4:
		b.it -= 1
		b.hp = min(100, b.hp + 25)
		loc_next()
		return
	var pat = bot.b
	var mod = ""
	var kind = "basic"
	var bs = true
	if r < 0.3 and b.en >= 20:
		var i = 1 if (b.en >= 50 and randf() < 0.5) else 0
		b.en -= COST[i]
		pat = bot.k[i][1]
		mod = bot.k[i][2]
		kind = "s" + str(i)
		bs = false
	else:
		b.en = min(100, b.en + 15)
		Q.p[0].hp = max(0, Q.p[0].hp - (2 + randi() % 9))
		if Q.p[0].hp <= 0:
			loc_over(1)
			return
	loc_go(kind, [15.0, 0])
	emit({"t": "wave", "kind": kind, "pat": pat, "mod": mod, "wave": gen(pat, bs)})
func loc_send(m):
	var p = Q.p[0]
	if m.t == "done":
		if Q.ph == "dodge" and Q.turn == 1: loc_endd(m.hits)
		return
	if m.t != "act" or Q.ph != "choose" or Q.turn != 0: return
	match m.k:
		"item":
			if p.it <= 0: return
			p.it -= 1
			p.hp = min(100, p.hp + 25)
			loc_next()
		"act":
			if int(m.i) == 1: Q.sp[1] += 1
			loc_next()
		"spare":
			if Q.sp[1] >= 3:
				Q.ph = "over"
				emit({"t": "mercy", "by": 0})
			else: loc_next()
		"flee":
			Q.ph = "over"
			emit({"t": "mercy", "by": 0, "flee": true})
		"fight":
			p.en = min(100, p.en + 15)
			Q.sp[1] = 0
			Q.p[1].hp = max(0, Q.p[1].hp - (2 + lv() + int(clampf(float(m.acc), 0.0, 1.0) * 16)))
			if Q.p[1].hp <= 0: loc_over(0)
			else: loc_go("basic", [3.5, randi() % 3])
		"skill":
			var i = int(m.i)
			if p.en < COST[i]: return
			p.en -= COST[i]
			loc_go("s" + str(i), [3.5, randi() % 3])
func on_msg(m):
	if m == null: return
	match m.t:
		"joined":
			slot = int(m.slot)
			mode = "select"
			if mem.runs > 0: bn("[%d. DÖNGÜ] \"%s\" demiştin. Unutmadım." % [int(mem.runs) + 1, mem.last], 5)
		"err": info = m.m
		"fx": fx(m.n)
		"say": bn(m.s, 4)
		"arena":
			me = byid(m.chars[slot])
			op = byid(m.chars[1 - slot])
			md = bool(m.dark[slot])
			od = bool(m.dark[1 - slot])
			mode = "arena"
			if not pve: mem.runs += 1
			save_mem()
			gl = 1.0
			shake = 30.0
			msub = ""
			ai = 1.2
			mm = 0
			ehp = 0.0
			egg = 0
			var k = [me.i, op.i]
			k.sort()
			bn("Duvarın ardındaki izleyici sahneye çıktı." if "void" in k else TAUNT.get(k[0] + "|" + k[1], me.n + " VS " + op.n), 4)
		"state":
			if st != null:
				for i in 2:
					var d = int(m.hp[i]) - int(st.hp[i])
					if d != 0: floats.append({"t": 1.2, "x": 90.0 if i == slot else 240.0, "y": 196.0 if i == slot else 40.0, "s": ("+" if d > 0 else "") + str(d), "c": Color.html("#4f4") if d > 0 else Color.html("#f33")})
					if d < 0:
						shake = 14.0
						if i != slot: ehp = 2.0
			st = m
			msub = ""
			if ftl <= 0:
				var my = m.phase == "choose" and int(m.turn) == slot
				ft = ("* " + FL[randi() % 4]) if my else ("* Dalga gönderildi..." if (m.phase == "dodge" and int(m.turn) == slot) else "* Rakip seçiyor...")
				ti = 0.0
		"wave": start_dodge(m.mod, m.wave)
		"mercy":
			var mine = int(m.by) == slot
			var flee = m.get("flee", false)
			if pve and mine and not flee:
				mem.spare += 1
				save_mem()
			end_game(("KAÇTIN." if mine else "RAKİP KAÇTI.") if flee else ("RAKİBİ BAĞIŞLADIN. Kimse ölmedi." if mine else ("\"Ok.\" Maç bitti." if op.i == "saitama" else "RAKİP SENİ BAĞIŞLADI.")))
		"over":
			var won = int(m.winner) == slot
			if pve and won:
				mem.kill += 1
				mem.exp += 4
				save_mem()
			end_game(("KAZANDIN." + (" EXP +4" if pve else "")) if won else ("YENİLDİN... Kararlılık seni ayağa kaldırdı." if pve else "KAYBETTİN. Hafıza silinmez."))
		"left": end_game("RAKİP KAÇTI.")
		"rematch":
			mode = "select"
			st = null
			D = null
			rotT = 0.0
			shrT = 1.0
			exT = 0.0
			bl = []
			info = ""
func end_game(t):
	mode = "over"
	info = t
	gl = 1.2
	shake = 30.0
	if pve: get_tree().create_timer(2.6).timeout.connect(back_world)
func back_world():
	if not pve: return
	loc = false
	pve = false
	Q = {}
	slot = os
	st = null
	bl = []
	rotT = 0.0
	shrT = 1.0
	exT = 0.0
	mode = "world"
	wp = Vector2(240, 100)
	steps = 0.0
	bn("LV %d  EXP %d" % [lv(), int(mem.exp)], 2)
func fx(n):
	match n:
		"peerglitch": gl = 1.5; shake = 25.0
		"s1":
			exT = 1.0
			shake = 25.0
			gl = 0.3
			get_tree().create_timer(7.5).timeout.connect(func(): exT = 0.0)
		"s0": shake = 12.0; gl = 0.1
		"nani": gl = 1.5; shake = 20.0
func start_solo():
	if loc: return
	pve = false
	var p = CH.filter(func(c): return not c.get("hid", false) and c.i != me.i)
	loc_start(p[randi() % p.size()])
func encounter():
	if loc or D != null: return
	pve = true
	loc_start(MON[randi() % MON.size()])

# ---------- hikaye / dünya ----------
func say(w, t, ch): D = {"w": w, "t": t, "i": 0.0, "ch": ch, "L": wr(t, 52), "sw": randf() < 0.5, "cs": 0}
func shared(i):
	if i == 0: return ["???", "Bu seçimleri sen mi yapıyorsun, yoksa seni izleyen mi?", "Ben yapıyorum", "Beni izleyen sensin"]
	if mem.runs > 0 and mem.last != "": return ["HAFIZA", str(int(mem.runs) + 1) + ". döngü. Son seçimin: \"" + mem.last + "\". Unutmadım.", "Hatırlamak iyi", "Sil onu"]
	return ["???", "Seçimlerin kaydediliyor. Duvarın ardını duyuyor musun?", "Duyuyorum", "Duymak istemiyorum"]
func scene(i):
	npc_i = i
	var s = me.q[i] if i < 2 else shared(i - 2)
	say(s[0], "* " + s[1], [{"l": s[2], "k": "f"}, {"l": s[3], "k": "d"}])
func pick(c):
	mem.last = c.l
	if c.k == "d":
		mem.dark += 1
		shake = 10.0
		gl = 0.15
	else: mem.fair += 1
	save_mem()
	D = null
	used[npc_i] = true
	si += 1
	if si >= 4: get_tree().create_timer(1.2).timeout.connect(climax)
func climax():
	md = aln()
	gl = 2.8
	shake = 40.0
	mode = "wait"
	if ws != null and not loc: send({"t": "ready", "ch": me.i, "dark": md, "last": mem.last})
	else: get_tree().create_timer(1.8).timeout.connect(start_solo)
func start_story():
	mode = "world"
	si = 0
	used = [false, false, false, false]
	wp = Vector2(240, 200)
	steps = 0.0
	wm = false
	say("*", "* Kendini Kararlılıkla dolu hissediyorsun.", null)
func hit_wall(p):
	if p.x < 16 or p.x > 464 or p.y < 56 or p.y > 252: return true
	for o in OB:
		if p.x > o.position.x - 6 and p.x < o.end.x + 6 and p.y > o.position.y - 2 and p.y < o.end.y + 12: return true
	return false
func interact():
	for i in 4:
		if not used[i] and NPC[i].distance_to(wp) < 34:
			scene(i)
			return
	if Vector2(240, 66).distance_to(wp) < 40:
		save_mem()
		say("*", "* Kararlılık seni dolduruyor. (Kayıt alındı.)", null)

# ---------- mermi dalgası üretimi ----------
func ed():
	var r = randf()
	return [[r, -0.05, 0, 1], [r, 1.05, 0, -1], [-0.05, r, 1, 0], [1.05, r, -1, 0]][randi() % 4]
func ob(t, u, v, vu, vv, r = 0.035, x = {}):
	var d = {"t": t, "k": "o", "c": 0, "u": u, "v": v, "vu": vu, "vv": vv, "r": r}
	d.merge(x, true)
	return d
func ln(t, o, p, warn, life, th): return {"t": t, "k": "l", "o": o, "p": p, "warn": warn, "life": life, "th": th}
func gen(p, bs = false):
	var a = []
	var n = 0.65 if bs else 1.0
	var N = 0
	match p:
		"rain":
			N = int(26 * n)
			for i in N: a.append(ob(0.3 + i * 6.0 / N, randf(), -0.05, (randf() - 0.5) * 0.1, 0.3 + randf() * 0.15))
		"pull":
			N = int(30 * n)
			for i in N:
				var e = ed()
				var s = 0.28 + randf() * 0.15
				a.append(ob(0.3 + i * 6.0 / N, e[0], e[1], e[2] * s, e[3] * s, 0.035, {"c": 1 if i % 2 else 2}))
		"ring":
			for w in 4:
				for i in 14:
					var A = i / 14.0 * TAU + w * 0.2
					a.append(ob(1.2 + w * 1.5, 0.5 + cos(A) * 0.12, 0.5 + sin(A) * 0.12, cos(A) * 0.3, sin(A) * 0.3))
		"spiral":
			N = int(36 * n)
			for i in N:
				var A = i * 0.55
				a.append(ob(0.8 + i * 0.12, 0.5 + cos(A) * 0.1, 0.5 + sin(A) * 0.1, cos(A) * 0.32, sin(A) * 0.32))
		"aim":
			N = int(14 * n)
			for i in N:
				var e = ed()
				a.append(ob(0.5 + i * 5.0 / N, e[0], e[1], 0.45, 0.0, 0.04, {"aim": 1}))
		"beam":
			N = int(11 * n)
			for i in N: a.append(ln(0.4 + i * 0.55, "h" if randf() < 0.5 else "v", 0.1 + randf() * 0.8, 0.55, 0.2, 0.1))
		"big":
			for i in (2 if bs else 3): a.append(ln(0.5 + i * 1.9, "h" if randf() < 0.5 else "v", 0.25 + randf() * 0.5, 0.9, 0.35, 0.3))
		"wave":
			N = int(18 * n)
			for i in N:
				var d = 1 if i % 2 else -1
				a.append(ob(0.3 + i * 0.33, -0.05 if d > 0 else 1.05, 0.5, d * 0.3, 0.0, 0.035, {"v0": 0.1 + randf() * 0.8, "A": 0.1, "f": 4 + randf() * 2}))
		"rush":
			N = int(20 * n)
			for i in N:
				var e = ed()
				a.append(ob(0.3 + i * 0.28, e[0], e[1], e[2] * 0.75, e[3] * 0.75, 0.03, {"c": 2}))
		"orb":
			N = int(ceil(4 * n))
			for i in N:
				var e = ed()
				a.append(ob(0.5 + i * 1.2, e[0], e[1], 0.22, 0.0, 0.09, {"aim": 1, "dl": 6}))
		"barr":
			for w in (4 if bs else 6):
				var e = ed()
				var g0 = randi() % 7
				for i in 8:
					if i != g0 and i != g0 + 1:
						var z = (i + 0.5) / 8.0
						a.append(ob(0.5 + w * 0.9, e[0] if e[2] != 0 else z, z if e[2] != 0 else e[1], e[2] * 0.3, e[3] * 0.3, 0.04))
		"lurk":
			N = int(14 * n)
			for i in N: a.append(ob(0.5 + i * 0.4, 0.1 + randf() * 0.8, 0.1 + randf() * 0.8, 0.0, 0.0, 0.05, {"wn": 0.6, "dl": 2.2}))
	for b in a:
		if b.k == "o" and b.c == 0:
			var r = randf()
			b.c = 3 if r < 0.12 else (4 if r < 0.24 else 0)
	return a
func start_dodge(mo, w):
	mode = "dodge"
	qq = w.duplicate(true)
	qq.sort_custom(func(a, b): return a.t < b.t)
	bl = []
	T = 0.0
	hits = 0
	inv = 0.0
	ht = Vector2(0.5, 0.5)
	blue = "blue" in mo
	vy = 0.0
	if blue: ht.y = 0.9
	pp = ht
	bub = (["Dayan.", "Eğlenelim!", "Ağlama..."] if od else ["Hazır ol!", "Acele etme.", "Nefes al."])[randi() % 3]
	bub_t = 2.0
	dur = 2.0
	for b in qq: dur = max(dur, b.t + ((b.warn + b.life) if b.k == "l" else b.get("dl", 2.8)))
	if "flip" in mo: rotT = 180.0
	if "shrink" in mo: shrT = 0.55
	invM = "inv" in mo
	blindM = "blind" in mo
	fastM = 1.3 if "fast" in mo else 1.0

# ---------- girdi ----------
func press(a):
	if mode == "menu":
		if a == "up" or a == "down": mi = 1 - mi
		elif a == "ok":
			if mi == 0: mode = "select"
			else:
				ws = WebSocketPeer.new()
				ws.connect_to_url(SERVER)
				joined = false
				info = "Bağlanılıyor..."
				mode = "online"
	elif mode == "online":
		if a == "back":
			ws = null
			mode = "menu"
	elif mode == "select":
		var v = vis()
		var n = v.size()
		if a == "left": sel = (sel + n - 1) % n
		elif a == "right": sel = (sel + 1) % n
		elif a == "up": sel = (sel + n - 5) % n
		elif a == "down": sel = (sel + 5) % n
		elif a == "ok":
			me = v[sel]
			start_story()
	elif mode == "world":
		if D != null:
			if a == "ok" or a == "back":
				if D.i < D.t.length(): D.i = D.t.length() + 1
				elif a == "ok":
					if D.ch != null: pick(D.ch[1 - D.cs if D.sw else D.cs])
					else: D = null
			elif a == "left": D.cs = 0
			elif a == "right": D.cs = 1
		elif wm:
			if a == "ok" or a == "back" or a == "menu": wm = false
		elif a == "menu": wm = true
		elif a == "ok": interact()
	elif mode == "wait":
		if a == "ok": start_solo()
	elif mode == "over":
		if a == "ok":
			if pve: back_world()
			elif loc:
				loc = false
				Q = {}
				slot = os
				mode = "select"
				st = null
				bl = []
				rotT = 0.0
				shrT = 1.0
				exT = 0.0
				info = ""
			elif ws != null: send({"t": "rematch"})
			else: mode = "select"
	elif mode == "arena":
		if st == null or not (st.phase == "choose" and int(st.turn) == slot): return
		if msub == "":
			if a == "left": mm = (mm + 3) % 4
			elif a == "right": mm = (mm + 1) % 4
			elif a == "ok":
				if mm == 2 and int(st.items[slot]) < 1: return
				msub = ["atk", "act", "item", "mercy"][mm]
				cur = 0.0
				cdir = 1.0
				si2 = 0
				ti = 0.0
		elif a == "back": msub = ""; ti = 0.0
		elif msub == "atk":
			if a == "ok":
				var acc = max(0.0, 1.0 - abs(cur - 120.0) / 120.0)
				slash = 0.4
				msub = ""
				send({"t": "act", "k": "fight", "acc": acc, "pat": me.b, "mod": "", "wave": gen(me.b, true)})
		elif msub == "act":
			if a == "left" or a == "right": si2 = si2 ^ 1
			elif a == "up" or a == "down": si2 = si2 ^ 2
			elif a == "ok":
				if si2 < 2:
					send({"t": "act", "k": "act", "i": si2})
					ft = ("* " + op.n + " ile konuştun. Biraz yumuşadı.") if si2 == 1 else ("* " + op.n + " - " + op.l)
					ti = 0.0
					ftl = 3.0
					msub = ""
				else:
					var i = si2 - 2
					if int(st.en[slot]) >= COST[i]:
						msub = ""
						send({"t": "act", "k": "skill", "i": i, "pat": me.k[i][1], "mod": me.k[i][2], "wave": gen(me.k[i][1])})
		elif msub == "item":
			if a == "ok":
				msub = ""
				send({"t": "act", "k": "item"})
		elif msub == "mercy":
			if a == "up" or a == "down": si2 = si2 ^ 1
			elif a == "ok":
				msub = ""
				send({"t": "act", "k": "flee" if si2 == 1 else "spare"})
func tap(p):
	if p.y < 18 and p.x > 414:
		press(["menu", "back", "ok"][mini(2, int((p.x - 414) / 22))])
		return
	match mode:
		"menu":
			mi = 0 if p.y < 150 else 1
			press("ok")
		"select":
			if p.y < 30 and p.x < 180:
				logo += 1
				if logo % 5 == 0 and mem.hid == 0:
					mem.hid = 1
					save_mem()
					bn("NANİ?! Gizli karakter açıldı: VOID", 4)
					gl = 1.5
				return
			var v = vis()
			for i in v.size():
				if Rect2(8 + (i % 5) * 58, 32 + int(i / 5) * 66, 54, 60).has_point(p): sel = i
			if Rect2(310, 206, 152, 24).has_point(p): press("ok")
		"world":
			if D != null:
				if D.i < D.t.length(): D.i = D.t.length() + 1
				elif D.ch != null:
					if p.y > 228 and p.y < 258:
						D.cs = 0 if p.x < 240 else 1
						press("ok")
				else: D = null
		"wait", "over": press("ok")
		"arena":
			if Rect2(200, 10, 80, 60).has_point(p):
				egg += 1
				if egg % 7 == 0:
					var t = "Hatırlıyorum: \"" + mem.last + "\""
					bn(t, 4)
					send({"t": "say", "s": t})
					gl = 0.8
				return
			if st == null or not (st.phase == "choose" and int(st.turn) == slot): return
			if p.y > 222:
				var k = int((p.x - 24) / 112)
				if p.x >= 24 and k <= 3:
					msub = ""
					mm = k
					press("ok")
			elif msub == "act":
				si2 = (0 if p.y < 132 else 2) + (0 if p.x < 240 else 1)
				press("ok")
			elif msub == "mercy":
				si2 = 0 if p.y < 132 else 1
				press("ok")
			elif msub == "atk" or msub == "item": press("ok")
func _input(e):
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed:
			dragging = true
			drag_o = e.position
			drag_d = 0.0
			tap(e.position)
		else:
			dragging = false
			touch_v = Vector2.ZERO
			if mode == "dodge" and drag_d < 8: jump = true
	elif e is InputEventMouseMotion and dragging:
		drag_d += e.relative.length()
		if mode == "dodge":
			var f = (-1.0 if abs(rotc) > 90 else 1.0) * (-1.0 if invM else 1.0)
			ht.x += e.relative.x * f / bw
			if not blue: ht.y += e.relative.y * f / bw
		elif mode == "world" and D == null:
			var d = e.position - drag_o
			touch_v = d.normalized() * minf(d.length() / 40.0, 1.0) if d.length() > 8 else Vector2.ZERO

# ---------- güncelleme ----------
func _process(dt):
	tt += dt
	shake *= 0.9
	gl = maxf(0.0, gl - dt)
	bn_t -= dt
	bub_t -= dt
	ehp -= dt
	ai -= dt
	ftl -= dt
	slash = maxf(0.0, slash - dt)
	exv += (exT - exv) * minf(1.0, dt * 1.5)
	rotc += (rotT - rotc) * minf(1.0, dt * 4)
	shr += (shrT - shr) * minf(1.0, dt * 3)
	net_poll()
	for a in ["ok", "back", "menu", "left", "right", "up", "down"]:
		if Input.is_action_just_pressed(a): press(a)
	for f in floats:
		f.t -= dt
		f.y -= dt * 15
	floats = floats.filter(func(f): return f.t > 0)
	if D != null and D.i < D.t.length(): D.i += 28 * dt
	if ti < ft.length(): ti += 30 * dt
	if mode == "world" and D == null and not wm:
		var v = Input.get_vector("left", "right", "up", "down") + touch_v
		if v.length() > 0.05:
			var s = v.limit_length(1.0) * 78 * dt
			if not hit_wall(wp + Vector2(s.x, 0)): wp.x += s.x
			if not hit_wall(wp + Vector2(0, s.y)): wp.y += s.y
			steps += s.length()
			if steps > 420:
				steps = 0
				if randf() < 0.7: encounter()
	elif mode == "arena":
		var ch = st != null and st.phase == "choose"
		bw += ((400.0 if ch else 110.0 * shr) - bw) * minf(1.0, dt * 3)
		bh += ((80.0 if ch else 110.0 * shr) - bh) * minf(1.0, dt * 3)
		if msub == "atk":
			cur += cdir * 230 * dt
			if cur > 240:
				cur = 240
				cdir = -1.0
			if cur < 0:
				cur = 0
				cdir = 1.0
	elif mode == "dodge": upd_dodge(dt)
	var r = deg_to_rad(rotc)
	rotation = r
	position = Vector2(240, 135) - Vector2(240, 135).rotated(r) + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	queue_redraw()
func upd_dodge(dt):
	bw += (110 * shr - bw) * minf(1.0, dt * 3)
	bh = bw
	T += dt
	inv -= dt
	while qq.size() > 0 and qq[0].t <= T:
		var b = qq.pop_front()
		b.age = 0.0
		if b.has("v0"): b.v = b.v0
		if b.has("aim"):
			var A = atan2(ht.y - b.v, ht.x - b.u)
			var s = Vector2(b.vu, b.vv).length()
			b.vu = cos(A) * s
			b.vv = sin(A) * s
		bl.append(b)
	var sl = (1.0 if md else 0.8) * (1.15 if od else 1.0) * fastM
	var f = (-1.0 if abs(rotc) > 90 else 1.0) * (-1.0 if invM else 1.0)
	var m6 = 6.0 / bw
	var iv = Input.get_vector("left", "right", "up", "down")
	ht.x += iv.x * dt * 0.7 * f
	if blue:
		if ht.y >= 1 - m6 - 0.004 and (iv.y < -0.5 or jump): vy = -1.3
		jump = false
		vy += 3 * dt
		ht.y += vy * dt
	else:
		ht.y += iv.y * dt * 0.7 * f
		jump = false
	ht.x = clampf(ht.x, m6, 1 - m6)
	if ht.y > 1 - m6:
		ht.y = 1 - m6
		vy = 0.0
	if ht.y < m6:
		ht.y = m6
		vy = maxf(0.0, vy)
	mv = (ht - pp).length() > 0.0008
	pp = ht
	var keep = []
	for b in bl:
		var h = false
		if b.k == "o":
			b.age += dt
			if b.has("A"): b.v = b.v0 + b.A * sin(b.age * b.f)
			b.u += b.vu * dt * sl
			b.v += b.vv * dt * sl
			if b.c == 1 and Vector2(b.u, b.v).distance_to(ht) < 0.3:
				ht += (Vector2(b.u, b.v) - ht) * dt * 0.8
			var live = not (b.has("wn") and b.wn > b.age)
			h = live and Vector2((b.u - ht.x) * bw, (b.v - ht.y) * bw).length() < b.r * bw + 3 and (mv if b.c == 3 else ((not mv) if b.c == 4 else true))
			b.dead = b.u < -0.2 or b.u > 1.2 or b.v < -0.2 or b.v > 1.2 or (b.has("dl") and b.age > b.dl)
		else:
			var a = T - b.t
			b.act = a > b.warn and a < b.warn + b.life
			b.dead = a > b.warn + b.life
			if b.act: h = abs((ht.y if b.o == "h" else ht.x) - b.p) < b.th / 2 + 0.01
		if h and inv <= 0:
			inv = 0.9
			hits += 1
			shake = 16.0
		if not b.dead: keep.append(b)
	bl = keep
	if T >= dur:
		mode = "arena"
		bl = []
		rotT = 0.0
		shrT = 1.0
		invM = false
		blindM = false
		fastM = 1.0
		blue = false
		vy = 0.0
		if hits == 0: floats.append({"t": 1.4, "x": 240.0, "y": 60.0, "s": "PERFECT", "c": Color.html("#ff0")})
		send({"t": "done", "hits": hits})

# ---------- çizim ----------
func _draw():
	draw_rect(Rect2(-50, -50, 580, 370), Color.BLACK)
	var dk = aln()
	match mode:
		"menu", "online":
			tx("META-RPG", 240, 80, Color.html("#a5f"), 28, 1)
			tx("SOLO / BOT", 240, 135, Color.html("#ff0") if (mi == 0 and mode == "menu") else Color.WHITE, 12, 1)
			tx("ONLINE", 240, 185, Color.html("#ff0") if (mi == 1 and mode == "menu") else Color.WHITE, 12, 1)
			heart(150, 131 if mi == 0 else 181, 12, Color.html("#f22"))
			tx(info, 240, 235, Color.html("#f55"), 8, 1)
			tx("Z: onay   X: geri   C: menü   (gamepad: A / B / Y)", 240, 258, Color.html("#777"), 7, 1)
		"select": draw_select()
		"world", "wait": draw_world(dk)
		_: draw_arena()
	for f in floats: tx(f.s, f.x, f.y, f.c, 14, 1)
	if mode in ["select", "world", "arena"]:
		for i in 3:
			draw_rect(Rect2(416 + i * 22, 3, 18, 14), Color.html("#666"), false, 1.0)
			tx(["C", "X", "Z"][i], 425 + i * 22, 14, Color.html("#888"), 7, 1)
	if bn_t > 0:
		var L = wr(bn_s, 50)
		draw_rect(Rect2(0, 40, 480, 10 + L.size() * 11), Color(0, 0, 0, 0.75))
		for i in L.size(): tx(L[i], 240, 52 + i * 11, Color.html("#ff0"), 7, 1)
	if mode == "over":
		draw_rect(Rect2(0, 100, 480, 60), Color(0, 0, 0, 0.7))
		tx(info, 240, 126, Color.WHITE, 9, 1)
		tx("Z / dokun: devam" if pve else "Z / dokun: tekrar seç", 240, 146, Color.html("#999"), 7, 1)
	if gl > 0:
		for i in 8: draw_rect(Rect2(randf() * 480 - 40, randf() * 270, randf() * 300, randf() * 12), Color(randf(), 0, randf(), 0.35))
func draw_select():
	tx("KARAKTERİNİ SEÇ", 8, 20, Color.html("#a5f"), 10)
	var v = vis()
	for i in v.size():
		var cx = v[i]
		var x = 8 + (i % 5) * 58
		var y = 32 + int(i / 5) * 66
		draw_rect(Rect2(x, y, 54, 60), Color.html("#000"))
		draw_rect(Rect2(x, y, 54, 60), col(cx.a) if sel == i else Color.html("#443"), false, 2.0)
		spr(HERO if cx.t == 0 else LONG, x + 15, y + 6, 3, pal(cx))
		tx(cx.n.substr(0, 8), x + 27, y + 52, Color.WHITE if sel == i else Color.html("#999"), 6, 1)
	var c = v[sel]
	box(Rect2(300, 30, 172, 206), col(c.a))
	spr(HERO if c.t == 0 else LONG, 310, 38, 4, pal(c))
	tx(c.n, 352, 54, col(c.a), 9)
	tx(c.s, 352, 68, Color.html("#999"), 6)
	var L = wr(c.l, 22)
	for i in L.size(): tx(L[i], 310, 96 + i * 11, Color.WHITE, 7)
	tx("YETENEK", 310, 160, Color.html("#f80"), 7)
	for i in 2: tx("* " + c.k[i][0], 310, 174 + i * 13, Color.WHITE, 7)
	tx("SALDIRI: " + c.b, 310, 200, Color.html("#999"), 6)
	btn("BAŞLA", 310, 206, 152, 24, true, col(c.a))
	tx("OKLAR: gez   Z: seç   5x başlık: ???", 8, 262, Color.html("#777"), 6)
func draw_world(dk):
	for y in range(3, 17):
		for x in 30: draw_rect(Rect2(x * 16, y * 16, 16, 16), Color.html("#150c28") if (x + y) % 2 == 1 else Color.html("#1a1030"))
	draw_rect(Rect2(0, 0, 480, 48), Color.html("#2a0a1a") if dk else Color.html("#2a1a4a"))
	draw_rect(Rect2(0, 46, 480, 2), Color.html("#f24") if dk else col(me.a))
	for o in OB:
		draw_rect(o, Color.html("#2a1a4a"))
		draw_rect(o, col(me.a), false, 2.0)
	tx("*", 240, 74 + sin(tt * 3) * 2, Color.html("#ff0"), 16, 1)
	for i in 4:
		var n = NPC[i]
		var np = NPAL[i]
		spr(HERO, n.x - 8, n.y - 10, 2, {"H": col(np[0]), "S": Color.html("#fca"), "O": col(np[1]), "A": Color.WHITE, "K": Color.html("#111")}, true)
		if used[i]: draw_rect(Rect2(n.x - 8, n.y - 10, 16, 20), Color(0, 0, 0, 0.65))
		elif n.distance_to(wp) < 34: tx("!", n.x, n.y - 14 + sin(tt * 6) * 2, Color.html("#ff0"), 10, 1)
	spr(HERO if me.t == 0 else LONG, wp.x - 8, wp.y - 10, 2, pal(me))
	if wm:
		box(Rect2(20, 56, 210, 150), Color.WHITE)
		tx(me.n, 34, 76, col(me.a), 8)
		tx("LV %d   EXP %d" % [lv(), int(mem.exp)], 34, 92, Color.WHITE, 7)
		tx("ÖLDÜRDÜN %d  BAĞIŞLADIN %d" % [int(mem.kill), int(mem.spare)], 34, 108, Color.WHITE, 6)
		tx("ADİL %d  KARANLIK %d" % [int(mem.fair), int(mem.dark)], 34, 122, Color.WHITE, 6)
		var L = wr("ARAMA: Ellerin kirleniyor. Bunu hatırlıyorum." if dk else "ARAMA: Merhamet seni zayıflatmaz.", 26)
		for i in L.size(): tx(L[i], 34, 146 + i * 11, Color.html("#ff0"), 6)
	if D != null:
		box(Rect2(8, 176, 464, 90), Color.WHITE)
		tx(D.w, 18, 192, Color.html("#ff0"), 8)
		var used_n = 0
		for i in D.L.size():
			var shown = clampi(int(D.i) - used_n, 0, D.L[i].length())
			tx(D.L[i].substr(0, shown), 18, 206 + i * 12, Color.WHITE, 8)
			used_n += D.L[i].length() + 1
		if D.i >= D.t.length() and D.ch != null:
			for k in 2:
				var ch = D.ch[1 - k if D.sw else k]
				btn(("> " if D.cs == k else "") + ch.l, 246 if k == 1 else 16, 230, 218, 26, true, Color.html("#ff0") if D.cs == k else Color.html("#999"))
		elif D.i >= D.t.length(): tx("v", 460, 258, Color.WHITE, 8)
	if mode == "wait":
		draw_rect(Rect2(0, 100, 480, 50), Color(0, 0, 0, 0.6))
		tx("RAKİP BEKLENİYOR...", 240, 122, Color.html("#f0f"), 9, 1)
		tx("Z / DOKUN: BOTLA OYNA", 240, 140, Color.html("#ff0"), 7, 1)
func draw_arena():
	if me.is_empty() or op.is_empty(): return
	var s = st
	var spb = s != null and int(s.sp[1 - slot]) >= 3
	draw_circle(Vector2(240, 130), 420 * (0.2 + exv * 0.9), Color(0.75 if (md or od) else 0.43, 0, 0.16 if (md or od) else 0.75, 0.05 + exv * 0.25))
	spr(HERO if op.t == 0 else LONG, 220 + (randf() - 0.5) * 8 * float(slash > 0), 16 + sin(tt * 3) * 2, 5, pal(op), true)
	if slash > 0:
		draw_line(Vector2(215, 14), Vector2(265, 70), Color.WHITE, 3)
		draw_line(Vector2(225, 12), Vector2(272, 62), Color.WHITE, 3)
	tx("* " + op.n, 200, 40, Color.html("#ff0") if spb else Color.WHITE, 8, 2)
	if ehp > 0 and s != null:
		draw_rect(Rect2(200, 72, 80, 6), Color.html("#a00"))
		draw_rect(Rect2(200, 72, float(s.hp[1 - slot]) * 0.8, 6), Color.html("#ff0"))
	if bub_t > 0:
		draw_rect(Rect2(274, 16, 126, 22), Color.WHITE)
		tx(bub, 280, 31, Color.BLACK, 7)
	var bx = 240 - bw / 2
	var by = 132 - bh / 2
	box(Rect2(bx, by, bw, bh), Color.WHITE)
	var red = Color.html("#f22")
	if mode == "arena" and s != null:
		if msub == "":
			var L = wr(ft.substr(0, int(ti)), 44)
			for i in L.size(): tx(L[i], bx + 16, by + 26 + i * 16, Color.WHITE, 8)
		elif msub == "atk":
			draw_rect(Rect2(bx + 80, by + 30, 240, 22), Color.html("#432"))
			draw_rect(Rect2(bx + 197, by + 28, 6, 26), Color.html("#fb0"))
			draw_rect(Rect2(bx + 78 + cur, by + 24, 5, 38), Color.WHITE)
			tx("Z: VUR!", 240, by + 16, Color.WHITE, 7, 1)
		elif msub == "act":
			var names = ["* KONTROL", "* KONUŞ", "* " + me.k[0][0], "* " + me.k[1][0]]
			for i in 4:
				var x = bx + 40 + (i % 2) * 190
				var y = by + 30 + int(i / 2) * 28
				tx(names[i], x, y, Color.WHITE if (i < 2 or int(s.en[slot]) >= COST[i - 2]) else Color.html("#666"), 8)
				if si2 == i: heart(x - 12, y - 3, 9, red)
		elif msub == "item":
			tx("* Çörek x%d (+25 HP)" % int(s.items[slot]), bx + 40, by + 30, Color.WHITE, 8)
			heart(bx + 28, by + 27, 9, red)
		elif msub == "mercy":
			for i in 2:
				var y = by + 30 + i * 28
				tx(["* SPARE", "* FLEE"][i], bx + 40, y, Color.html("#ff0") if (i == 0 and spb) else Color.WHITE, 8)
				if si2 == i: heart(bx + 28, y - 3, 9, red)
	if mode == "dodge":
		for b in bl:
			if b.k == "o":
				var p = Vector2(bx + b.u * bw, by + b.v * bw)
				if not Rect2(bx, by, bw, bh).has_point(p): continue
				var c = Color.WHITE if b.c == 1 else (col(op.h) if b.c == 2 else (Color.html("#2af") if b.c == 3 else (Color.html("#f93") if b.c == 4 else col(op.a))))
				if b.has("wn") and b.wn > b.age: c.a = 0.3
				draw_circle(p, b.r * bw, c)
			else:
				var th = b.th * bw if b.act else 2.0
				var c = col(op.a) if b.act else Color(1, 1, 1, 0.3)
				if b.o == "h": draw_rect(Rect2(bx, by + b.p * bw - th / 2, bw, th), c)
				else: draw_rect(Rect2(bx + b.p * bw - th / 2, by, th, bh), c)
		if blindM:
			var hp = Vector2(bx + ht.x * bw, by + ht.y * bw)
			draw_arc(hp, 200.0, 0, TAU, 48, Color(0, 0, 0, 0.97), 280.0)
			draw_rect(Rect2(bx, by, bw, bh), Color.WHITE, false, 3.0)
		if inv <= 0 or int(inv * 20) % 2 == 1: heart(bx + ht.x * bw, by + ht.y * bw, 12, Color.html("#2af") if blue else red)
	if s != null:
		var my = s.phase == "choose" and int(s.turn) == slot and mode == "arena"
		tx(me.n + " LV " + str(lv()), 24, 214, Color.WHITE, 8)
		tx("HP", 140, 214, Color.WHITE, 7)
		draw_rect(Rect2(160, 205, 100, 10), Color.html("#a00"))
		draw_rect(Rect2(160, 205, float(s.hp[slot]), 10), Color.html("#ff0"))
		tx(str(int(s.hp[slot])), 268, 214, Color.WHITE, 8)
		tx("EN", 316, 214, Color.WHITE, 7)
		draw_rect(Rect2(338, 205, 100, 10), Color.html("#124"))
		draw_rect(Rect2(338, 205, float(s.en[slot]), 10), col(me.a))
		for i in 4:
			var sl = my and mm == i and msub == ""
			var dis = (not my) or (i == 2 and int(s.items[slot]) < 1)
			btn(["FIGHT", "ACT", "ITEM", "MERCY"][i], 38 + i * 112, 226, 94, 30, not dis, Color.html("#ff0") if sl else Color.html("#f80"))
			if sl: heart(52 + i * 112, 241, 10, red)
	if ai > 0:
		draw_rect(Rect2(-50, -50, 580, 370), Color.BLACK)
		if int(ai * 8) % 2 == 1: heart(240, 135, 16, Color.html("#f22"))
