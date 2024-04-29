module magia.kernel.runtime;

import core.thread;

import std.conv;
import std.datetime;
import std.path;
import std.file;
import std.exception : enforce;

import farfadet;
import grimoire;
import magia.audio;
import magia.core;
import magia.input;
import magia.render;
import magia.shape;
import magia.ui;
import magia.kernel.loader;
import magia.kernel.logger;

private void _print(string msg) {
    log(msg);
}

/// Magia class
final class Magia {
    static private {
        bool _isInitialized;

        // Grimoire
        alias CompileFunc = GrBytecode delegate(GrLibrary[]);
        GrEngine _engine;
        GrLibrary[] _libraries;
        GrBytecode _bytecode;
        CompileFunc _compileFunc;

        // Informations
        bool _isRedist, _isRunning;
        bool _mustReload, _mustReloadResources, _mustReloadScript;

        // Ressources
        string[] _archives;
        Archive.File[] _resourceFiles, _compiledResourceFiles;

        TimeStep _timeStep;

        float _currentFps;
        long _tickStartFrame;
        uint _ticksPerSecond = 60u;
        ulong _currentTick;
        double _accumulator = 0.0;

        // Main window
        Window _window;

        /// Gestionnaire audio
        AudioMixer _audioMixer;

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
        /// L’application est en mode export ?
        bool isRedist() {
            return _isRedist;
        }

        /// Est-ce que magia tourne toujours ?
        bool isRunning() {
            return _isRunning && !_inputManager.hasQuit();
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
        AudioMixer audio() {
            return _audioMixer;
        }

        /// La machine virtuelle Grimoire
        GrEngine vm() {
            return _engine;
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

        /// Add updatable to 2D scene
        void addUpdatable(Updatable entity, Scene2D scene2D = _currentScene2D) {
            scene2D.addUpdatable(entity);
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

    /// Demande le rechargement de l’application (valide seulement en mode développement)
    static void reload(bool mustReloadResources, bool mustReloadScript) {
        if (_isRedist)
            return;
        _mustReload = true;
        _mustReloadResources = mustReloadResources;
        _mustReloadScript = mustReloadScript;
    }

    /// Quitte le moteur
    static void close() {
        _isRunning = false;
    }

    /// Init
    this(uint windowWidth, uint windowHeight, string windowTitle) {
        this(false, null, [], windowWidth, windowHeight, windowTitle);
    }

    /// Constructor
    this(bool isRedist_, CompileFunc compileFunc, GrLibrary[] libraries,
        uint windowWidth, uint windowHeight, string windowTitle) {
        enforce(!_isInitialized, "magia ne peut être instiancié q’une seule fois");
        _isInitialized = true;

        _isRedist = isRedist_;
        _compileFunc = compileFunc;
        _libraries = libraries;
        _isRunning = true;

        // Load internal libs
        loadSDLOpenGL();

        // Initialisation du gestionnaire audio
        _audioMixer = new AudioMixer();

        // Create window
        _window = new Window(vec2u(windowWidth, windowHeight), windowTitle);
        _tickStartFrame = Clock.currStdTime();

        // Lighting manager
        _lightingManager = new LightingManager();

        // Create renderers and their associated coordinate system and camera
        _renderer3D = new Renderer3D(_window, Cartesian3D.center);
        _renderer2D = new Renderer2D(_window, Cartesian2D(_window.topLeft, vec2f.bottomRight));

        // Create default scenes (@TODO parametrize)
        addCurrentScene(new Scene2D(_renderer2D));
        addCurrentScene(new Scene3D(_renderer3D));
        _uiManager = new UIManager();

        // Create input handlers
        _inputManager = new InputManager;

        // Création du gestionnaire des ressources
        _resourceManager = new ResourceManager();
        setupDefaultResourceLoaders(_resourceManager);
    }

    /// Ajoute l’archive à la liste
    void addArchive(string path) {
        _archives ~= path;
    }

    private void _loadArchives() {
        foreach (path; _archives) {
            log("[ALCHIMIE] Chargement de l’archive `" ~ path ~ "`...");
            long startTime = Clock.currStdTime();

            Archive archive = new Archive;

            if (isDir(path)) {
                enforce(exists(path), "le dossier `" ~ path ~ "` n’existe pas");
                archive.pack(path);
            } else if (extension(path) == Alchimie_Archive_Extension) {
                enforce(exists(path), "l’archive `" ~ path ~ "` n’existe pas");
                archive.load(path);
            }

            foreach (file; archive) {
                const string ext = extension(file.name);
                switch (ext) {
                case Alchimie_Resource_Extension:
                    _resourceFiles ~= file;
                    break;
                case Alchimie_Resource_Compiled_Extension:
                    _compiledResourceFiles ~= file;
                    break;
                default:
                    res.write(file.path, file.data);
                    break;
                }
            }

            double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
            log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
        }
    }

    private void _compileResources() {
        log("[ALCHIMIE] Compilation des ressources...");
        long startTime = Clock.currStdTime();

        foreach (Archive.File file; _resourceFiles) {
            OutStream stream = new OutStream;
            stream.write!string(Alchimie_Resource_Compiled_MagicWord);

            try {
                Farfadet ffd = Farfadet.fromBytes(file.data);

                stream.write!uint(cast(uint) ffd.getNodes().length);
                foreach (resNode; ffd.getNodes()) {
                    stream.write!string(resNode.name);

                    ResourceManager.Loader loader = res.getLoader(resNode.name);
                    loader.compile(dirName(file.path) ~ Archive.Separator, resNode, stream);
                }
            } catch (FarfadetSyntaxException e) {
                string msg = file.path ~ "(" ~ to!string(
                    e.tokenLine) ~ "," ~ to!string(e.tokenColumn) ~ "): ";
                e.msg = msg ~ e.msg;
                throw e;
            }

            file.data = cast(ubyte[]) stream.data;
            _compiledResourceFiles ~= file;
        }
        _resourceFiles.length = 0;

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    private void _loadResources() {
        log("[ALCHIMIE] Chargement des ressources...");
        long startTime = Clock.currStdTime();

        foreach (Archive.File file; _compiledResourceFiles) {
            InStream stream = new InStream;
            stream.data = cast(ubyte[]) file.data;
            enforce(stream.read!string() == Alchimie_Resource_Compiled_MagicWord,
                "format du fichier de ressource `" ~ file.path ~ "` invalide");

            uint nbRes = stream.read!uint();
            for (uint i; i < nbRes; ++i) {
                string resType = stream.read!string();
                ResourceManager.Loader loader = res.getLoader(resType);
                loader.load(stream);
            }
        }
        _compiledResourceFiles.length = 0;

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    private void _startVM() {
        if (!_bytecode)
            return;

        log("[ALCHIMIE] Initialisation de la machine virtuelle...");
        long startTime = Clock.currStdTime();

        _engine = new GrEngine(Alchimie_Version_ID);

        foreach (GrLibrary library; _libraries) {
            _engine.addLibrary(library);
        }

        enforce(_engine.load(_bytecode), "version du bytecode invalide");

        _engine.callEvent("app");

        _engine.setPrintOutput(&_print);

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
    }

    void _reload() {
        _mustReload = false;

        _audioMixer.clear();
        _uiManager.clearUI();
        //_theme.setDefault();

        if (_mustReloadResources) {
            _resourceManager = new ResourceManager();
            setupDefaultResourceLoaders(_resourceManager);
            _resourceFiles.length = 0;
            _compiledResourceFiles.length = 0;
            loadResources();
        }

        if (_mustReloadScript && _compileFunc) {
            _bytecode = _compileFunc(_libraries);
        }
        _startVM();
    }

    void loadResources() {
        _loadArchives();
        _compileResources();
        _loadResources();

        // Load shapes
        loadShapes();

        // Load shaders
        loadShaders();

        // À FAIRE: réinitialiser la scène
    }

    /// Récupère les événements (clavier/souris/manette/etc)
    /// et les événements de la fenêtre (redimmensionnement/glisser-déposer/etc)
    /// et les redistribue sous forme d’InputEvent
    InputEvent[] pollEvents() {
        return _inputManager.pollEvents();
    }

    /// Run application
    void run() {
        if (_compileFunc) {
            _bytecode = _compileFunc(_libraries);
        }
        _startVM();

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

            if (_mustReload) {
                _reload();
            }

            while (_accumulator >= 1.0) {
                _accumulator -= 1.0;

                InputEvent[] inputEvents = _inputManager.pollEvents();
                /*
                
                foreach (InputEvent event; inputEvents) {
                    _uiManager.dispatch(event);
                }*/

                if (_engine) {
                    if (_engine.hasTasks) {
                        _engine.process();
                    }

                    if (_engine.isPanicking) {
                        string err = "panique: " ~ _engine.panicMessage ~ "\n";
                        foreach (trace; _engine.stackTraces) {
                            err ~= "[" ~ to!string(
                                trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                                trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                        }
                        _engine = null;
                        log(err);
                        return;
                    }
                }

                // Update scenes (default order: 3D, 2D, UI)
                updateScenes();

                // Update window
                _window.update();

                // Update tick
                _currentTick++;
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

        _uiManager.draw(_renderer2D);
    }

    void callEvent(GrEvent event, GrValue[] parameters = []) {
        if (!_engine)
            return;

        _engine.callEvent(event, parameters);
    }
}
