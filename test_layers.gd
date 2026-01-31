@tool
extends Node2D

func _process(delta: float) -> void:
	var layer1 : PolygonLayer = $Layer1.polygon_layer
	var layer2 : PolygonLayer = $Layer2.polygon_layer
	$Polygon2D.polygon = layer1.apply_to(layer2)
