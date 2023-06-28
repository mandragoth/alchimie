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

alias Clip = vec4i;

/// Material structure
class Material {
    /// How should we texture the rendered item?
    Texture[] textures; // @TODO maybe only one texture per material?

    /// How should we color the rendered item?
    Color color; // @TODO bind to texture

    /// What is the transparency for the item?
    float alpha; // @TODO bind to texture

    /// How should we blend the rendered item?
    Blend blend; // @TODO bind to texture

    /// Do we need to flip the rendered item?
    Flip flip; // @TODO bind to texture

    /// What subset of the texture should we use?
    Clip clip; // @TODO bind to texture

    /// Constructor
    this(Texture texture_ = null, Color color_ = Color.white, float alpha_ = 1f, Blend blend_ = Blend.alpha,
         Flip flip_ = Flip.none, Clip clip_ = vec4i.one) {
        color = color_;
        alpha = alpha_;
        blend = blend_;
        flip = flip_;
        clip = clip_;

        if (texture_) {
            textures ~= texture_;
        }
    }
}