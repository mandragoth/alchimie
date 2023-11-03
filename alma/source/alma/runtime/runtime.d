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

        Archive.File[] _resourceFiles, _compiledResourceFiles;
    }

    this(GrBytecode bytecode, uint width, uint height, string name) {
        _bytecode = bytecode;
        enforce(_bytecode, "le bytecode n’a pas pu être chargé");

        super(vec2u(width, height), name);
    }

    override Status load() {
        writeln("[ALMA] Compilation des ressources...");
        long startTime = Clock.currStdTime();

        foreach (Archive.File file; _resourceFiles) {
            OutStream stream = new OutStream;
            stream.write!string(Alchimie_Resource_Compiled_MagicWord);

            Json json = new Json(file.data);
            Json[] resNodes = json.getObjects("resources", []);

            stream.write!uint(cast(uint) resNodes.length);
            foreach (resNode; resNodes) {
                string resType = resNode.getString("type");
                stream.write!string(resType);

                ResourceManager.Loader loader = res.getLoader(resType);
                loader.compile(dirName(file.path), resNode, stream);
            }

            file.data = cast(ubyte[]) stream.data;
            _compiledResourceFiles ~= file;
        }
        _resourceFiles.length = 0;

        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");

        writeln("[ALMA] Chargement des ressources...");
        startTime = Clock.currStdTime();

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

        loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");

        writeln("[ALMA] Post-traitement des ressources...");
        startTime = Clock.currStdTime();

        res.make();

        loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");

        writeln("[ALMA] Initialisation de la machine virtuelle...");
        startTime = Clock.currStdTime();

        _engine = new GrEngine(Alchimie_Version_ID);

        foreach (GrLibrary lib; getLibraries()) {
            _engine.addLibrary(lib);
        }

        enforce(_engine.load(_bytecode), "version du bytecode invalide");

        _engine.callEvent("app");

        _inputEvent = _engine.getEvent("input", [grGetNativeType("InputEvent")]);
        _lateInputEvent = _engine.getEvent("lateInput", [
                grGetNativeType("InputEvent")
            ]);

        grSetOutputFunction(&print);

        loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");

        return Status.ok;
    }

    void loadResources(string path) {
        writeln("[ALMA] Chargement de l’archive `" ~ path ~ "`...");
        long startTime = Clock.currStdTime();

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
        writeln("  > Effectué en " ~ to!string(loadDuration) ~ "sec");
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
