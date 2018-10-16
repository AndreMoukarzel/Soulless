extends Control

const FADEOUT_SPD = 1.0

# If fadeout_time = 0.0, doesn't fade out
func create(text, fadeout_time = 0.0, color = Color(255, 70, 70), size = 20):
	$Label.set_text(text)
	$Label.set_font_color(color)
	$Label.font.set_size(size)
	
	show()
	
	if fadeout_time > 0.0:
		$FadeoutTimer.set_wait_time(fadeout_time)
		$FadeoutTimer.start()
		yield($FadeoutTimer, "timeout")
		fadeout()


func fadeout():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), FADEOUT_SPD, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
