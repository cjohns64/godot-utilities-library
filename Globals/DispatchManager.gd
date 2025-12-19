extends Node


var dispatch_queue
var running_delta: PackedFloat32Array = PackedFloat32Array()
var max_dequeue:int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#class QueueNode:
	#func QueueNode(queue_time:float, )
