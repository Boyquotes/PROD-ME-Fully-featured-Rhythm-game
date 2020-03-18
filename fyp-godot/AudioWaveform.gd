extends ColorRect

var preview
var loaded = false

var full_size = Vector2()
var viewport_rect = Rect2()
var last_scroll_val = 0
var last_scale_val = 1
var updated = false

var preview_len
const COLOR = Color(0.68, 1, 0.18, 1)
var step = 2

func _ready():
	update()
	
func set_stream(stream):
	loaded = false
	var g = AudioStreamPreviewGenerator.new()
	g.connect("preview_updated", self, "_on_preview_updated")
	preview = g.generate_preview(stream)
	preview_len = float(preview.get_length())
	
func set_scroll(val):
	if last_scroll_val != val:
		last_scroll_val = val
		viewport_rect.position = Vector2(val, 0)
		queue_update()

func set_scale_ratio(val):
	if last_scale_val != val:
		var scale_d = val / last_scale_val
		last_scale_val = val
		viewport_rect = Rect2(Vector2(round(viewport_rect.position.x * scale_d), viewport_rect.position.y), Vector2(viewport_rect.size.x, viewport_rect.size.y))
		queue_update()
		
func set_viewport_rect(rect):
	if viewport_rect.position.x != rect.position.x or viewport_rect.position.y != rect.position.y or viewport_rect.size.x != rect.size.x or viewport_rect.size.y != rect.size.y:
		viewport_rect = rect
		queue_update()
		
func set_full_size(new_full_size):
	if full_size.x != new_full_size.x or full_size.y != new_full_size.y:
		full_size = Vector2(round(new_full_size.x), round(new_full_size.y))
		queue_update()
		
func queue_update():
	updated = false
	
func _draw_wavefrom():
	var viewport_size = viewport_rect.size
	var viewport_position = viewport_rect.position
	
	for i in range(0, full_size.x, step):
		if i >= viewport_position.x and i < viewport_position.x + viewport_size.x:
			var ofs = i * preview_len / full_size.x
			var ofs_n = (i + step) * preview_len / full_size.x
			var maxi = preview.get_max(ofs, ofs_n) * 0.5 + 0.5
			var mini = preview.get_min(ofs, ofs_n) * 0.5 + 0.5
			draw_line(Vector2(i + 1, viewport_size.y * 0.05 + mini * viewport_size.y * 0.9), Vector2(i + 1, viewport_size.y * 0.05 + maxi * viewport_size.y * 0.9), COLOR, step, false)

func _on_preview_updated(_e):
	if not loaded:
		loaded = true
		queue_update()
		set_process(true)

func _draw():
	_draw_wavefrom()

func update():
	if not updated:
		updated = true
		.update()
