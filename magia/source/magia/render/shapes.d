module magia.render.shapes;

import magia.core;
import magia.render.buffer;
import magia.render.mesh;
import magia.render.vertex;

/// 2D sprite layout
BufferLayout layout2D;

/// 3D model layout
BufferLayout layout3D;

/// Rect mesh
Mesh rectMesh;

/// Quad mesh
Mesh quadMesh;

/// Cube mesh
Mesh cubeMesh;

/// Load all shapes at runtime
void loadShapes() {
    layout2D = new BufferLayout([
        BufferElement("a_Position", LayoutType.ltFloat2),
        BufferElement("a_TexCoords", LayoutType.ltFloat2)
    ]);

    rectMesh = new Mesh(new VertexBuffer([
        -1f, -1f, 0f, 0f, // 3-----2
         1f, -1f, 1f, 0f, // |     |
         1f,  1f, 1f, 1f, // |     |
        -1f,  1f, 0f, 1f  // 0-----1
    ], layout2D), [
        0, 1, 2,
        2, 3, 0
    ]);

    layout3D = new BufferLayout([
        BufferElement("a_Position", LayoutType.ltFloat3),
        BufferElement("a_Normal", LayoutType.ltFloat3),
        BufferElement("a_Color", LayoutType.ltFloat3),
        BufferElement("a_TexCoords", LayoutType.ltFloat2)
    ]);

    quadMesh = new Mesh(new VertexBuffer([
        // Coordinates (x, z)      TexCoords     Normals    
        Vertex(vec3(-1f, 0f,  1f), vec2(0f, 0f), vec3.up), // 0-----3
        Vertex(vec3(-1f, 0f, -1f), vec2(0f, 1f), vec3.up), // |     |
        Vertex(vec3( 1f, 0f, -1f), vec2(1f, 1f), vec3.up), // |     |
        Vertex(vec3( 1f, 0f,  1f), vec2(1f, 0f), vec3.up)  // 1-----2
    ], layout3D), [      
        0, 1, 2,
        0, 2, 3
    ]);

    cubeMesh = new Mesh(new VertexBuffer([
        // Coordinates (x, y, z)
        Vertex(vec3(-1f, -1f,  1f)),   //      7---------6
        Vertex(vec3( 1f, -1f,  1f)),   //     /|        /|
        Vertex(vec3( 1f, -1f, -1f)),   //    4---------5 |
        Vertex(vec3(-1f, -1f, -1f)),   //    | |       | |
        Vertex(vec3(-1f,  1f,  1f)),   //    | 3-------|-2
        Vertex(vec3( 1f,  1f,  1f)),   //    |/        |/
        Vertex(vec3( 1f,  1f, -1f)),   //    0---------1
        Vertex(vec3(-1f,  1f, -1f))    //
    ], layout3D), [      
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
