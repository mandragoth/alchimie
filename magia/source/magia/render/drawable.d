module magia.render.drawable;

import magia.render.renderer;

/// Any object that can be drawn
interface Drawable(uint dimension_) {
    /// Dimension
    static uint dimension = dimension_;

    /// Render on screen
    void draw(Renderer!(dimension_));
}

alias Drawable2D = Drawable!(2);
alias Drawable3D = Drawable!(3);