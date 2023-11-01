module alma.runtime.runtime;

import std.stdio : writeln;
import std.exception : enforce;
import std.algorithm.mutation : remove;
import std.conv : to;
import std.path, std.file;
import std.datetime, core.thread;

import magia, grimoire, config;
import alma.script;
import alma.runtime.compiler;

final class Alma : Magia {
    private {
        // Grimoire
        GrEngine _engine;
        GrBytecode _bytecode;

        // Événements
        GrEvent _inputEvent, _lateInputEvent;

        const(Archive.File)[] _resourceFiles;
    }

    this(GrBytecode bytecode, uint width, uint height, string name) {
        _bytecode = bytecode;
        enforce(_bytecode, "le bytecode n’a pas pu être chargé");

        super(vec2u(width, height), name);
    }

    override Status load() {
        foreach (const Archive.File file; _resourceFiles) {
            Json json = new Json(file.data);
            Json[] resNodes = json.getObjects("resources", []);
            foreach (resNode; resNodes) {
                string resType = resNode.getString("type");
                auto parser = res.getLoader(resType);
                parser(dirName(file.path), resNode);
            }
        }
        _resourceFiles.length = 0;

        res.make();

        _engine = new GrEngine(Alchimie_Version_ID);

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

        return Status.ok;
    }

    void loadResources(string path) {
        Archive archive = new Archive;

        if (isDir(path)) {
            enforce(exists(path), "le dossier `" ~ path ~ "` n’existe pas");
            archive.pack(path);
        }
        if (extension(path) == Alchimie_Archive_Extension) {
            enforce(exists(path), "l’archive `" ~ path ~ "` n’existe pas");
            archive.load(path);
        }

        foreach (file; archive) {
            if (extension(file.name) == Alchimie_Resource_Extension) {
                _resourceFiles ~= file;
            } else {
                res.write(file.path, file.data);
            }
        }
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
