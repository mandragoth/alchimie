module runa.kernel.application;


import core.thread;
import std.conv;
import std.datetime;
import std.stdio;
import std.exception : enforce;

import runa.audio;
import runa.core;
import runa.input;
import runa.render;
import runa.ui;
import runa.kernel.loader;

/// Runa class
class Runa {
    static private {
        bool _isInitialized;

        TimeStep _timeStep;

        float _currentFps;
        long _tickStartFrame;
        uint _ticksPerSecond = 60u;
        ulong _currentTick;
        double _accumulator = 0.0;
        bool _hasQuit;

        // Main window
        Window _window;

        /// Gestionnaire audio
        AudioManager _audioManager;

        // Renderer for , 3D
        Renderer _renderer;

        // @TODO handle several scene (Ressource?)
        //Scene _scene;

        // @TODO merge UIManager with scene / hierarchy
        // To be specific the UIManager ought to be a Scene?
        UIManager _uiManager;

        // @TODO move ?
        InputManager _inputManager;

        ResourceManager _resourceManager;
    }

    /// État des opérations
    enum Status {
        error,
        exit,
        ok
    }

    static @property {
        /// Est-ce que runa tourne toujours ?
        bool isRunning() {
            return !(_inputManager.hasQuit() || _hasQuit);
        }

        /// Fenetre
        Window window() {
            return _window;
        }

        /// Renderer 
        Renderer renderer() {
            return _renderer;
        }

        /// Module d’entrées
        InputManager input() {
            return _inputManager;
        }

        /// Module d’interface
        UIManager ui() {
            return _uiManager;
        }

        /// Gestionnaire de ressources
        ResourceManager res() {
            return _resourceManager;
        }

        /// Le gestionnaire audio
        AudioManager audio() {
            return _audioManager;
        }

        /// Add  entity
        void addEntity(Entity entity) {
            //_scene.addEntity(entity);
        }

        /// Ticks écoulés depuis le début
        ulong currentTick() {
            return _currentTick;
        }

        /// Nombre de ticks présents dans une seconde
        uint ticksPerSecond() {
            return _ticksPerSecond;
        }
    }

    /// Constructor
    this(vec2u size, string title) {
        enforce(!_isInitialized, "runa ne peut être instiancié q’une seule fois");
        _isInitialized = true;

        /// Setup console output properly for windows
        version (Windows) {
            import core.sys.windows.windows : SetConsoleOutputCP;

            SetConsoleOutputCP(65_001);
        }

        // Load internal libs
        loadSDL();
        initFont();

        // Initialisation du gestionnaire audio
        _audioManager = new AudioManager();

        // Create window
        _window = new Window(size, title);
        _tickStartFrame = Clock.currStdTime();

        // Create renderers and their associated coordinate system and camera
        _renderer = new Renderer(_window);

        _uiManager = new UIManager();

        // Create input handlers
        _inputManager = new InputManager(_window);

        // Création du gestionnaire des ressources
        _resourceManager = new ResourceManager();
        setupDefaultResourceLoaders(_resourceManager);
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

                // Update audio
                _audioManager.update();

                // Update rendering stacks
                //_renderer.update();

                // Update 3D,  and UI draw stacks
                //_scene.update();
                _uiManager.update();

                // Update window
                _window.update();

                // Update tick
                _currentTick++;

                // @TODO: Traiter Status.error en affichant le message d’erreur ?
                if (Status.ok != tick()) {
                    _hasQuit = true;
                    return;
                }
            }
        }

        /// Render application
        void draw() {
            // Draw 3D, then , then UI
            //_scene.draw();
            _uiManager.draw(_renderer);

            // Render all draw calls on window
            //_window.render();

            _renderer.render();

            // Clear renderers
            //_renderer.clear();
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

/*
Dans alma:

au lieu d’avoir Runa.input.isPressed()

on fait:

version(Alchimie_KernelRuna) {
    alias Kernel = Runa;
}
else version(Alchimie_KernelRuna) {
    alias Kernel = Runa;
}

Kernel.input.isPressed()
*/
