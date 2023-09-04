module magia.ui.element;

import magia.core;

/// Abstract class representing an UI element
abstract class UIElement {
    public {
        UIElement[] _children;
    }

    float posX = 0f, posY = 0f;
    float sizeX = 0f, sizeY = 0f;
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

    AlignX alignX = AlignX.left;
    AlignY alignY = AlignY.top;

    /// Transitions
    float offsetX = 0f, offsetY = 0f;
    float scaleX = 1f, scaleY = 1f;
    float alpha = 1f;
    float angle = 0f;

    static final class State {
        string name;
        float offsetX = 0f, offsetY = 0f;
        float scaleX = 1f, scaleY = 1f;
        float angle = 0f;
        float alpha = 1f;
        uint ticks = 60;
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
    void draw(Transform);
}
