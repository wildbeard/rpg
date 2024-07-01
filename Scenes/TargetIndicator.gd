extends Control

signal target_changed(value: Character)
signal target_selected(value: Character)

var enemies: Array[Character]
var targetIdx: int = -1
var target: Character = null

func hoverTarget(idx: int) -> void:
	if !self.enemies.size():
		return

	self.targetIdx = idx
	self.target = self._getTargetable()[idx]
	var pos: Vector2 = self.target.global_position

	# @todo: Figure out a better way to position this
	pos.y -= 42
	global_position = pos

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.is_action_pressed("ui_up") || event.is_action_pressed("ui_down"):
			self._handleEvent(event)
		elif event.is_action_pressed("ui_accept"):
			target_selected.emit(self.target)

func _handleEvent(event: InputEventKey) -> void:
	var idx: int = self.targetIdx
	var alive := self._getTargetable()

	if event.is_action("ui_up"):
		idx = max(0, idx-1)
	else:
		idx = min(alive.size()-1, idx+1)

	self.hoverTarget(idx)

func _getTargetable() -> Array[Character]:
	return self.enemies.filter(func(c: Character): return !c.isDead)
