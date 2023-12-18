module runa.render.entity;

import runa.core;
import runa.render.renderer;

abstract class Entity {
    vec2 position = vec2.zero;
    float angle = 0f;

    void update() {}
    void draw(Renderer) {}
}
