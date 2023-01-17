module app;

import std.stdio;

import std.algorithm.mutation : remove;
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
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}

/// Lance l’application
void runApplication() {
    _tickStartFrame = Clock.currStdTime();

    _magia = new Magia(vec2u(800, 800), "Magia - Runtime");
    loadResources();

    // Script
    _stdlib = grLoadStdLibrary();
    _magialib = loadMagiaLibrary();
    grSetOutputFunction(&print);

    if (!loadScript()) {
        destroyWindow();
        return;
    }

    GrEvent grEventInput, grEventLateInput;
    if (_engine) {
        grEventInput = _engine.getEvent("input", [
                grList(grGetNativeType("InputEvent"))
            ]);
        grEventLateInput = _engine.getEvent("lateInput", [
                grList(grGetNativeType("InputEvent"))
            ]);
    }

    while (_magia.isRunning()) {
        /*if (getButtonDown(KeyButton.f5)) {
            if (!loadScript()) {
                destroyApplication();
                return;
            }
        }*/

        InputEvent[] inputEvents = _magia.pollEvents();

        if (_engine) {
            if (grEventInput && inputEvents.length) {
                _engine.callEvent(grEventInput, [GrValue(inputEvents)]);
                remove!(a => a.isAccepted)(inputEvents);
            }

            if (_engine.hasTasks)
                _engine.process();

            if (_engine.isPanicking) {
                string err = "panique: " ~ _engine.panicMessage ~ "\n";
                foreach (trace; _engine.stackTraces) {
                    err ~= "[" ~ to!string(
                        trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                        trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
                }
                _engine = null;
                writeln(err);

                destroyWindow();
                return;
            }
        }

        _magia.update(_deltatime);

        if (_engine) {
            if (grEventLateInput && inputEvents.length) {
                _engine.callEvent(grEventLateInput, [GrValue(inputEvents)]);
            }
        }

        _magia.render();

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
    _magia.ui.removeRoots();

    GrCompiler compiler = new GrCompiler;
    compiler.addLibrary(_stdlib);
    compiler.addLibrary(_magialib);

    GrBytecode bytecode = compiler.compileFile("assets/script/main.gr",
        GrOption.profile | GrOption.symbols | GrOption.safe, GrLocale.fr_FR);

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

void loadResources() {
    import std.path, std.file;

    auto files = dirEntries(buildNormalizedPath("assets", "texture"), "{*.png}", SpanMode.depth);
    foreach (file; files) {
        string name = baseName(file, ".png");
        storePrototype!Texture(name, new Texture(file, "sprite"));
    }
}
