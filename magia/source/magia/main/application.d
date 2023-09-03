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
        uint _ticksPerSecond = 60u;
        double _accumulator = 0.0;

        // @TODO handle several scene (Ressource?)
        Scene3D _scene3D;
        Scene2D _scene2D;

        // @TODO merge UIManager with scene / hierarchy
        // To be specific the UIManager ought to be a Scene2D?
        UIManager _uiManager;

        // @TODO move ?
        InputManager _inputManager;
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
        // @TODO: Traiter Status.error en affichant le message d’erreur ?
        if (Status.ok != load()) {
            return;
        }

        // Create renderer
        renderer = new Renderer();
        
        // Create rendering stacks
        _scene3D = new Scene3D();
        _scene2D = new Scene2D();
        _uiManager = new UIManager();

        // Create input handlers
        _inputManager = new InputManager;

        _tickStartFrame = Clock.currStdTime();
        while (isRunning()) {
            update();
            draw();
        }
    }

    private {
        /// Update application
        void update() {
            long deltaTicks = Clock.currStdTime() - _tickStartFrame;

            deltaTicks = Clock.currStdTime() - _tickStartFrame;
            double deltaTime = (cast(double)(deltaTicks) / 10_000_000.0) * _ticksPerSecond;
            _currentFps = (deltaTime == .0) ? .0 : (10_000_000.0 / cast(double)(deltaTicks));
            _tickStartFrame = Clock.currStdTime();

            _accumulator += deltaTime;

            while (_accumulator >= 1.0) {
                _accumulator -= 1.0;

                renderer.update();
                _uiManager.update();
                _scene3D.update();
                _scene2D.update();
                window.update();
                
                // @TODO: Traiter Status.error en affichant le message d’erreur ?
                if (Status.ok != tick()) {
                    return;
                }
            }
        }

        /// Render application
        void draw() {
            // Draw 3D scene
            renderer.setup3DRender();
            _scene3D.draw();

            // Draw 2D scene, UI
            renderer.setup2DRender();
            _scene2D.draw();
            _uiManager.draw();

            // Render all draw calls on window
            window.render();

            // Clear up screen
            renderer.clear();
        }
    }


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
