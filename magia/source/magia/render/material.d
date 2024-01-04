module magia.render.material;

import magia.core.color;
import magia.core.vec;
import magia.core.type;
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
alias Clip = vec4u;
alias defaultClip = vec4u.zero;

/// Material element
struct MaterialElement {
    /// Name of element in the material
    string name;

    /// Type of element
    LayoutType type;
}

alias MaterialElements = MaterialElement[];

/// Material structure
class Material {
    private {
        MaterialElements _elements;
    }

    this(MaterialElements elements) {
        _elements = elements;
    }
}