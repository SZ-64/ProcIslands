extends MeshInstance

# The shader to use for the wave mesh
export var wave_shader_mad: ShaderMaterial

# Wave properties
var time := 0.0
var wave_length := 0.25
var wave_amplitude := 1.5
var wave_frequency := 0.5
var wave_time_scale := 0.5

# Debug info
var fps := 0.0
var verts_count := 0

# Mesh collider reference
onready var mesh_collider = $StaticBody/CollisionShape


# Called when the node enters the scene tree for the first time.
func _ready():
	material_override = wave_shader_mad
#	arraymesh_update()


func arraymesh_update() -> void:
	var mesh_array = mesh.surface_get_arrays(0)
	
	var vertex_array = mesh_array[0]
	verts_count = vertex_array.size()
	
	for i in range(verts_count):
		var vert = vertex_array[i]
		vert.y = wave_function(vert) - 0.5
		vertex_array.set(i, vert)
	
	mesh_array[0] = vertex_array
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
	mesh = array_mesh
	material_override = wave_shader_mad
	
	var col_shape = ConcavePolygonShape.new()
	col_shape.set_faces(mesh.get_faces())
	mesh_collider.set_shape(col_shape)
	mesh_collider.visible = true


func _physics_process(delta: float) -> void:
	time += delta
	arraymesh_update()

func wave_function(vert: Vector3) -> float:
	var wave1 = sin(wave_length*(sqrt((vert.x*vert.x) + (vert.z*vert.z))) + time*1.1)
	var wave2 = sin(time * wave_time_scale - vert.x * wave_frequency / 2.0 + vert.y * wave_frequency / 2.0) * (wave_amplitude);
	return wave1 + wave2;

func get_fps():
	return str(Engine.get_frames_per_second())

func get_verts():
	return str(verts_count)
