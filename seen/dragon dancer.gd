extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	


func _on_area_3d_body_entered(body):
	print(body)
	$Area3D/CSGSphere3D .visible = false
	pass # Replace with function body.


func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print(body)
	$Area3D/CSGSphere3D .visible = false
	pass # Replace with function body.


func _on_area_3d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print(area)
	$Area3D/CSGSphere3D .visible = false
	pass # Replace with function body.


func _on_area_3d_area_entered(area):
	print(area)
	$Area3D/CSGSphere3D .visible = false
	pass # Replace with function body.
