extends Node2D

const BACKGROUND_TEXTURE := preload("res://assets/level1_skin/background2.png")
const WIRING_TEXTURE := preload("res://assets/level1_skin/sheet/wiring.png")
const WET_FLOOR_TEXTURE := preload("res://assets/level1_skin/sheet/wet_floor.png")
const CEILING_FAN_TEXTURE := preload("res://assets/level1_skin/sheet/ceiling_fan.png")
const TRAFFIC_CAR_TEXTURE := preload("res://assets/level1_skin/sheet/traffic_car.png")
const BUS_STOP_TEXTURE := preload("res://assets/level1_skin/sheet/bus_stop.png")
const SAFE_ZONE_TEXTURE := preload("res://assets/level1_skin/sheet/safe_zone.png")
const ACTIVATE_BUTTON_TEXTURE := preload("res://assets/level1_skin/sheet/activate_button.png")
const SECURITY_BATON_TEXTURE := preload("res://assets/level1_skin/sheet/security_baton.png")
const BROKEN_LIFT_TEXTURE := preload("res://assets/level1_skin/sheet/broken_lift.png")
const FRIDGE_TEXTURE := preload("res://assets/level1_skin/sheet/refrigerator.png")
const OPENING_DOOR_TEXTURE := preload("res://assets/level1_skin/sheet/opening_door.png")
const GENERIC_DOOR_TEXTURE := preload("res://assets/level1_skin/sheet/generic_door.png")
const APARTMENT_BACKDROP_TEXTURE := preload("res://assets/level1_skin/sheet/apartment_backdrop.png")
const FLOOR_WOOD_TEXTURE := preload("res://assets/level1_skin/sheet/floor_wood.png")
const FLOOR_STONE_TEXTURE := preload("res://assets/level1_skin/sheet/floor_stone.png")
const WALL_BRICK_TEXTURE := preload("res://assets/level1_skin/sheet/wall_brick.png")
const WALL_CONCRETE_TEXTURE := preload("res://assets/level1_skin/sheet/wall_concrete.png")
const BOX_TEXTURE := preload("res://assets/level1_skin/box.png")
const KEY_TEXTURE := preload("res://assets/level1_skin/key.png")
const COFFEE_TEXTURE := preload("res://assets/level1_skin/coffee.png")
const STUDENT_ID_TEXTURE := preload("res://assets/level1_skin/student_id.png")
const STUDY_NOTE_TEXTURE := preload("res://assets/level1_skin/study_note.png")
const ROOMMATE_TEXTURE := preload("res://assets/level1_skin/roommate.png")
const SECURITY_TEXTURE := preload("res://assets/level1_skin/security.png")
const PLAYER_TEXTURE := preload("res://assets/level1_skin/main_character.png")

const SKIN_SPRITE_NAME := "PixelSkinSprite"
const BACKGROUND_ALPHA := 1.0
const MAIN_BACKGROUND_TOP_LEFT := Vector2(0, -320)
const MAIN_BACKGROUND_SIZE := Vector2(5600, 2220)
const PLAYER_SKIN_Z_INDEX := 20
const PLAYER_HEIGHT_FILL_RATIO := 0.8
const OBJECT_SKIN_Z_INDEX := 8
const ARCHITECTURE_SKIN_Z_INDEX := 2
const SKIPPED_SKIN_ROOTS := {
	"RoundMechanics_TestArea": true,
}

var _tiled_texture_cache: Dictionary = {}


func _ready() -> void:
	_add_background()
	_skin_player()
	_skin_nodes(self)


