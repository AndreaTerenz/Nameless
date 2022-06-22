class_name AudioQueuePlayer
extends AudioStreamPlayer

signal sample_added(s)
signal started_next(s)
signal queue_emptied

var queue := []

func _ready() -> void:
	self.connect("finished", self, "_on_done")

func enqueue(sample: AudioStream):
	queue.append(sample)
	emit_signal("sample_added", sample)
	
	if len(queue) == 1:
		next()
	
func _on_done():
	next()
	
func next():
	if len(queue) > 0:
		if not playing:
			stream = queue.pop_front()
			if stream.get("loop"):
				stream.loop = false
			emit_signal("started_next", stream)
			play()
	else:
		emit_signal("queue_emptied")
