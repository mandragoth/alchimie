module magia.ui.uimanager;

import std.string;
import bindbc.opengl, bindbc.sdl;
import magia.core, magia.render;
import magia.ui.element;

import std.stdio;

/// UI elements manager
class UIManager {
    private {
        UIElement[] _roots;
        Renderer2D _renderer;
    }

    /// Constructor
    this(Renderer2D renderer) {
        _renderer = renderer;
    }

    /// Update
    void update() {
        foreach (UIElement element; _roots) {
            update(element);
        }
    }

    private void update(UIElement element) {
        // Compute transitions
        if (element.timer.isRunning) {
            element.timer.update();

            SplineFunc splineFunc = getSplineFunc(element.targetState.spline);
            const float t = splineFunc(element.timer.value01);

            element.offsetX = lerp(element.initState.offsetX, element.targetState.offsetX, t);
            element.offsetY = lerp(element.initState.offsetY, element.targetState.offsetY, t);

            element.scaleX = lerp(element.initState.scaleX, element.targetState.scaleX, t);
            element.scaleY = lerp(element.initState.scaleY, element.targetState.scaleY, t);

            element.angle = lerp(element.initState.angle, element.targetState.angle, t);
            element.alpha = lerp(element.initState.alpha, element.targetState.alpha, t);
        }

        // Update children
        foreach (UIElement child; element._children) {
            update(child);
        }
    }

    /// Draw
    void draw() {
        // Top left corner
        vec2 position = vec2(-1f, -1f);

        // Window ratio
        vec2 size = vec2(1f / _renderer.window.screenSize().x, 1f / _renderer.window.screenSize().y);

        Transform2D transform = Transform2D(position, size);
        foreach (UIElement element; _roots) {
            draw(transform, element);
        }
    }

    private void draw(Transform2D transform, UIElement element, UIElement parent = null) {
        // Scale
        vec2 scale = vec2(element.scaleX, element.scaleY);

        // Rotation
        rot2 rotation = rot2(element.angle);

        float x = element.posX + element.offsetX;
        float y = element.posY + element.offsetY;
        
        const float parentW = parent ? parent.sizeX : _renderer.window.screenWidth();
        const float parentH = parent ? parent.sizeY : _renderer.window.screenHeight();

        final switch (element.alignX) with (UIElement.AlignX) {
            case left:
                break;
            case right:
                x = parentW - (x + (element.sizeX * element.scaleX));
                break;
            case center:
                x = parentW / 2f + x;
                break;
        }

        final switch (element.alignY) with (UIElement.AlignY) {
            case bottom:
                break;
            case top:
                y = parentH - (y + (element.sizeY * element.scaleY));
                break;
            case center:
                y = parentH / 2f + y;
                break;
        }

        // Position
        vec2 position = vec2(x * 2f, y * 2f);
        transform = transform * Transform2D(position, rotation, scale);

        element.draw(_renderer, transform);
        foreach (UIElement child; element._children) {
            draw(transform, child, element);
        }
    }

    /// Add an UIElement to the manager at root level
    void appendRoot(UIElement element) {
        _roots ~= element;
    }

    /// Remove all root UIElements from the manager
    void removeRoots() {
        _roots.length = 0;
    }
}