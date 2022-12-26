module magia.common.application;

import core.thread;

import std.conv;
import std.datetime;
import std.stdio;

import magia.common.event;
import magia.core.vec;
import magia.core.timer;
import magia.render.renderer;
import magia.ui.manager;
import magia.ui.element;
import magia.render.font;
import magia.render.scene;
import magia.render.window;
import magia.script;

import grimoire;

/// Current application being tracked
Application _currentApplication;

/// Application class
class Application {
    private {
        float _deltatime = 1f;
        float _currentFps;
        long _tickStartFrame;

        GrEngine _engine;
        GrLibrary _stdlib;
        GrLibrary _magialib;

        Scene _scene; // @TODO handle several scene (Ressource?)
        //UIManager _UIManager;
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
        initEvents();
        initFont();

        createWindow(size, title);
        renderer = new Renderer();
        _scene = new Scene();
        //initScene();

        //_UIManager = new UIManager();

        // Load grimoire libs and scripts
        _stdlib = grLoadStdLibrary();
        _magialib = loadMagiaLibrary();
        grSetOutputFunction(&print);

        if (!loadScript()) {
            destroyApplication();
            return;
        }

        _tickStartFrame = Clock.currStdTime();
    }

    /// Load a scene
    void loadScene(string sceneName) {

    }

    /// Run application
    void run() {
        while (processEvents()) {
            updateEvents(_deltatime);
            updateScripts();

            if (_scene) {
                _scene.update();
                _scene.draw();
            }

            renderWindow();
            updateFPS();
        }
    }

    /// Set application icon
    void setIcon() {
        
    }

    /// Append UI element at root level
    void appendUIRootElement(UIElement ui) {
        _UIManager.appendRoot(ui);
    }

    /// Load scripts
    private bool loadScript() {
        resetScene();
        _UIManager.removeRoots();

        GrCompiler compiler = new GrCompiler;
        compiler.addLibrary(_stdlib);
        compiler.addLibrary(_magialib);

        GrBytecode bytecode = compiler.compileFile("../assets/script/main.gr",
            GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

        if (!bytecode) {
            writeln(compiler.getError().prettify(GrLocale.fr_FR));
            _engine = null;
            return false;
        }

        _engine = new GrEngine;
        _engine.addLibrary(_stdlib);
        _engine.addLibrary(_magialib);
        _engine.load(bytecode);

        // Call onLoad if the even is available
        if (_engine.hasEvent("onLoad")) {
            _engine.callEvent("onLoad");
        }

        return true;
    }

    /// Update scripts
    private void updateScripts() {
        // Reload scripts if F5 pressed
        if (getButtonDown(KeyButton.f5)) {
            if (!loadScript()) {
                destroyApplication();
                return;
            }
        }

        // Engine alive
        if (_engine) {
            // Process tasks if there are any
            if (_engine.hasTasks) {
                _engine.process();
            }

            // Handle engine panick
            if (_engine.isPanicking) {
                writeln(_engine.prettifyProfiling());

                // @TODO handle language
                string err = "Panique: " ~ _engine.panicMessage ~ "\n";
                foreach (trace; _engine.stackTraces) {
                    err ~= "[" ~ to!string(
                        trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                        trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                }
                _engine = null;
                writeln(err);

                destroyApplication();
                return;
            }
        }
    }

    /// Update delta time, tick, FPS
    private void updateFPS() {
        long deltaTicks = Clock.currStdTime() - _tickStartFrame;

        if (deltaTicks < (10_000_000 / getNominalFPS())) {
            Thread.sleep(dur!("hnsecs")((10_000_000 / getNominalFPS()) - deltaTicks));
        }

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * getNominalFPS();
        _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();
    }
}