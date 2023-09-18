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

import sorcier.runtime.compiler;

final class Runtime : Application {
    private {
        // Grimoire
        GrEngine _engine;
        GrBytecode _bytecode;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;
    }

    this(GrBytecode bytecode) {
        _bytecode = bytecode;
        enforce(_bytecode, "le bytecode n’a pas pu être chargé");

        super(vec2u(800, 800), "Alchimie");
    }

    override Status load() {
        _engine = new GrEngine(Sorcier_Version);

        foreach (GrLibrary lib; getLibraries()) {
            _engine.addLibrary(lib);
        }

        enforce(_engine.load(_bytecode), "version du bytecode invalide");

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
