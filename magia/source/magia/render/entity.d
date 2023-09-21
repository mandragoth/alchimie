module magia.render.entity;

import magia.audio;
import magia.core;
import magia.render.instance;
import magia.render.material;
import magia.render.renderer;
import magia.render.texture;

/// An entity is a drawable instance
abstract class Entity(uint dimension_) : Instance!(dimension_) {
    /// Material stating how to render the item
    Material material;

    /// Render on screen
    void draw(Renderer!(dimension_)) {}
}

alias Entity2D = Entity!(2);
alias Entity3D = Entity!(3);