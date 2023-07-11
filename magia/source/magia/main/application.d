module magia.main.application;

import core.thread;

import std.conv;
import std.datetime;
import std.stdio;

import magia.audio;
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
        uint _ticksPerSecond = 60u;

        // @TODO handle several scene (Ressource?)
        Scene _scene;

        // @TODO merge UIManager with scene / hierarchy
        UIManager _uiManager;

        // @TODO move ?
        InputManager _inputManager;

        AudioManager _audioManager;
    }

    /// État des opérations
    enum Status {
        error,
        exit,
        ok
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

        currentApplication = this;
    }

    /// Récupère les événements (clavier/souris/manette/etc)
    /// et les événements de la fenêtre (redimmensionnement/glisser-déposer/etc)
    /// et les redistribue sous forme d’InputEvent
    InputEvent[] pollEvents() {
        return _inputManager.pollEvents();
    }

    /// Run application
    void run() {
        //@TODO: Traiter Status.error en affichant le message d’erreur ?
        if (Status.ok != load())
            return;

        _scene = new Scene();
        _uiManager = new UIManager();
        _inputManager = new InputManager;
        _audioManager = new AudioManager;

        _tickStartFrame = Clock.currStdTime();
        double accumulator = 0.0;

        while (isRunning()) {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;

            deltaTicks = Clock.currStdTime() - _tickStartFrame;
            double deltaTime = (cast(double)(deltaTicks) / 10_000_000.0) * _ticksPerSecond;
            _currentFps = (deltaTime == .0) ? .0 : (10_000_000.0 / cast(double)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            accumulator += deltaTime;

            while (accumulator >= 1.0) {
                accumulator -= 1.0;

                _uiManager.update();
                _scene.update();
                window.update();

                if (Status.ok != tick()) {
                    return;
                    //@TODO: Traiter Status.error en affichant le message d’erreur ?
                }
            }

            // Setup 2D
            renderer.setup2DRender();

            // Draw scene (so far only 2D)
            //_scene.draw();

            // Draw UI
            _uiManager.draw();

            // Render all draw calls on window
            window.render();

            // Clear up screen
            renderer.clear();
        }
    }

    /// Render application
    /*void draw() {
        // Setup 2D
        renderer.setup2DRender();

        // Draw scene (so far only 2D)
        //_scene.draw();

        // Draw UI
        _uiManager.draw();

        // Render all draw calls on window
        window.render();

        // Clear up screen
        renderer.clear();
    }*/

    /// Render
    /*void render() {
        window.render();
    }*/

    /// Set application icon
    void setIcon() {

    }

    /// Append UI element at root level
    void appendUIRootElement(UIElement ui) {
        _uiManager.appendRoot(ui);
    }

    /// Chargement des resources
    abstract Status load();

    /// Logique de l’application
    abstract Status tick();
}