func _add_background() -> void:
	if get_node_or_null("PixelBackground") != null:
		return

	var background := Sprite2D.new()
	background.name = "PixelBackground"
	background.texture = BACKGROUND_TEXTURE
	background.centered = true
	background.position = MAIN_BACKGROUND_TOP_LEFT + MAIN_BACKGROUND_SIZE * 0.5
	var texture_size := BACKGROUND_TEXTURE.get_size()
	background.scale = Vector2(
		MAIN_BACKGROUND_SIZE.x / texture_size.x,
		MAIN_BACKGROUND_SIZE.y / texture_size.y
	)
	background.z_index = -100
	background.modulate = Color(1, 1, 1, BACKGROUND_ALPHA)
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(background)
	move_child(background, 0)


func _skin_player() -> void:
	var player := get_node_or_null("Player") as Node2D
	if player == null:
		return

	_add_player_skin_sprite(player, PLAYER_TEXTURE, _get_target_bounds(player), PLAYER_SKIN_Z_INDEX)
	var blockout := player.get_node_or_null("Polygon2D") as Polygon2D
	if blockout != null:
		blockout.color.a = 0.0


func _skin_nodes(root: Node) -> void:
	for child in root.get_children():
		if SKIPPED_SKIN_ROOTS.has(String(child.name)):
			continue

		if child is Node2D:
			_skin_node(child)
		_skin_nodes(child)


