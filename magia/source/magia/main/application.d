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
Application application;

/// Application class
class Application {
    private {
        TimeStep _timeStep;

        float _currentFps;
        long _tickStartFrame;
        uint _ticksPerSecond = 60u;
        ulong _currentTick;
        double _accumulator = 0.0;
        bool _hasQuit;

        // Main window
        Window _window;

        /// Audio context
        AudioDevice _audioDevice;
        AudioContext3D _audioContext;

        /// Lighting manager
        LightingManager _lightingManager;

        // Renderer for 2D, 3D
        Renderer2D _renderer2D;
        Renderer3D _renderer3D;

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

        /// Module d’entrées
        InputManager inputManager() {
            return _inputManager;
        }

        /// Module d’interface
        UIManager uiManager() {
            return _uiManager;
        }

        /// Set audio context
        void audioContext(AudioContext3D audioContext) {
            _audioContext = audioContext;
        }

        /// Get audio context
        AudioContext3D audioContext() {
            return _audioContext;
        }

        /// Le périphérique audio
        AudioDevice audioDevice() {
            return _audioDevice;
        }

        /// Get ticks for each second
        uint ticksPerSecond() {
            return _ticksPerSecond;
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

        /// Add 2D entity
        void addEntity(Entity2D entity) {
            _scene2D.addEntity(entity);
        }

        /// Add 3D entity
        void addEntity(Entity3D entity) {
            _scene3D.addEntity(entity);
        }

        /// Set directional light
        void directionalLight(DirectionalLight directionalLight) {
            _lightingManager.directionalLight = directionalLight;
        }

        /// Add point light
        void addPointLight(PointLight pointLight) {
            _lightingManager.addPointLight(pointLight);
        }

        /// Add spot light
        void addSpotLight(SpotLight spotLight) {
            _lightingManager.addSpotLight(spotLight);
        }

        /// Ticks écoulés depuis le début
        ulong currentTick() const {
            return _currentTick;
        }

        /// Nombre de ticks présents dans une seconde
        uint ticksPerSecond() const {
            return _ticksPerSecond;
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

        // Initialisation du périphérique audio
        _audioDevice = new AudioDevice();

        // Create window
        _window = new Window(size, title);
        _tickStartFrame = Clock.currStdTime();

        // Lighting manager
        _lightingManager = new LightingManager();

        // Create renderers and their associated coordinate system and camera
        _renderer3D = new Renderer3D(_window, CoordinateSystem.center);
        _renderer2D = new Renderer2D(_window, CoordinateSystem.topLeft);

        // Create scenes (@TODO and associate renderers to them)
        _scene3D = new Scene3D(_renderer3D);
        _scene2D = new Scene2D(_renderer2D);
        _uiManager = new UIManager(_renderer2D);

        // Create input handlers
        _inputManager = new InputManager(_window);

        application = this;
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
                if (_audioContext) {
                    _audioContext.update();
                }

                // Update rendering stacks
                _renderer3D.update();
                _renderer2D.update();

                // Update 3D, 2D and UI draw stacks
                _scene3D.update();
                _scene2D.update();
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
            // Setup light
            _lightingManager.setup();

            // Draw 3D, then 2D, then UI
            _scene3D.draw();
            _scene2D.draw();
            _uiManager.draw();

            // Render all draw calls on window
            _window.render();

            // Clear renderers
            _renderer3D.clear();
            _renderer2D.clear();
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
