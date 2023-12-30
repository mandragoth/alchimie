module magia.render.batch;

import magia.core.resource;
import magia.core.vec;
import magia.render.array;
import magia.render.buffer;
import magia.render.data;
import magia.render.material;
import magia.render.mesh;
import magia.render.renderer;
import magia.render.sprite;
import magia.render.texture;

class SpriteRenderer : Resource!SpriteRenderer {
    static const kMaxNbSprites = 10000;

    private {
        Mesh2D _mesh;
        Texture _texture;
        Sprite[] _sprites;
    }

    this(Texture texture) {
        // Save texture reference
        _texture = texture;

        // Create mesh for sprite render
        _mesh = new Mesh2D(rectMesh);

        // Information to forward for each rendered instance
        BufferLayout instanceLayout = new BufferLayout([
            BufferElement("a_Transform", LayoutType.ltMat4),
            BufferElement("a_Clip", LayoutType.ltFloat4),
            BufferElement("a_Flip", LayoutType.ltFloat2)
        ]);

        // Per instance vertex buffer
        VertexBuffer instanceBuffer = new VertexBuffer(kMaxNbSprites, instanceLayout);
        _mesh.addInstancedVertexBuffer(instanceBuffer, layout2D.count);
    }

    void addSprite(Sprite sprite) {
        _sprites ~= sprite;
    }

    /// Access to resource without copy
    SpriteRenderer fetch() {
        return this;
    }

    void render(Renderer2D renderer) {
        float[] data;
        foreach (Sprite sprite; _sprites) {
            // Append sprite transform model
            data ~= sprite.getTransformModel(renderer).value;

            // Append sprite clip
            data ~= sprite.clipf.value;

            // Append sprite flip
            data ~= sprite.flipf.value;
        }

        // Update per instance data
        _mesh.updateInstanceData(data, cast(uint)_sprites.length);
        _mesh.draw(spriteShader, [_texture]);
    }
}