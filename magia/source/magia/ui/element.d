module magia.ui.element;

import magia.core;
import magia.render.drawable;
import magia.render.instance;
import magia.render.renderer;

/// Abstract class representing an UI element
abstract class UIElement : Instance2D, Drawable2D, Updatable {
    /// Size
    vec2f size = vec2f.zero;

    /// Pivot point
    vec2f pivot = vec2f.one * .5f;

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
    vec2f offset = vec2f.zero;

    /// Alpha
    float alpha = 1f;

    /// State of element
    static final class State {
        /// Name of state
        string name;

        /// Initial transform
        Transform2D transform;

        /// Offset to set
        vec2f offset = vec2f.zero;

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

    /// Update
    void update() {
        // Compute transitions
        if (timer.isRunning) {
            timer.update();

            SplineFunc splineFunc = getSplineFunc(targetState.spline);
            const float t = splineFunc(timer.value01);

            offset.x = lerp(initState.offset.x, targetState.offset.x, t);
            offset.y = lerp(initState.offset.y, targetState.offset.y, t);

            transform.scale.x = lerp(initState.transform.scale.x, targetState.transform.scale.x, t);
            transform.scale.y = lerp(initState.transform.scale.y, targetState.transform.scale.y, t);

            transform.rotation.angle = lerp(initState.transform.rotation.angle, targetState.transform.rotation.angle, t);
            alpha = lerp(initState.alpha, targetState.alpha, t);
        }
    }

    /// Draw
    void draw(Renderer2D renderer) {
        // Position
        vec2f position = transform.position + offset;

        // Rotation
        rot2f rotation = transform.rotation;

        // Scale
        vec2f scale = transform.scale;

        UIElement parentElement = cast(UIElement) parent;
        
        const float parentW = parentElement ? parentElement.size.x : renderer.window.screenWidth();
        const float parentH = parentElement ? parentElement.size.y : renderer.window.screenHeight();

        final switch (alignX) with (UIElement.AlignX) {
            case left:
                break;
            case right:
                position.x = parentW - (position.x + (size.x * scale.x));
                break;
            case center:
                position.x = parentW / 2f + position.x;
                break;
        }

        final switch (alignY) with (UIElement.AlignY) {
            case bottom:
                break;
            case top:
                position.y = parentH - (position.y + (size.y * scale.y));
                break;
            case center:
                position.y = parentH / 2f + position.y;
                break;
        }

        // Adjust position
        position *= 2f;

        // Set new transform
        transform = Transform2D(position, rotation, scale);

        // Prepare draw for children
        foreach (Instance2D child; children) {
            UIElement childElement = cast(UIElement) child;
            childElement.draw(renderer);
        }
    }
}
