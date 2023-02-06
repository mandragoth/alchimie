module magia.main.application;

import core.thread;

import std.conv;
import std.datetime;
import std.stdio;

import magia.core;
import magia.input;
import magia.render;
import magia.ui;

import grimoire;

/// Current application being tracked
Application currentApplication;

/// Application class
class Application {
    private {
        TimeStep _timeStep;

        float _currentFps;
        long _tickStartFrame;

        // @TODO handle several scene (Ressource?)
        Scene _scene;

        // @TODO merge UIManager with scene / hierarchy
        UIManager _uiManager;

        // @TODO move ?
        InputManager _inputManager;
    }

    @property {
        /// Est-ce que magia tourne toujours ?
        bool isRunning() const {
            return !_inputManager.hasQuit();
        }

        /// Module d’entrées
        InputManager inputManager() {
            return _inputManager;
        }

        /// Module d’interface
        UIManager uiManager() {
            return _uiManager;
        }

        /// Scene actuelle
        Scene scene() {
            return _scene;
        }
    }

    /// Constructor
    this(vec2u size, string title) {
        /// Setup console output properly for windows
        version (Windows) {
            import core.sys.windows.windows : SetConsoleOutputCP;
            SetConsoleOutputCP(65_001);
        }

        // Load internal libs
        loadSDLOpenGL();
        initFont();

        // Create window
        window = new Window(size, title);
        _tickStartFrame = Clock.currStdTime();
    }

    /// scene, UI and input managers
    void postLoad() {
        _scene = new Scene();
        _uiManager = new UIManager();
        _inputManager = new InputManager;
    }

    /// Récupère les événements (clavier/souris/manette/etc)
    /// et les événements de la fenêtre (redimmensionnement/glisser-déposer/etc)
    /// et les redistribue sous forme d’InputEvent
    InputEvent[] pollEvents() {
        return _inputManager.pollEvents();
    }

    /// Run application
    void update() {
        _uiManager.update(_timeStep.delta);
        _scene.update(_timeStep);
        window.update();
    }

    /// Render application
    void draw() {
        // Clear up screen
        renderer.clear();

        // Setup 2D
        renderer.setup2DRender();

        // Draw scene (so far only 2D)
        _scene.draw();

        // Draw UI
        _uiManager.draw();

        // Render all draw calls on window
        window.render();
    }

    /// Render
    void render() {
        window.render();
    }

    /// Set application icon
    void setIcon() {
        
    }

    /// Append UI element at root level
    void appendUIRootElement(UIElement ui) {
        _uiManager.appendRoot(ui);
    }
}