/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.render.graphic;

import std.conv : to;

import runa.core;
import runa.render.entity;
import runa.render.util;

abstract class Graphic : Entity {
    vec4i clip;

    double angle = 0.0;

    bool flipX, flipY;

    float anchorX = .5f, anchorY = .5f;

    float pivotX = 0f, pivotY = 0f;

    Blend blend = Blend.alpha;

    Color color = Color.white;

    float alpha = 1f;

    this() {
    }

    this(Graphic drawable) {
        clip = drawable.clip;
        angle = drawable.angle;
        flipX = drawable.flipX;
        flipY = drawable.flipY;
        anchorX = drawable.anchorX;
        anchorY = drawable.anchorY;
        pivotX = drawable.pivotX;
        pivotY = drawable.pivotY;
        blend = drawable.blend;
        color = drawable.color;
        alpha = drawable.alpha;
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    abstract void fit(float x, float y);

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    abstract void contain(float x, float y);
}
