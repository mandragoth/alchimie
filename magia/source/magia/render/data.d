module magia.render.data;

import magia.core;
import magia.main;
import magia.render.buffer;
import magia.render.material;
import magia.render.mesh;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

/// Static 2D sprite layout
BufferLayout layout2D;

/// Static 3D model layout
BufferLayout layout3D;

/// Animated 3D model layout
BufferLayout layout3DAnimated;

/// Rect mesh
Mesh2D rectMesh;

/// Quad mesh
Mesh3D quadMesh;

/// Skybox mesh
Mesh3D skyboxMesh;

/// Default texture
Texture defaultTexture;

/// Line shader
Shader lineShader;

/// Quad shader
Shader quadShader;

/// Sprite shader
Shader spriteShader;

/// Circle shader
Shader circleShader;

/// Model shader
Shader modelShader;

/// Animated model shader
Shader animatedShader;

/// Load all shapes at runtime
void loadShapes() {
    // Default white pixel texture to be used if one is required and none provided
    defaultTexture = new Texture(1, 1, 0xffffffff);

    layout2D = new BufferLayout([
        BufferElement("a_Position", LayoutType.ltFloat2),
        BufferElement("a_TexCoords", LayoutType.ltFloat2)
    ]);

    rectMesh = new Mesh2D(new VertexBuffer([
       -1f, -1f, 0f, 0f, // 3-----2
        1f, -1f, 1f, 0f, // |     |
        1f,  1f, 1f, 1f, // |     |
       -1f,  1f, 0f, 1f  // 0-----1
    ], layout2D), new IndexBuffer([
        0, 1, 2,
        2, 3, 0
    ]));

    // Information to forward for each rendered instance
    BufferLayout spriteInstanceLayout = new BufferLayout([
        BufferElement("a_Transform[0]", LayoutType.ltFloat4),
        BufferElement("a_Transform[1]", LayoutType.ltFloat4),
        BufferElement("a_Transform[2]", LayoutType.ltFloat4),
        BufferElement("a_Transform[3]", LayoutType.ltFloat4),
        BufferElement("a_Clip", LayoutType.ltFloat4),
        BufferElement("a_Flip", LayoutType.ltFloat2)
    ]);

    // Per instance vertex buffer
    InstanceBuffer spriteInstanceBuffer = new InstanceBuffer(spriteInstanceLayout);
    rectMesh.addInstanceBuffer(spriteInstanceBuffer, layout2D.count);

    layout3D = new BufferLayout([
        BufferElement("a_Position", LayoutType.ltFloat3),
        BufferElement("a_Normal", LayoutType.ltFloat3),
        BufferElement("a_Color", LayoutType.ltFloat3),
        BufferElement("a_TexCoords", LayoutType.ltFloat2)
    ]);

    layout3DAnimated = new BufferLayout([
        BufferElement("a_Position", LayoutType.ltFloat3),
        BufferElement("a_Normal", LayoutType.ltFloat3),
        BufferElement("a_Color", LayoutType.ltFloat3),
        BufferElement("a_TexCoords", LayoutType.ltFloat2),
        BufferElement("a_BoneIDs", LayoutType.ltInt4),
        BufferElement("a_Weights", LayoutType.ltFloat4)
    ]);

    quadMesh = new Mesh3D(new VertexBuffer([
        // Coordinates (x, z)      TexCoords     Normals    
        Vertex(vec3(-1f, 0f,  1f), vec2(0f, 0f), vec3.up), // 0-----3
        Vertex(vec3(-1f, 0f, -1f), vec2(0f, 1f), vec3.up), // |     |
        Vertex(vec3( 1f, 0f, -1f), vec2(1f, 1f), vec3.up), // |     |
        Vertex(vec3( 1f, 0f,  1f), vec2(1f, 0f), vec3.up)  // 1-----2
    ], layout3D), new IndexBuffer([
        0, 1, 2,
        0, 2, 3
    ]));

    BufferLayout layoutSkybox = new BufferLayout([
        BufferElement("a_Position", LayoutType.ltFloat3)
    ]);

    skyboxMesh = new Mesh3D(new VertexBuffer([
        // Coordinates (x, y, z)
       -1f, -1f,  1f,   //      7---------6
        1f, -1f,  1f,   //     /|        /|
        1f, -1f, -1f,   //    4---------5 |
       -1f, -1f, -1f,   //    | |       | |
       -1f,  1f,  1f,   //    | 3-------|-2
        1f,  1f,  1f,   //    |/        |/
        1f,  1f, -1f,   //    0---------1
       -1f,  1f, -1f    //
    ], layoutSkybox), new IndexBuffer([
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
    ]));
}

/// Load shaders for draw calls
void loadShaders() {
    lineShader = Magia.res.get!Shader("line");
    quadShader = Magia.res.get!Shader("quad");
    spriteShader = Magia.res.get!Shader("sprite");
    circleShader = Magia.res.get!Shader("circle");
    modelShader = Magia.res.get!Shader("model");
    animatedShader = Magia.res.get!Shader("animated");
}
