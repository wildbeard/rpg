extends Control

signal target_changed(value: Character)
signal target_selected(value: Character)

var enemies: Array[Enemy]
var targetIdx: int = -1
var target: Character = null

func hoverTarget(idx: int) -> void:
	if !enemies.size():
		return

	targetIdx = idx
	target = _getTargetable()[idx]
	var pos: Vector2 = target.global_position

	# @todo: Figure out a better way to position this
	pos.y -= 24
	global_position = pos

func _input(event: InputEvent) -> void:
	if !visible:
		return

	if event is InputEventKey && event.is_pressed():
		if event.is_action_pressed("ui_up") || event.is_action_pressed("ui_down"):
			_handleEvent(event)
		elif event.is_action_pressed("ui_accept"):
			target_selected.emit(target)

func _handleEvent(event: InputEventKey) -> void:
	var idx: int = targetIdx
	var alive := _getTargetable()

	if event.is_action("ui_up"):
		idx = max(0, idx-1)
	else:
		idx = min(alive.size()-1, idx+1)

	hoverTarget(idx)

func _getTargetable() -> Array[Enemy]:
	return enemies.filter(func(c: Enemy): return !c.isDead)
