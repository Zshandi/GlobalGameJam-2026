extends Node2D
class_name Layer

@export
var blend_operation : Geometry2D.PolyBooleanOperation

var shapes : Array[PackedVector2Array]

func _ready() -> void:
	for child in get_children():
		if child is Polygon2D or child is CollisionPolygon2D:
			shapes.push_back(child.polygon)

func apply_to_layer(other:Layer) -> void:
	match blend_operation:
		Geometry2D.OPERATION_UNION:
			return 

func combine_with_layer(other:Layer) -> void:
	var result := other.shapes
	for shape in shapes:
		var new_result : Array[PackedVector2Array] = []
		for other_shape in result:
			var combined = Geometry2D.merge_polygons(shape, other_shape)
			
	