func _skin_node(node: Node2D) -> void:
	var node_name := node.name.to_lower()

	if node_name.contains("functional_ceilingfanplatform") or node_name.contains("functional_lockeddoor"):
		return

	if _is_functional_area(node_name):
		return

	if _is_wood_floor_node(node_name, node):
		var wood_floor_bounds := _get_architecture_bounds(node)
		if wood_floor_bounds.has_area():
			_add_tiled_skin(node, FLOOR_WOOD_TEXTURE, wood_floor_bounds, ARCHITECTURE_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_self_polygon(node)
		return

	if _is_platform_tile_node(node_name, node):
		var platform_bounds := _get_platform_tile_bounds(node)
		if platform_bounds.has_area():
			_add_tiled_skin(node, FLOOR_STONE_TEXTURE, platform_bounds, ARCHITECTURE_SKIN_Z_INDEX + 1)
		_hide_blockout_children(node)
		_hide_self_polygon(node)
		return

	if _is_car_node(node_name):
		_add_skin_sprite_to_bounds(node, TRAFFIC_CAR_TEXTURE, _get_target_bounds(node), 1.0, OBJECT_SKIN_Z_INDEX)
		_hide_basic_visual_and_label(node)
		return

	if node_name.contains("wetfloor"):
		_add_skin_sprite_exact(node, WET_FLOOR_TEXTURE, _get_target_bounds(node), OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_self_polygon(node)
		return

	if node_name.contains("exposedwiring"):
		_add_skin_sprite_exact(node, WIRING_TEXTURE, _get_target_bounds(node), OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if _is_ceiling_fan_node(node_name):
		_skin_ceiling_fan_node(node)
		return

	if _is_bus_stop_node(node_name):
		_add_skin_sprite_to_bounds(node, BUS_STOP_TEXTURE, _get_target_bounds(node), 1.0, OBJECT_SKIN_Z_INDEX)
		_hide_basic_visual_and_label(node)
		return

	if _is_safe_island_node(node_name):
		_skin_safe_island(node)
		return

	if _is_switch_button_node(node_name):
		_add_skin_sprite_to_bounds(node, ACTIVATE_BUTTON_TEXTURE, _get_target_bounds(node), 1.0, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_visual_placeholders_recursive(node)
		return

	if _is_locked_door_node(node_name):
		_add_skin_sprite_exact(node, GENERIC_DOOR_TEXTURE, _get_target_bounds(node), OBJECT_SKIN_Z_INDEX)
		_hide_door_blockout_children(node)
		return

	if _is_opening_node(node_name):
		_add_skin_sprite_to_bounds(node, OPENING_DOOR_TEXTURE, _get_target_bounds(node), 1.0, OBJECT_SKIN_Z_INDEX)
		_hide_basic_visual_and_label(node)
		return

	if _is_fridge_node(node_name, node):
		_add_skin_sprite_exact(node, FRIDGE_TEXTURE, _get_target_bounds(node), OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if _is_broken_lift_node(node_name, node):
		_add_skin_sprite_to_bounds(node, BROKEN_LIFT_TEXTURE, _get_target_bounds(node), 1.0, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if _is_apartment_backdrop_node(node_name, node):
		_add_skin_sprite_to_bounds(node, APARTMENT_BACKDROP_TEXTURE, _get_target_bounds(node), 1.0, OBJECT_SKIN_Z_INDEX - 1)
		_hide_blockout_children(node)
		# Adjust apartment backdrop visual to sit on floor (prevent floating)
		_adjust_apartment_backdrop_to_floor(node)
		return

	if node_name.contains("coffee"):
		_add_skin_sprite_to_bounds(node, COFFEE_TEXTURE, _get_target_bounds(node), 0.85, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if node_name.contains("studentid"):
		_add_skin_sprite_to_bounds(node, STUDENT_ID_TEXTURE, _get_target_bounds(node), 0.85, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if node_name.contains("studynote") or node_name.contains("study_note") or node_name.ends_with("_sn_nearspawn"):
		_add_skin_sprite_to_bounds(node, STUDY_NOTE_TEXTURE, _get_target_bounds(node), 0.85, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_self_polygon(node)
		return

	if node_name.contains("roommatekeys"):
		_add_skin_sprite_to_bounds(node, KEY_TEXTURE, _get_target_bounds(node), 0.8, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if node_name.contains("roommate"):
		_add_skin_sprite_to_bounds(node, ROOMMATE_TEXTURE, _get_target_bounds(node), 0.9, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		return

	if _is_security_baton_node(node_name):
		_add_skin_sprite_to_bounds(node, SECURITY_BATON_TEXTURE, _get_target_bounds(node), 0.9, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_visual_placeholders_recursive(node)
		return

	if node_name.contains("securityguard"):
		_add_skin_sprite_to_bounds(node, SECURITY_TEXTURE, _get_target_bounds(node), 0.9, OBJECT_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_security_guard_placeholders(node)
		return

	if _is_box_node(node_name):
		_skin_box_node(node)
		return

	# Skin every wall with wall_brick texture.
	if _is_wall_or_ceiling_node(node_name, node):
		var wall_bounds := _get_wall_bounds(node)
		if wall_bounds.has_area():
			_add_tiled_skin(node, WALL_BRICK_TEXTURE, wall_bounds, ARCHITECTURE_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_self_polygon(node)
		return

	# Skin floor with floor_wood texture
	if _is_floor_node(node_name, node):
		var floor_bounds := _get_floor_bounds(node)
		if floor_bounds.has_area():
			_add_tiled_skin(node, FLOOR_WOOD_TEXTURE, floor_bounds, ARCHITECTURE_SKIN_Z_INDEX)
		_hide_blockout_children(node)
		_hide_self_polygon(node)
		return


func _skin_box_node(node: Node2D) -> void:
	var box_polygons: Array[Polygon2D] = []
	_collect_box_polygons(node, box_polygons)

	if not box_polygons.is_empty():
		for box_polygon in box_polygons:
			_add_skin_sprite_to_bounds(box_polygon, BOX_TEXTURE, _get_target_bounds(box_polygon), 0.95, OBJECT_SKIN_Z_INDEX)
			_hide_self_polygon(box_polygon)
		_hide_labels(node)
		return

	_add_skin_sprite_to_bounds(node, BOX_TEXTURE, _get_target_bounds(node), 0.95, OBJECT_SKIN_Z_INDEX)
	_hide_blockout_children(node)
	_hide_self_polygon(node)


func _collect_box_polygons(node: Node, box_polygons: Array[Polygon2D]) -> void:
	for child in node.get_children():
		if child is Polygon2D and child.name.to_lower().begins_with("box"):
			box_polygons.append(child)
		_collect_box_polygons(child, box_polygons)


func _skin_ceiling_fan_node(node: Node2D) -> void:
	_add_ceiling_fan_sprite(node, CEILING_FAN_TEXTURE, _get_target_bounds(node), OBJECT_SKIN_Z_INDEX)
	_hide_self_polygon(node)
	_hide_basic_visual_and_label(node)

	var functional_platform := node.get_node_or_null("Functional_CeilingFanPlatform")
	if functional_platform != null:
		_hide_basic_visual_and_label(functional_platform)


func _skin_safe_island(node: Node2D) -> void:
	var bounds := _get_target_bounds(node)
	if not bounds.has_area():
		return

	_add_skin_sprite_to_width(node, SAFE_ZONE_TEXTURE, bounds, 1.0, OBJECT_SKIN_Z_INDEX)
	_hide_self_polygon(node)
	var label := node.get_parent().get_node_or_null("SafeIslandLabel") as Label
	if label != null:
		label.visible = false


func _add_skin_sprite_to_width(node: Node2D, texture: Texture2D, bounds: Rect2, fill_ratio: float, sprite_z_index: int) -> void:
	if node.get_node_or_null(SKIN_SPRITE_NAME) != null:
		return

	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var sprite := Sprite2D.new()
	sprite.name = SKIN_SPRITE_NAME
	sprite.texture = texture
	sprite.centered = true
	sprite.position = bounds.get_center()
	var uniform_scale := maxf(bounds.size.x, 1.0) / texture_size.x * fill_ratio
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	sprite.z_as_relative = false
	sprite.z_index = sprite_z_index
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)


func _add_ceiling_fan_sprite(node: Node2D, texture: Texture2D, bounds: Rect2, sprite_z_index: int) -> void:
	if node.get_node_or_null(SKIN_SPRITE_NAME) != null:
		return

	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var target_width := clampf(bounds.size.x * 0.72, 64.0, 104.0)
	var uniform_scale := target_width / texture_size.x
	var sprite := Sprite2D.new()
	sprite.name = SKIN_SPRITE_NAME
	sprite.texture = texture
	sprite.centered = true
	sprite.position = bounds.get_center()
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	sprite.z_as_relative = false
	sprite.z_index = sprite_z_index
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)


func _add_tiled_skin(node: Node2D, texture: Texture2D, bounds: Rect2, sprite_z_index: int) -> void:
	if node.get_node_or_null(SKIN_SPRITE_NAME) != null:
		return

	var target_size := Vector2i(maxi(1, ceili(bounds.size.x)), maxi(1, ceili(bounds.size.y)))
	var tiled_texture := _get_tiled_texture(texture, target_size)
	var sprite := Sprite2D.new()
	sprite.name = SKIN_SPRITE_NAME
	sprite.texture = tiled_texture
	sprite.centered = true
	sprite.position = bounds.get_center()
	sprite.z_as_relative = false
	sprite.z_index = sprite_z_index
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)


func _get_tiled_texture(texture: Texture2D, target_size: Vector2i) -> Texture2D:
	var cache_key := "%s:%dx%d" % [texture.resource_path, target_size.x, target_size.y]
	if _tiled_texture_cache.has(cache_key):
		return _tiled_texture_cache[cache_key]

	var source := texture.get_image()
	if source == null:
		return texture

	source.convert(Image.FORMAT_RGBA8)
	var source_size := Vector2i(source.get_width(), source.get_height())
	var image := Image.create(target_size.x, target_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in range(0, target_size.y, source_size.y):
		for x in range(0, target_size.x, source_size.x):
			var copy_size := Vector2i(
				mini(source_size.x, target_size.x - x),
				mini(source_size.y, target_size.y - y)
			)
			image.blit_rect(source, Rect2i(Vector2i.ZERO, copy_size), Vector2i(x, y))

	var tiled_texture := ImageTexture.create_from_image(image)
	_tiled_texture_cache[cache_key] = tiled_texture
	return tiled_texture


func _add_skin_sprite_to_bounds(node: Node2D, texture: Texture2D, bounds: Rect2, fill_ratio: float, sprite_z_index: int) -> void:
	if node.get_node_or_null(SKIN_SPRITE_NAME) != null:
		return

	var sprite := Sprite2D.new()
	sprite.name = SKIN_SPRITE_NAME
	sprite.texture = texture
	sprite.centered = true
	sprite.position = bounds.get_center()
	sprite.scale = _scale_to_fit(texture, bounds.size, fill_ratio)
	sprite.z_as_relative = false
	sprite.z_index = sprite_z_index
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)


func _add_skin_sprite_exact(node: Node2D, texture: Texture2D, bounds: Rect2, sprite_z_index: int) -> void:
	if node.get_node_or_null(SKIN_SPRITE_NAME) != null:
		return

	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var safe_size := Vector2(maxf(bounds.size.x, 1.0), maxf(bounds.size.y, 1.0))
	var sprite := Sprite2D.new()
	sprite.name = SKIN_SPRITE_NAME
	sprite.texture = texture
	sprite.centered = true
	sprite.position = bounds.get_center()
	sprite.scale = Vector2(safe_size.x / texture_size.x, safe_size.y / texture_size.y)
	sprite.z_as_relative = false
	sprite.z_index = sprite_z_index
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)


func _add_player_skin_sprite(node: Node2D, texture: Texture2D, bounds: Rect2, sprite_z_index: int) -> void:
	if node.get_node_or_null(SKIN_SPRITE_NAME) != null:
		return

	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var safe_size := Vector2(maxf(bounds.size.x, 1.0), maxf(bounds.size.y, 1.0))
	var target_height := safe_size.y * PLAYER_HEIGHT_FILL_RATIO
	var target_width := safe_size.x * 1.35
	var uniform_scale := minf(target_width / texture_size.x, target_height / texture_size.y)
	uniform_scale = maxf(uniform_scale, 0.05)
	var sprite_size := texture_size * uniform_scale

	var sprite := Sprite2D.new()
	sprite.name = SKIN_SPRITE_NAME
	sprite.texture = texture
	sprite.centered = true
	sprite.position = Vector2(
		bounds.get_center().x,
		bounds.position.y + bounds.size.y - sprite_size.y * 0.5
	)
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	sprite.z_as_relative = false
	sprite.z_index = sprite_z_index
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)


func _scale_to_fit(texture: Texture2D, target_size: Vector2, fill_ratio: float) -> Vector2:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE

	var safe_size := Vector2(maxf(target_size.x, 1.0), maxf(target_size.y, 1.0))
	var uniform_scale := minf(safe_size.x / texture_size.x, safe_size.y / texture_size.y) * fill_ratio
	uniform_scale = maxf(uniform_scale, 0.05)
	return Vector2(uniform_scale, uniform_scale)


func _get_target_bounds(node: Node2D) -> Rect2:
	var bounds := _collect_local_bounds(node)
	if bounds.has_area():
		return bounds

	return Rect2(Vector2(-24, -24), Vector2(48, 48))


func _get_platform_tile_bounds(node: Node2D) -> Rect2:
	if node is Polygon2D:
		return _get_polygon_local_bounds(node, node as Polygon2D)

	for child in node.get_children():
		if child is Polygon2D and child.name == "Visual":
			return _get_polygon_local_bounds(node, child as Polygon2D)

	return Rect2()


func _get_architecture_bounds(node: Node2D) -> Rect2:
	if node is Polygon2D:
		return _get_polygon_local_bounds(node, node as Polygon2D)

	for child in node.get_children():
		if child is CollisionShape2D and (child as CollisionShape2D).shape is RectangleShape2D:
			var rect := (child as CollisionShape2D).shape as RectangleShape2D
			var half_size := rect.size * 0.5
			var local_pos := node.to_local(child.to_global(Vector2.ZERO))
			return Rect2(local_pos - half_size, rect.size)

		if child is Polygon2D and child.name == "Visual":
			return _get_polygon_local_bounds(node, child as Polygon2D)

	return Rect2()


func _get_polygon_local_bounds(target: Node2D, polygon_node: Polygon2D) -> Rect2:
	if polygon_node.polygon.size() == 0:
		return Rect2()

	var first_point := target.to_local(polygon_node.to_global(polygon_node.polygon[0]))
	var min_point := first_point
	var max_point := first_point
	for polygon_point in polygon_node.polygon:
		var point := target.to_local(polygon_node.to_global(polygon_point))
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)

	return Rect2(min_point, max_point - min_point)


func _collect_local_bounds(target: Node2D) -> Rect2:
	var points: Array[Vector2] = []
	_collect_bounds_points(target, target, points)

	if points.is_empty():
		return Rect2()

	var min_point := points[0]
	var max_point := points[0]
	for point in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)

	return Rect2(min_point, max_point - min_point)


func _collect_bounds_points(target: Node2D, current: Node, points: Array[Vector2]) -> void:
	if current.name == SKIN_SPRITE_NAME:
		return

	if current is Polygon2D:
		var polygon_node := current as Polygon2D
		if _should_use_polygon_bounds(polygon_node, target):
			for point in polygon_node.polygon:
				points.append(target.to_local(polygon_node.to_global(point)))

	if current is CollisionPolygon2D:
		var collision_polygon := current as CollisionPolygon2D
		for point in collision_polygon.polygon:
			points.append(target.to_local(collision_polygon.to_global(point)))

	if current is CollisionShape2D:
		_append_collision_shape_points(target, current as CollisionShape2D, points)

	for child in current.get_children():
		_collect_bounds_points(target, child, points)


func _append_collision_shape_points(target: Node2D, collision_shape: CollisionShape2D, points: Array[Vector2]) -> void:
	if collision_shape.shape is RectangleShape2D:
		var rectangle := collision_shape.shape as RectangleShape2D
		var half_size := rectangle.size * 0.5
		var corners := [
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
		]
		for corner in corners:
			points.append(target.to_local(collision_shape.to_global(corner)))


func _should_use_polygon_bounds(polygon_node: Polygon2D, target: Node2D) -> bool:
	if polygon_node == target:
		return true

	var polygon_name := polygon_node.name.to_lower()
	return polygon_name == "visual" or polygon_name.begins_with("box")


func _hide_blockout_children(node: Node) -> void:
	for child in node.get_children():
		if child.name == SKIN_SPRITE_NAME:
			continue

		if child is Polygon2D and (child.name == "Visual" or child.name.begins_with("Box")):
			child.visible = false

		if child is Label and (child.name == "Label" or child.name.ends_with("Label")):
			child.visible = false


func _hide_basic_visual_and_label(node: Node) -> void:
	for child in node.get_children():
		if child.name == SKIN_SPRITE_NAME:
			continue

		if child is Polygon2D and (child.name == "Visual" or child.name.begins_with("Box")):
			child.visible = false

		if child is Label and child.name == "Label":
			child.visible = false


func _hide_door_blockout_children(node: Node) -> void:
	_hide_basic_visual_and_label(node)
	var functional_door := node.get_node_or_null("Functional_LockedDoor")
	if functional_door != null:
		for child in functional_door.get_children():
			if child is Polygon2D and child.name == "Visual":
				child.visible = false
			if child is Label and child.name == "StatusLabel":
				child.visible = false


func _hide_labels(node: Node) -> void:
	for child in node.get_children():
		if child is Label and (child.name == "Label" or child.name.ends_with("Label")):
			child.visible = false


func _hide_security_guard_placeholders(node: Node) -> void:
	for child in node.get_children():
		if child.name == SKIN_SPRITE_NAME:
			continue

		if child is Polygon2D and child.name == "Visual":
			child.visible = false

		_hide_security_guard_placeholders(child)


func _hide_visual_placeholders_recursive(node: Node) -> void:
	for child in node.get_children():
		if child.name == SKIN_SPRITE_NAME:
			continue

		if child is Polygon2D and child.name == "Visual":
			child.visible = false

		if child is Label and (child.name == "Label" or child.name.ends_with("Label")):
			child.visible = false

		_hide_visual_placeholders_recursive(child)


func _is_wall_or_ceiling_node(node_name: String, node: Node2D) -> bool:
	# Safety checks to exclude non-architecture nodes
	if _should_skip_node(node_name, node):
		return false

	if not node_name.contains("wall"):
		return _is_opening_wall_piece(node_name, node)

	return node is StaticBody2D or node is Polygon2D


func _is_opening_wall_piece(node_name: String, node: Node2D) -> bool:
	if not node is Polygon2D:
		return false

	if node_name != "solidheader":
		return false

	var parent := node.get_parent()
	if parent == null:
		return false

	return String(parent.name).to_lower().contains("opening")


func _is_floor_node(node_name: String, node: Node2D) -> bool:
	# Safety checks
	if _should_skip_node(node_name, node):
		return false
	
	# Check if it's a StaticBody2D
	if not node is StaticBody2D:
		return false
	
	# Whitelist floor names (but exclude platform and service)
	if node_name.contains("platform"):
		return false
	
	return node_name.contains("floor")


func _is_wood_floor_node(node_name: String, node: Node2D) -> bool:
	if _should_skip_node(node_name, node):
		return false

	if node is Polygon2D and node_name.ends_with("_mainpath"):
		return true

	if node is StaticBody2D and node_name.begins_with("floor_"):
		return true

	if (node is StaticBody2D or node is Polygon2D) and node_name.contains("boundary"):
		return true

	return false


func _should_skip_node(node_name: String, node: Node2D) -> bool:
	# Never skin inside test area
	var current := node.get_parent()
	while current != null:
		if String(current.name).to_lower() == "roundmechanics_testarea":
			return true
		current = current.get_parent()
	
	# Skip functional areas
	if node_name.begins_with("functional_"):
		return true
	
	# Skip collectibles, hazards, interactive objects
	if (node_name.contains("collectible") or node_name.contains("hazard") or 
		node_name.contains("pickup") or node_name.contains("mechanic") or
		node_name.contains("roommate") or node_name.contains("securityguard") or
		node_name.contains("traffic") or node_name.contains("busstop") or
		node_name.contains("idbarrier")):
		return true
	
	return false


func _get_wall_bounds(node: Node2D) -> Rect2:
	if node is Polygon2D:
		return _get_polygon_local_bounds(node, node as Polygon2D)

	# Get bounds from collision shape or visual polygon
	if node is StaticBody2D:
		for child in node.get_children():
			if child is CollisionShape2D and (child as CollisionShape2D).shape is RectangleShape2D:
				var rect := (child as CollisionShape2D).shape as RectangleShape2D
				var half_size := rect.size * 0.5
				var local_pos := node.to_local(child.to_global(Vector2.ZERO))
				return Rect2(local_pos - half_size, rect.size)
			
			if child is Polygon2D and child.name == "Visual":
				return _get_polygon_local_bounds(node, child as Polygon2D)

			if child is CollisionPolygon2D:
				return _get_collision_polygon_local_bounds(node, child as CollisionPolygon2D)
	
	return Rect2()


func _get_collision_polygon_local_bounds(target: Node2D, collision_polygon: CollisionPolygon2D) -> Rect2:
	if collision_polygon.polygon.size() == 0:
		return Rect2()

	var first_point := target.to_local(collision_polygon.to_global(collision_polygon.polygon[0]))
	var min_point := first_point
	var max_point := first_point
	for polygon_point in collision_polygon.polygon:
		var point := target.to_local(collision_polygon.to_global(polygon_point))
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)

	return Rect2(min_point, max_point - min_point)


func _get_floor_bounds(node: Node2D) -> Rect2:
	# Get bounds from collision shape or visual polygon
	if node is StaticBody2D:
		for child in node.get_children():
			if child is CollisionShape2D and (child as CollisionShape2D).shape is RectangleShape2D:
				var rect := (child as CollisionShape2D).shape as RectangleShape2D
				var half_size := rect.size * 0.5
				var local_pos := node.to_local(child.to_global(Vector2.ZERO))
				return Rect2(local_pos - half_size, rect.size)
			
			if child is Polygon2D and child.name == "Visual":
				return _get_polygon_local_bounds(node, child as Polygon2D)
	
	return Rect2()


func _adjust_apartment_backdrop_to_floor(node: Node2D) -> void:
	# Find the PixelSkinSprite added by _add_skin_sprite_to_bounds
	var skin_sprite := node.get_node_or_null(SKIN_SPRITE_NAME) as Sprite2D
	if skin_sprite == null:
		return
	
	# Get the bounds of the apartment backdrop
	var backdrop_bounds := _get_target_bounds(node)
	if not backdrop_bounds.has_area():
		return
	
	# Adjust sprite position to sit on bottom of bounds
	var sprite_size := skin_sprite.texture.get_size() * skin_sprite.scale
	var target_y := backdrop_bounds.position.y + backdrop_bounds.size.y - sprite_size.y * 0.5
	skin_sprite.position.y = target_y


func _hide_self_polygon(node: Node2D) -> void:
	if node is Polygon2D:
		(node as Polygon2D).color.a = 0.0


func _is_functional_area(node_name: String) -> bool:
	return node_name.begins_with("functional_") or node_name == "pickuparea" or node_name == "mechanicarea"


func _is_box_node(node_name: String) -> bool:
	return node_name.contains("boxes") or node_name.begins_with("box")


func _is_platform_tile_node(node_name: String, node: Node2D) -> bool:
	if node_name.contains("functional"):
		return false

	if node is Polygon2D and (
		node_name.begins_with("platform")
		or node_name.contains("_platform")
	):
		return true

	if node is Node2D and node.get_node_or_null("Visual") is Polygon2D:
		return node_name.begins_with("platform") or node_name.contains("_platform")

	return false


func _is_car_node(node_name: String) -> bool:
	return node_name.contains("carhazard") or node_name.contains("movingcar")


func _is_ceiling_fan_node(node_name: String) -> bool:
	return node_name.contains("ceilingfan") and not node_name.contains("functional")


func _is_bus_stop_node(node_name: String) -> bool:
	return node_name.contains("busstop")


func _is_safe_island_node(node_name: String) -> bool:
	return node_name == "safeislandvisual"


func _is_switch_button_node(node_name: String) -> bool:
	return node_name.contains("switchbutton")


func _is_security_baton_node(node_name: String) -> bool:
	return node_name.contains("securitybaton")


func _is_locked_door_node(node_name: String) -> bool:
	return node_name.contains("lockeddoor")


func _is_opening_node(node_name: String) -> bool:
	return node_name.contains("opening") and not node_name.begins_with("route_")


func _is_fridge_node(node_name: String, node: Node) -> bool:
	return node_name.contains("fridge") or _node_has_label_text(node, "Fridge")


func _is_broken_lift_node(node_name: String, node: Node) -> bool:
	return node_name.contains("brokenlift") or _node_has_label_text(node, "Broken Lift")


func _is_apartment_backdrop_node(node_name: String, node: Node) -> bool:
	return node_name.contains("apartment") or _node_has_label_text(node, "Apartment")


func _node_has_label_text(node: Node, text_fragment: String) -> bool:
	for child in node.get_children():
		if child is Label and (child as Label).text.contains(text_fragment):
			return true
	return false
