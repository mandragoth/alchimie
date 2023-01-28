module magia.render.material;

import magia.core.color;
import magia.core.vec;
import magia.render.shader;
import magia.render.texture;

/// Indicate if something is mirrored.
enum Flip {
    none,
    horizontal,
    vertical,
    both
}

/// Blending algorithm
// - alpha: Paste everything with transparency (Default one)
// - none: Paste everything without transparency
// - additive: Add color value with the destination
enum Blend {
    alpha,
    none,
    additive
}

alias Clip = vec4;

/// Material structure
struct Material {
    /// How should we texture the rendered item?
    Texture[] textures;

    /// How should we color the rendered item?
    Color color;

    /// How should we blend the rendered item?
    Blend blend;

    /// Do we need to flip the rendered item?
    Flip flip;

    /// What subset of the texture should we use?
    Clip clip;

    /// Constructor
    this(Texture texture_, Color color_ = Color.white, Blend blend_ = Blend.alpha,
         Flip flip_ = Flip.none, Clip clip_ = vec4.one) {
        color = color_;
        blend = blend_;
        flip = flip_;
        clip = clip_;
        textures ~= texture_;
    }
}