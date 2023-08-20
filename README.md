# Procedural Islands

A simple Godot demo that randomly generates small islands with different landscapes.

## Explanation

This is a prototype of a procedural generation mechanic written in Godot. The prototype contains a main Game.tscn that drops the player in an open space with a few islands that are generated dynamically each time the game starts. The player will always start on one island and can move around with W, A, S, and D keys to explore the other islands.

Water is also implemented, but is a collider and so the player will simply walk on top of it. No swimming or similar mechanics are on display here. The water shader is also a procedural texture inspired by [The Legend of Zelda: Wind Waker](https://en.wikipedia.org/wiki/The_Legend_of_Zelda:_The_Wind_Waker). The shader used is based on this [Wind Waker styled shader](https://www.shadertoy.com/view/3tKBDz) on shader toy, with some of my own small modifications.

## Technical

The island generation process works as follows:
 - Use Godot's OpenSimplexNoise to generate a height map
 - Loop over a grid of n x n vertices
   - Set each vertex's height from the noise
   - Scale each vertex by a circular falloff map
   - Color each vertex based on it's height
 - Create a collider and assign it to the mesh
 - Render the final island at a predetermined location

Starting with the noise heightmap gives each island it's own unique set of heights to mold the mesh around. This is a helpful base, but using just the simplex noise alone could lead to some unnatural formations. For example, if the height values are high right at the border of the original vertex grid, the generator could output an island with half of a mountain on the edge of the island, which looked unnatural.

To fix this, a circular falloff map is applied to the height values. This is a simple texture file containing a circular gradient that has the value 0 at the edges and the value 1 in the middle. This corrects the above issue with mountains on the edges, as the heights of the vertices on the edges will be reduced to "sea level" while the heights closer to the middle of the noise texture will remain close to or the same as the value in the noise texture.

Each vertex is then assigned a color based on it's height. I am using a four-tiered color ramp with hard cutoffs at predetermined heights. So, vertices close to the water line appear as a sandy tan color, while higher points on the island will be painted a grassy green or rocky grey. There is no blending between layers currently but might be an interesting improvement to work on later.

Finally, the mesh and material are rendered and a collider is generated so the player can walk on top of the islands.

## Playable Demo

(A link to itch.io will be provided soon!)
