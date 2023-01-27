module sorcier.runtime.runtime;

import std.stdio : writeln;
import std.exception : enforce;
import std.algorithm.mutation : remove;
import std.conv : to;
import std.path, std.file;
import std.datetime, core.thread;

import grimoire;
import magia;
import sorcier.common;
import sorcier.loader;
import sorcier.script;

void bootUp(string[] args) {
    string bootFile;

    if (args.length) {
        string exePath = args[0];

        string exeDir = dirName(exePath);
        string exeName = stripExtension(baseName(exePath));

        bootFile = buildNormalizedPath(exeDir, setExtension(exeName, Alchimie_BootExt));
    }
    else {
        bootFile = setExtension("boot", Alchimie_BootExt);
    }

    Runtime rt = new Runtime(bootFile);

    rt.run();
}

void launchProject(string path) {
    Runtime rt = new Runtime(path);

    rt.run();
}

final class Runtime {
    private {
        string _filePath;

        // Grimoire
        GrEngine _engine;
        GrLibrary _stdLib;
        GrLibrary _alchimieLib;
        GrBytecode _bytecode;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;

        // IPS
        float _deltatime = 1f;
        float _currentFps;
        long _tickStartFrame;
    }

    this(string filePath) {
        _filePath = filePath;
        enforce(exists(_filePath), "boot file does not exist `" ~ _filePath ~ "`");

        _load();
    }

    private void _load() {
        _stdLib = grLoadStdLibrary();
        _alchimieLib = loadAlchimieLibrary();

        version (AlchimieDist) {
            _bytecode = new GrBytecode(_filePath);
        }
        else {
            GrCompiler compiler = new GrCompiler;
            compiler.addLibrary(_stdLib);
            compiler.addLibrary(_alchimieLib);

            _bytecode = compiler.compileFile(_filePath,
                GrOption.profile | GrOption.symbols | GrOption.safe, GrLocale.fr_FR);

            if (!_bytecode) {
                writeln(compiler.getError().prettify(GrLocale.fr_FR));
            }
        }

        _engine = new GrEngine;
        _engine.addLibrary(_stdLib);
        _engine.addLibrary(_alchimieLib);
        _engine.load(_bytecode);

        _engine.callEvent("onLoad");

        _inputEvent = _engine.getEvent("input", [
                grList(grGetNativeType("InputEvent"))
            ]);
        _lateInputEvent = _engine.getEvent("lateInput", [
                grList(grGetNativeType("InputEvent"))
            ]);

        grSetOutputFunction(&print);

        // Create the application
        currentApplication = new Application(vec2u(800, 800), "Alchimie");

        // Load resources
        loadResources();

        // Create scene and renderers once data loaded
        currentApplication.postLoad();
    }

    void run() {
        _tickStartFrame = Clock.currStdTime();

        while (currentApplication.isRunning()) {
            InputEvent[] inputEvents = currentApplication.pollEvents();

            if (_engine) {
                if (_inputEvent && inputEvents.length) {
                    _engine.callEvent(_inputEvent, [GrValue(inputEvents)]);
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

            // @TODO delegate to scripts events?
            currentApplication.update();

            if (_engine) {
                if (_lateInputEvent && inputEvents.length) {
                    _engine.callEvent(_lateInputEvent, [GrValue(inputEvents)]);
                }
            }

            // @TODO delegate to scripts events?
            //currentApplication.draw();
        }
    }
}
