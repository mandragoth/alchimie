module magia.ui.manager;

import std.string;
import bindbc.opengl, bindbc.sdl;
import magia.core, magia.render;
import magia.ui.element;
import magia.render.vao;
import magia.render.vbo;

/// UI elements manager
class UI {
    private {
        UIElement[] _roots;
    }

    /// Update
    void update(float deltaTime) {
        foreach (UIElement element; _roots) {
            update(deltaTime, element);
        }
    }

    private void update(float deltaTime, UIElement element) {
        // Compute transitions
        if (element.timer.isRunning) {
            element.timer.update(deltaTime);

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
            update(deltaTime, child);
        }
    }

    /// Draw
    void draw() {
        mat4 position = mat4.identity;
        mat4 size = mat4.identity;
        position.translate(-1f, -1f, 0.0f);
        size.scale(1f / screenSize().x, 1f / screenSize().y, 1.0f);

        mat4 transform = position * size;
        foreach (UIElement element; _roots) {
            draw(transform, element);
        }
    }

    private void draw(mat4 transform, UIElement element, UIElement parent = null) {
        mat4 local = mat4.identity;

        // Scale
        local.scale(element.scaleX, element.scaleY, 1f);

        // Rotation: translate the element back to 0,0 temporarily
        local.translate(-element.sizeX * element.scaleX * element.pivotX * 2f,
                        -element.sizeY * element.scaleY * element.pivotY * 2f,
                        0f);

        // Rotation
        if (element.angle) {
            local.rotatez(element.angle);
        }

        // Rotation: translate the element back to its pivot
        local.translate(element.sizeX * element.scaleX * element.pivotX * 2f,
                        element.sizeY * element.scaleY * element.pivotY * 2f,
                        0f);

        float x = element.posX + element.offsetX;
        float y = element.posY + element.offsetY;
        
        const float parentW = parent ? parent.sizeX : screenWidth();
        const float parentH = parent ? parent.sizeY : screenHeight();

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
        local.translate(x * 2f, y * 2f, 0f);
        transform = transform * local;

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