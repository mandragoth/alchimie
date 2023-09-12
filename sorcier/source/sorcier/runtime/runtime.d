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

        bootFile = buildNormalizedPath(exeDir, setExtension(exeName, Sorcier_GrimoireCompiledExt));
    } else {
        bootFile = setExtension("boot", Sorcier_GrimoireCompiledExt);
    }

    Runtime rt = new Runtime(bootFile);

    rt.run();
}

void launchProject(string path) {
    Runtime rt = new Runtime(path);

    rt.run();
}

final class Runtime : Application {
    private {
        string _filePath;

        // Grimoire
        GrEngine _engine;
        GrLibrary _stdLib;
        GrLibrary _alchimieLib;
        GrBytecode _bytecode;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;
    }

    this(string filePath) {
        _filePath = filePath;
        enforce(exists(_filePath), "boot file does not exist `" ~ _filePath ~ "`");

        super(vec2u(800, 800), "Alchimie");
    }

    override Status load() {
        _stdLib = grLoadStdLibrary();
        _alchimieLib = loadAlchimieLibrary();

        version (SorcierRT) {
            _bytecode = new GrBytecode(_filePath);
        } else {
            GrCompiler compiler = new GrCompiler;
            compiler.addLibrary(_stdLib);
            compiler.addLibrary(_alchimieLib);

            compiler.addFile(_filePath);

            _bytecode = compiler.compile(GrOption.profile | GrOption.symbols | GrOption.safe,
                GrLocale.fr_FR);

            if (!_bytecode) {
                writeln(compiler.getError().prettify(GrLocale.fr_FR));
                return Status.error;
            }

            //writeln(_bytecode.prettify());
        }

        _engine = new GrEngine;
        _engine.addLibrary(_stdLib);
        _engine.addLibrary(_alchimieLib);
        _engine.load(_bytecode);

        _engine.callEvent("onLoad");

        _inputEvent = _engine.getEvent("input", [grGetNativeType("InputEvent")]);
        _lateInputEvent = _engine.getEvent("lateInput", [
                grGetNativeType("InputEvent")
            ]);

        grSetOutputFunction(&print);

        // Load resources
        loadResources();

        return Status.ok;
    }

    override Status tick() {
        if (!_engine)
            return Status.exit;

        InputEvent[] inputEvents = pollEvents();

        if (_inputEvent) {
            foreach (InputEvent inputEvent; inputEvents) {
                _engine.callEvent(_inputEvent, [GrValue(inputEvent)]);
            }
        }

        if (_engine.hasTasks)
            _engine.process();
        else {
            _engine = null;
            return Status.exit;
        }

        remove!(a => a.isAccepted)(inputEvents);

        if (_engine.isPanicking) {
            string err = "panique: " ~ _engine.panicMessage ~ "\n";
            foreach (trace; _engine.stackTraces) {
                err ~= "[" ~ to!string(
                    trace.pc) ~ "] dans " ~ trace.name ~ " à " ~ trace.file ~ "(" ~ to!string(
                    trace.line) ~ "," ~ to!string(trace.column) ~ ")\n";
            }
            _engine = null;
            writeln(err);
            return Status.error;
        }

        if (_lateInputEvent && inputEvents.length) {
            _engine.callEvent(_lateInputEvent, [GrValue(inputEvents)]);
        }

        return Status.ok;
    }
}
