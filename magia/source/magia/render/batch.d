module magia.render.batch;

import magia.core.vec;
import magia.render.buffer;
import magia.render.data;
import magia.render.material;
import magia.render.mesh;
import magia.render.renderer;

class SpriteArray {
    static const kNbVertices = 6;
    static const kMaxNbSprites = 5000;

    struct SpriteData {
        vec2 position;
        uint spriteId;
    };

    private {
        SpriteData[kMaxNbSprites] _aSpriteData;
        Mesh2D _mesh;
    }

    this() {
        createPositionBuffer();
        createSpriteIdBuffer();
        _mesh = new Mesh2D(new VertexBuffer(_aSpriteData, layoutBatch2D));
    }

    private void createPositionBuffer() {
        vec2[kNbVertices] aVertices = [
            vec2(0f, 0f),   // bottom left
            vec2(0f, 1f),   // bottom right
            vec2(1f, 1f),   // top right
            vec2(0f, 0f),   // bottom left
            vec2(1f, 1f),   // top right
            vec2(1f, 0f)    // bottom right
        ];

        for (uint spriteId = 0; spriteId < kMaxNbSprites; ++spriteId) {
            for (uint vertexId = 0; vertexId < kNbVertices ; ++vertexId) {
                _aSpriteData[spriteId * kNbVertices + vertexId].position = aVertices[vertexId];
            }
        }
    }

    private void createSpriteIdBuffer() {
        for (uint spriteId = 0; spriteId < kMaxNbSprites; ++spriteId) {
            for (uint vertexId = 0; vertexId < kNbVertices ; ++vertexId) {
                _aSpriteData[spriteId * kNbVertices + vertexId].spriteId = spriteId;
            }
        }
    }

    void draw(Material material) {
        _mesh.draw(spriteShader, material);
    }
}