extends MeshInstance

export(Image) var falloff_map: Image

# The size and width of the island
export(int) var size: int = 128

# The type of island to render (for debugging)
export(Enums.PrimitiveType) var render_type: int = Enums.PrimitiveType.PRIMITIVE_TRIANGLES

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	
	# Set up the simplex noise for height mapping
	var noise = OpenSimplexNoise.new()
	noise.octaves = 2
	noise.period = 64
	noise.persistence = 0.15
	noise.lacunarity = 1.5
	noise.seed = rand.randi_range(1, 1000)
	
	# Load a falloff map to dampen the noise around the edges
#	var falloff_map = Image.new()
#	falloff_map.load("res://Art/Textures/RadialGradient_128.png")
	falloff_map.lock()
	
	# Initialize the mesh
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	var verts = PoolVector3Array()
	var colors = PoolColorArray()
	var indices = PoolIntArray()
	
	# Generate all vertex positions
	for z in range(size):
		for x in range(size):
			var n = (noise.get_noise_2d(x, z) + 1)
			var p = falloff_map.get_pixel(x, z).r
			var y = n * p * 10
			var c = Globals.normalizef(y, 0, 20)
			
			verts.append(Vector3(x, y, z))
			if c < 0.40:
				colors.append(Color(237.0 / 255.0, 187.0 / 255.0, 69.0 / 255.0))
			elif c >= 0.40 and c < 0.70:
				colors.append(Color(c / 2, c, c / 4))
			elif c >= 0.70 and c < 0.90:
				colors.append(Color(c / 2, c / 2, c / 2))
			elif c >= 0.90:
				colors.append(Color(c, c, c))
	
	# Order vertices in clockwise order for triangulation
	for row in range(size - 1):
		for col in range(size - 1):
			var index := row * size + col
			indices.append(index)
			indices.append(index + 1)
			indices.append(index + size)
			
			indices.append(index + 1)
			indices.push_back(index + size + 1)
			indices.push_back(index + size)
	
	# Apply the lists to the mesh
	mesh_data[Mesh.ARRAY_VERTEX] = verts
	mesh_data[Mesh.ARRAY_INDEX] = indices
	mesh_data[Mesh.ARRAY_COLOR] = colors
	
	# Render the mesh
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(render_type, mesh_data)
	
	# Edit the material to use vertex colors
	var material := SpatialMaterial.new()
	material.vertex_color_use_as_albedo = true
	material.flags_unshaded = true
	material_override = material
	
	# Create the collider
	create_trimesh_collision()
