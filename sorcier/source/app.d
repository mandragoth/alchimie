import std.stdio;

import std.conv : to;
import std.datetime, core.thread;

import magia, grimoire;

import sorcier.script;

private {
    float _deltatime = 1f;
    float _currentFps;
    long _tickStartFrame;

    GrEngine _engine;
    GrLibrary _stdlib;
    GrLibrary _magialib;
}

void main() {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    try {
        runApplication();
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}

/// Lance l’application
void runApplication() {
    createWindow(Vec2u(800, 600), "Magia - Runtime");
    initializeEvents();
    _tickStartFrame = Clock.currStdTime();

    initFont();

    initializeScene();

    initUI();

    // Script
    _stdlib = grLoadStdLibrary();
    _magialib = loadMagiaLibrary();
    grSetOutputFunction(&print);

    if (!loadScript()) {
        destroyApplication();
        return;
    }

    while (processEvents()) {
        // Màj
        updateEvents(_deltatime);

        if (getButtonDown(KeyButton.f5)) {
            if (!loadScript()) {
                destroyApplication();
                return;
            }
        }

        if (_engine) {
            if (_engine.hasTasks)
                _engine.process();

            if (_engine.isPanicking) {
                writeln(_engine.prettifyProfiling());

                string err = "panique: " ~ _engine.panicMessage ~ "\n";
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

        updateScene(_deltatime);
        updateUI(_deltatime);

        // Rendu
        // 3D
        setup3DRender();
        drawScene(); /// @ERROR: crash ici quand le script ne compile pas

        // 2D
        setup2DRender();
        drawUI();

        rectPrototype.drawFilledRect(Vec2f(200f, 200f),
                                     Vec2f(50f, 20f),
                                     Color.red);

        circlePrototype.drawFilledCircle(Vec2f(400f, 300f),
                                         50f,
                                         Color.green);

        renderWindow();

        // IPS
        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        if (deltaTicks < (10_000_000 / getNominalFPS()))
            Thread.sleep(dur!("hnsecs")((10_000_000 / getNominalFPS()) - deltaTicks));

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * getNominalFPS();
        _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();
    }
}

bool loadScript() {
    resetScene();
    removeRoots();

    GrCompiler compiler = new GrCompiler;
    compiler.addLibrary(_stdlib);
    compiler.addLibrary(_magialib);

    GrBytecode bytecode = compiler.compileFile("assets/script/main.gr",
        GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

    if (!bytecode) {
        writeln(compiler.getError().prettify(GrLocale.fr_FR));
        _engine = null;
        return false;
    }

    //writeln(grDump(bytecode));

    _engine = new GrEngine;
    _engine.addLibrary(_stdlib);
    _engine.addLibrary(_magialib);
    _engine.load(bytecode);

    if (_engine.hasEvent("onLoad"))
        _engine.callEvent("onLoad");

    return true;
}
