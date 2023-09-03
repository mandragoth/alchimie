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
        vec3 position = vec3(-1f, -1f, 0f);

        // Window ratio
        vec3 size = vec3(1f / window.screenSize().x, 1f / window.screenSize().y, 1.0f);

        Transform transform = Transform(position, size);
        foreach (UIElement element; _roots) {
            draw(transform, element);
        }
    }

    private void draw(Transform2D transform, UIElement element, UIElement parent = null) {
        // Scale
        vec3 scale = vec3(element.scaleX, element.scaleY, 1f);

        // Rotation
        quat rotation = quat.euler_rotation(0f, 0f, element.angle);

        float x = element.posX + element.offsetX;
        float y = element.posY + element.offsetY;
        
        const float parentW = parent ? parent.sizeX : window.screenWidth();
        const float parentH = parent ? parent.sizeY : window.screenHeight();

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
        vec3 position = vec3(x * 2f, y * 2f, 0f);
        transform = transform * Transform(position, rotation, scale);

        element.draw(transform);
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