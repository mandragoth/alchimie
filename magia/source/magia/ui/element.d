module magia.ui.element;

import magia.core;
import magia.render.renderer;

/// Abstract class representing an UI element
/// @TODO remake with Element2D inheritance for position, scale and angle
abstract class UIElement {
    public {
        /// Children elements
        UIElement[] _children;
    }

    /// Position
    float posX = 0f, posY = 0f;

    /// Scale
    float sizeX = 0f, sizeY = 0f;

    /// Pivot point
    float pivotX = .5f, pivotY = .5f;

    /// X alignment
    enum AlignX {
        left,
        center,
        right
    }

    /// Y alignment
    enum AlignY {
        top,
        center,
        bottom
    }

    /// Alignment on the X axis
    AlignX alignX = AlignX.left;

    /// Alignment on the Y axis
    AlignY alignY = AlignY.top;

    /// Offset
    float offsetX = 0f, offsetY = 0f;

    /// Scale
    float scaleX = 1f, scaleY = 1f;

    /// Alpha
    float alpha = 1f;

    /// Angle
    float angle = 0f;

    /// State of element
    static final class State {
        /// Name of state
        string name;

        /// Offset to set
        float offsetX = 0f, offsetY = 0f;

        /// Scale to set
        float scaleX = 1f, scaleY = 1f;

        /// Angle to set
        float angle = 0f;

        /// Alpha to set
        float alpha = 1f;

        /// Ticks for transition
        uint ticks = 60;

        /// Spline used for transition interpolation
        Spline spline = Spline.linear;
    }

    /// States indexed by name
    State[string] states;

    /// Current state
    string currentStateName;

    /// Initial and target states
    State initState, targetState;

    /// Internal timer
    Timer timer;

    /// Propriétés
    bool isHovered, isClicked;

    /// Draw call to implement
    void draw(Renderer2D, Transform2D);
}
