module magia.render.pool;

import magia.render.drawable;
import magia.render.material;
import magia.render.mesh;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;

/// Drawable pool
abstract class DrawablePool(uint dimension_, Type, Data) : Drawable!dimension_ {
    protected {
        Mesh!(dimension_) _mesh;
        Shader _shader;
        Texture[] _textures;
        Type[] _drawables;
        Data[] _instanceData;
    }

    /// Add a sprite to the pool
    void addDrawable(Type drawable) {
        _drawables ~= drawable;
    }

    /// Add sprite data to the pool
    void addInstanceData(Data data) {
        _instanceData ~= data;
    }

    /// Draw all sprites held by the pool
    void draw(Renderer!dimension_ renderer) {
        foreach(Type drawable; _drawables) {
            drawable.draw(renderer);
        }

        if (_instanceData.length) {
            renderer.draw(_mesh, _shader, _textures, _instanceData);
        }

        _instanceData.length = 0;
    }
}