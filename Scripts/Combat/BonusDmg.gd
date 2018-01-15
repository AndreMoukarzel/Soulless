extends Node

signal done

var t1
var t2
var ts
var hit = false
var super = false


func start(max_time, min_time = max_time - 0.12, super_time = max_time - 0.05):
	t1 = min_time
	t2 = max_time
	ts = super_time
	
	get_node("Timer").set_wait_time(max_time)
	get_node("Timer").start()
	set_process_input(true)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		var t = get_node("Timer").time_left

		t = t2 - t # because timer goes backwards
		if t >= t1 and t <= t2:
			hit = true
			if t >= ts:
				super = true
		emit_signal("done")
		set_process_input(false)


func _on_Timer_timeout():
	emit_signal("done")
	set_process_input(false)