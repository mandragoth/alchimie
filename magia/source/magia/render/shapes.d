module magia.render.shapes;

import magia.core;
import magia.render.mesh;
import magia.render.vertex;

/// Single definition for a quad mesh
Mesh quadMesh;

/// Single definition for a cube mesh
Mesh cubeMesh;

/// Load all shapes at runtime
void loadShapes() {
    quadMesh = new Mesh([
        // Coordinates                   Normals                 Colors                  TexCoords
        Vertex(vec3(-1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3.zero, vec2(0.0f, 0.0f)), // 3-----2
        Vertex(vec3(-1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3.zero, vec2(0.0f, 1.0f)), // |     |
        Vertex(vec3( 1.0f, 0.0f, -1.0f), vec3(0.0f, 1.0f, 0.0f), vec3.zero, vec2(1.0f, 1.0f)), // |     |
        Vertex(vec3( 1.0f, 0.0f,  1.0f), vec3(0.0f, 1.0f, 0.0f), vec3.zero, vec2(1.0f, 0.0f))  // 0-----1
    ], [      
        0, 1, 2,
        0, 2, 3
    ]);

    /// Single definition for a cube mesh
    cubeMesh = new Mesh([
        // Coordinates
        Vertex(vec3(-1.0f, -1.0f,  1.0f)),   //      7---------6
        Vertex(vec3( 1.0f, -1.0f,  1.0f)),   //     /|        /|
        Vertex(vec3( 1.0f, -1.0f, -1.0f)),   //    4---------5 |
        Vertex(vec3(-1.0f, -1.0f, -1.0f)),   //    | |       | |
        Vertex(vec3(-1.0f,  1.0f,  1.0f)),   //    | 3-------|-2
        Vertex(vec3( 1.0f,  1.0f,  1.0f)),   //    |/        |/
        Vertex(vec3( 1.0f,  1.0f, -1.0f)),   //    0---------1
        Vertex(vec3(-1.0f,  1.0f, -1.0f))    //
    ], [      
        // Right
        6, 5, 1,
        1, 2, 6,
        // Left
        0, 4, 7,
        7, 3, 0,
        // Top
        4, 5, 6,
        6, 7, 4,
        // Bottom
        0, 3, 2,
        2, 1, 0,
        // Back
        0, 1, 5,
        5, 4, 0,
        // Front
        3, 7, 6,
        6, 2, 3 
    ]);
}
