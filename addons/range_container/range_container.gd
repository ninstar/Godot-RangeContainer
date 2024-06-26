@tool
@icon("range_container.svg")

class_name RangeContainer extends ScrollContainer


## A [ScrollContainer] that can be controlled by external [Range] nodes.


## [Range] node bound to the [HScrollBar] of the container.
@export var shared_h: Array[Range]: get = get_shared_h, set = set_shared_h 

## [Range] node bound to the [VScrollBar] of the container.
@export var shared_v: Array[Range]: get = get_shared_v, set = set_shared_v


#region Signals

func __on_h_scroll_bar_changed() -> void:
	var scroll_bar: HScrollBar = get_h_scroll_bar()
	for node: Node in shared_h:
		if not is_instance_valid(node) or node is ScrollBar or node is SpinBox:
			continue
		if node is Range:
			var range := node as Range
			range.min_value = scroll_bar.min_value
			range.max_value = scroll_bar.max_value-scroll_bar.page
			range.page = 0.0
			range.step = scroll_bar.step


func __on_v_scroll_bar_changed() -> void:
	var scroll_bar: VScrollBar = get_v_scroll_bar()
	for node: Node in shared_v:
		if not is_instance_valid(node) or node is ScrollBar or node is SpinBox:
			continue
		if node is Range:
			var range := node as Range
			range.min_value = scroll_bar.min_value
			range.max_value = scroll_bar.max_value-scroll_bar.page
			range.page = 0.0
			range.step = scroll_bar.step


func __on_h_scroll_bar_value_changed(value: float) -> void:
	for node: Node in shared_h:
		if not is_instance_valid(node) or node is ScrollBar or node is SpinBox:
			continue
		if node is Range:
			(node as Range).set_value_no_signal(value)


func __on_v_scroll_bar_value_changed(value: float) -> void:
	for node: Node in shared_v:
		if not is_instance_valid(node) or node is ScrollBar or node is SpinBox:
			continue
		if node is Range:
			(node as Range).set_value_no_signal(value)


func __on_slider_value_changed_h(value: float) -> void:
	scroll_horizontal = value
	__on_h_scroll_bar_value_changed(value)


func __on_slider_value_changed_v(value: float) -> void:
	scroll_vertical = value
	__on_v_scroll_bar_value_changed(value)

#endregion
#region Vritual methods

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		var h_scroll_bar: HScrollBar = get_h_scroll_bar()
		var v_scroll_bar: VScrollBar = get_v_scroll_bar()
		
		h_scroll_bar.changed.connect(__on_h_scroll_bar_changed)
		v_scroll_bar.changed.connect(__on_v_scroll_bar_changed)
		h_scroll_bar.value_changed.connect(__on_h_scroll_bar_value_changed)
		v_scroll_bar.value_changed.connect(__on_v_scroll_bar_value_changed)

#endregion
#region Getters & Setters

# Getters

func get_shared_h() -> Array[Range]:
	return shared_h


func get_shared_v() -> Array[Range]:
	return shared_v

# Setters

func set_shared_h(nodes: Array[Range]) -> void:
	if is_node_ready():
		for node: Node in shared_h:
			if not is_instance_valid(node):
				continue
			if node is Slider:
				var slider := node as Slider
				if slider.value_changed.is_connected(__on_slider_value_changed_h):
					slider.value_changed.disconnect(__on_slider_value_changed_h)
	
	shared_h = nodes
	
	if not is_node_ready():
		await ready
	
	var scroll_bar: HScrollBar = get_h_scroll_bar()
	scroll_bar.unshare()
	for node: Node in nodes:
		if not is_instance_valid(node):
			continue
		if node is Slider:
			(node as Slider).value_changed.connect(__on_slider_value_changed_h)
		if node is ScrollBar or node is SpinBox:
			scroll_bar.share(node)


func set_shared_v(nodes: Array[Range]) -> void:
	if is_node_ready():
		for node: Node in shared_v:
			if not is_instance_valid(node):
				continue
			if node is Slider:
				var slider := node as Slider
				if slider.value_changed.is_connected(__on_slider_value_changed_v):
					slider.value_changed.disconnect(__on_slider_value_changed_v)
	
	shared_v = nodes
	
	if not is_node_ready():
		await ready
	
	var scroll_bar: VScrollBar = get_v_scroll_bar()
	scroll_bar.unshare()
	for node: Node in nodes:
		if not is_instance_valid(node):
			continue
		if node is Slider:
			(node as Slider).value_changed.connect(__on_slider_value_changed_v)
		if node is ScrollBar or node is SpinBox:
			scroll_bar.share(node)

#endregion
