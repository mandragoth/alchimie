module magia.render.entity;

import magia.audio;
import magia.core;
import magia.render.drawable;
import magia.render.instance;
import magia.render.material;
import magia.render.renderer;
import magia.render.texture;

/// An entity is a drawable instance
abstract class Entity(uint dimension_) : Instance!(dimension_), Drawable!(dimension_) {
    Material material;
}

alias Entity2D = Entity!(2);
alias Entity3D = Entity!(3);