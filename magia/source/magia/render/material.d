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
struct Material {
    /// How should we color the rendered item?
    Color color = Color.white;

    /// What is the transparency for the item?
    float alpha = 1f;

    /// How should we blend the rendered item?
    Blend blend = Blend.alpha;

    /// Do we need to flip the rendered item?
    Flip flip = Flip.none;

    /// What subset of the texture should we use?
    Clip clip = defaultClip;
}