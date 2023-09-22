module magia.core.archive;

import std.file;
import std.path;
import std.stdio;
import std.exception : enforce;

import magia.core.stream;

/// Conteneur permettant de sérialiser des ressources
final class Archive {
    private enum magicWord = "arc";

    private final class Directory {
        private {
            Directory[string] _dirs;
            File[string] _files;
            string _name;
        }

        @property {
            string name() const {
                return _name;
            }
        }

        this(string name_) {
            _name = name_;
        }

        void pack(string path) {
            auto entries = dirEntries(path, SpanMode.shallow);
            foreach (entry; entries) {
                string name = baseName(entry.name);

                try {
                    if (entry.isDir) {
                        Directory subDir = new Directory(name);
                        subDir.pack(buildNormalizedPath(path, entry.name));
                        _dirs[name] = subDir;
                    } else if (entry.isFile) {
                        File file = new File(name);
                        file.pack(entry.name);
                        _files[name] = file;
                    }
                } catch (Exception e) {
                    writeln("Erreur d’archivage: ", entry.name);
                }
            }
        }

        void unpack(string path) {
            if (!exists(path))
                mkdir(path);

            foreach (file; _files) {
                file.unpack(buildNormalizedPath(path, file.name));
            }

            foreach (dir; _dirs) {
                dir.unpack(buildNormalizedPath(path, dir.name));
            }
        }

        void load(InStream stream) {
            size_t fileCount = stream.read!size_t();
            for (int i; i < fileCount; ++i) {
                string name = stream.read!string();
                File file = new File(name);
                file.load(stream);
                _files[name] = file;
            }

            size_t dirCount = stream.read!size_t();
            for (int i; i < dirCount; ++i) {
                string name = stream.read!string();
                Directory dir = new Directory(name);
                dir.load(stream);
                _dirs[name] = dir;
            }
        }

        void save(OutStream stream) {
            stream.write(_files.length);
            foreach (file; _files) {
                stream.write(file.name);
                file.save(stream);
            }

            stream.write(_dirs.length);
            foreach (dir; _dirs) {
                stream.write(dir.name);
                dir.save(stream);
            }
        }
    }

    private final class File {
        private {
            string _name;
            ubyte[] _data;
        }

        @property {
            string name() const {
                return _name;
            }
        }

        this(string name_) {
            _name = name_;
        }

        void pack(string path) {
            _data = cast(ubyte[]) std.file.read(path);
        }

        void unpack(string path) {
            std.file.write(path, _data);
        }

        void load(InStream stream) {
            _data = stream.read!(ubyte[])();
        }

        void save(OutStream stream) {
            stream.write!(ubyte[])(_data);
        }
    }

    private {
        Directory _rootDir;
    }

    /// Ctor
    this() {
    }

    /// Charge un dossier
    void pack(string path) {
        _rootDir = new Directory(baseName(path));
        _rootDir.pack(path);
    }

    /// Enregistre un dossier
    void unpack(string path) {
        if (_rootDir)
            _rootDir.unpack(path);
    }

    /// Charge une archive
    void load(string path) {
        InStream stream = new InStream;
        enforce(stream.read!string() == magicWord);
        stream.data = cast(ubyte[]) std.file.read(path);
        _rootDir = new Directory(baseName(path));
        _rootDir.load(stream);
    }

    /// Enregistre une archive
    void save(string path) {
        OutStream stream = new OutStream;
        stream.write(magicWord);
        if (_rootDir)
            _rootDir.save(stream);
        std.file.write(path, stream.data);
    }
}
