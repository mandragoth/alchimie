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
        // Update children
        foreach (Instance2D child; element.children) {
            update();
        }
    }

    /// Draw
    void draw() {
        _renderer.setup();

        foreach (UIElement element; _roots) {
            element.draw(_renderer);
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

    void clearUI() {
        
    }
}