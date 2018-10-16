extends Node2D

const FINAL_POS = Vector2(0, -57)
const INIT_POS = Vector2(0, 50)
var spd

func _ready():
	$Marker.set_position(INIT_POS)
	set_physics_process(false)

func start(total_time):
	var dist = FINAL_POS.y - INIT_POS.y
	spd = dist/total_time
	show()
	$Timer.set_wait_time(total_time)
	$Timer.start()
	set_physics_process(true)

func _physics_process(delta):
	$Marker.set_position($Marker.get_position() + Vector2(0, spd * delta))

func _on_Timer_timeout():
	set_physics_process(false)
	$Marker/Sprite/AnimationPlayer.play("pulsing")
