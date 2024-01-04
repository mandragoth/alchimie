module magia.main.application;

import core.thread;

import std.conv;
import std.datetime;
import std.stdio;
import std.exception : enforce;

import magia.audio;
import magia.core;
import magia.input;
import magia.render;
import magia.shape;
import magia.ui;
import magia.main.loader;

/// Magia class
class Magia {
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

        /// Lighting manager
        LightingManager _lightingManager;

        // Renderer for 2D, 3D
        Renderer2D _renderer2D;
        Renderer3D _renderer3D;

        // Scenes
        Scene3D[] _scenes3D;
        Scene2D[] _scenes2D;
        UIManager _uiManager;

        // Current scenes
        Scene3D _currentScene3D;
        Scene2D _currentScene2D;

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
        /// Est-ce que magia tourne toujours ?
        bool isRunning() {
            return !(_inputManager.hasQuit() || _hasQuit);
        }

        /// Fenetre
        Window window() {
            return _window;
        }

        /// Renderer 2D
        Renderer2D renderer2D() {
            return _renderer2D;
        }

        /// Renderer 3D
        Renderer3D renderer3D() {
            return _renderer3D;
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

        /// Système d’illumination
        LightingManager light() {
            return _lightingManager;
        }

        /// Le gestionnaire audio
        AudioManager audio() {
            return _audioManager;
        }

        /// Add 2D camera
        void addCamera2D(OrthographicCamera camera) {
            _window.addCamera(camera);
            _renderer2D.cameras ~= camera;
        }

        /// Add 3D camera
        void addCamera3D(PerspectiveCamera camera) {
            _window.addCamera(camera);
            _renderer3D.cameras ~= camera;
        }

        /// Default 2D scene
        Scene2D currentScene2D() {
            return _currentScene2D;
        }

        /// Default 3D scene
        Scene3D currentScene3D() {
            return _currentScene3D;
        }

        /// Add 2D scene and make it current
        void addCurrentScene(Scene2D scene) {
            _scenes2D ~= scene;
            _currentScene2D = scene;
        }

        /// Add 3D scene and make it current
        void addCurrentScene(Scene3D scene) {
            _scenes3D ~= scene;
            _currentScene3D = scene;
        }

        /// Add 2D drawable
        void addDrawable(Drawable2D entity, Scene2D scene2D = _currentScene2D) {
            scene2D.addDrawable(entity);
        }

        /// Add 3D drawable
        void addDrawable(Drawable3D entity, Scene3D scene3D = _currentScene3D) {
            scene3D.addDrawable(entity);
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
        enforce(!_isInitialized, "magia ne peut être instiancié q’une seule fois");
        _isInitialized = true;

        /// Setup console output properly for windows
        version (Windows) {
            import core.sys.windows.windows : SetConsoleOutputCP;

            SetConsoleOutputCP(65_001);
        }

        // Load internal libs
        loadSDLOpenGL();
        initFont();

        // Initialisation du gestionnaire audio
        _audioManager = new AudioManager();

        // Create window
        _window = new Window(size, title);
        _tickStartFrame = Clock.currStdTime();

        // Lighting manager
        _lightingManager = new LightingManager();

        // Create renderers and their associated coordinate system and camera
        _renderer3D = new Renderer3D(_window, Cartesian3D.center);
        _renderer2D = new Renderer2D(_window, Cartesian2D(_window.topLeft, vec2.bottomRight));

        // Create default scenes (@TODO parametrize)
        addCurrentScene(new Scene2D(_renderer2D));
        addCurrentScene(new Scene3D(_renderer3D));
        _uiManager = new UIManager(_renderer2D);

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
        // Load shapes
        loadShapes();

        // @TODO: Traiter Status.error en affichant le message d’erreur ?
        if (Status.ok != load()) {
            return;
        }

        // Load shaders
        loadShaders();

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

                // Update scenes (default order: 3D, 2D, UI)
                updateScenes();

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

        // Update scenes (default order: 3D, 2D, UI)
        private void updateScenes() {
            foreach (Scene3D scene3D; _scenes3D) {
                scene3D.update();
            }

            foreach (Scene2D scene2D; _scenes2D) {
                scene2D.update();
            }

            _uiManager.update();
        }

        /// Render application
        void draw() {
            // Setup light
            _lightingManager.setup();

            // Draw scenes
            drawScenes();

            // Render all draw calls on window
            _window.render();

            // Clear renderers
            _renderer3D.clear();
            _renderer2D.clear();
        }
    }

    // Draw scenes (default order: 3D, 2D, UI)
    private void drawScenes() {
        foreach (Scene3D scene3D; _scenes3D) {
            scene3D.draw();
        }

        foreach (Scene2D scene2D; _scenes2D) {
            scene2D.draw();
        }

        _uiManager.draw();
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
