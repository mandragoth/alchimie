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

        // @TODO remove
        Texture remilia;
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

        createWindow(size, title);
        _scene = new Scene();
        _uiManager = new UIManager();
        _inputManager = new InputManager;

        _tickStartFrame = Clock.currStdTime();

        remilia = new Texture("remilia.png");
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

        if (_scene) {
            _scene.update(_timeStep);
        }

        updateFPS();
    }

    /// Render application
    void render() {
        // BEING TEST
        // BELOW DATA TO BE EXTRACTED TO SCENE?

        renderer.setup2DRender();

        renderer.coordinates = defaultCoordinates;
        renderer.drawTexture(remilia, vec2.zero, remilia.size);
    
        // END TEST

        _scene.draw();
        renderWindow();
    }

    /// Set application icon
    void setIcon() {
        
    }

    /// Append UI element at root level
    void appendUIRootElement(UIElement ui) {
        _uiManager.appendRoot(ui);
    }

    /// Update delta time, tick, FPS
    private void updateFPS() {
        const long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        float deltatime = (cast(float)(deltaTicks) / 10_000_000f) * getNominalFPS();
        _timeStep = TimeStep(deltatime);
        _currentFps = (deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();
    }
}