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

// @TODO should be vec4u
alias Clip = vec4i;
alias defaultClip = vec4i.zero;

/// Material structure
// @TODO refactorize similarly to BufferElement
class Material {
    /// How should we texture the rendered item?
    Texture[] textures;

    /// How should we color the rendered item?
    Color color;

    /// What is the transparency for the item?
    float alpha;

    /// How should we blend the rendered item?
    Blend blend;

    /// Do we need to flip the rendered item?
    Flip flip;

    /// What subset of the texture should we use?
    Clip clip;

    /// Constructor
    this(Texture texture_ = null, Color color_ = Color.white, float alpha_ = 1f, Blend blend_ = Blend.alpha,
         Flip flip_ = Flip.none, Clip clip_ = defaultClip) {
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