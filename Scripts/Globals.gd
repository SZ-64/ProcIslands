extends Node


# Normalize an arbitrary number between min and max
func normalizef(v: float, min_val: float, max_val: float) -> float:
	return (v - min_val) / (max_val - min_val)

# Normalize and clamp an arbitrary number between min and max
func clampf(v: float, min_val: float, max_val: float) -> float:
	return clamp(normalizef(v, min_val, max_val), min_val, max_val) 
