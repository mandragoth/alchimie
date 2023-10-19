module magia.core.archive;

import std.file;
import std.path;
import std.stdio;
import std.exception : enforce;

import magia.core.stream;

/// Modèle d’archivage
interface IArchive {
    /// Charge un dossier
    void pack(string);

    /// Enregistre un dossier
    void unpack(string);

    /// Charge une archive
    void load(string);

    /// Enregistre une archive
    void save(string);
}

/// Conteneur permettant de sérialiser les fichiers d’un dossier
final class Archive : IArchive {
    private enum MagicWord = "CodexMagicae";

    /// ARC: **ARC**chive
    enum Ext = ".arc";

    /// Séparateur de chemin
    enum Separator = "/";

    private final class Directory {
        private {
            Directory[string] _dirs;
            File[string] _files;
            string _path, _name;
        }

        @property {
            string path() const {
                return _path;
            }

            string name() const {
                return _name;
            }
        }

        this(string path_, string name_) {
            _path = path_;
            _name = name_;
        }

        void pack(string path_) {
            auto entries = dirEntries(path_, SpanMode.shallow);
            foreach (entry; entries) {
                string name = baseName(entry.name);
                string subPath = _path ~ Separator ~ name;

                try {
                    if (entry.isDir) {
                        Directory subDir = new Directory(subPath, name);
                        subDir.pack(entry.name);
                        _dirs[name] = subDir;
                    } else if (entry.isFile) {
                        File file = new File(subPath, name);
                        file.pack(entry.name);
                        _files[name] = file;
                    }
                } catch (Exception e) {
                    writeln("Erreur d’archivage: ", entry.name, " - ", e.msg);
                }
            }
        }

        void unpack(string path_) {
            if (!exists(path_))
                mkdir(path_);

            foreach (file; _files) {
                file.unpack(buildNormalizedPath(path_, file.name));
            }

            foreach (dir; _dirs) {
                dir.unpack(buildNormalizedPath(path_, dir.name));
            }
        }

        void load(InStream stream) {
            size_t fileCount = stream.read!size_t();
            for (int i; i < fileCount; ++i) {
                string name = stream.read!string();
                File file = new File(_path ~ Separator ~ name, name);
                file.load(stream);
                _files[name] = file;
            }

            size_t dirCount = stream.read!size_t();
            for (int i; i < dirCount; ++i) {
                string name = stream.read!string();
                Directory dir = new Directory(_path ~ Separator ~ name, name);
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

        /// Itérateur
        int opApply(int delegate(const ref File) dlg) const {
            int result;

            foreach (file; _files) {
                result = dlg(file);

                if (result)
                    return result;
            }

            foreach (dir; _dirs) {
                result = dir.opApply(dlg);

                if (result)
                    return result;
            }

            return result;
        }
    }

    /// Fichier
    final class File {
        private {
            string _path, _name;
            ubyte[] _data;
        }

        @property {
            /// Chemin du fichier
            string path() const {
                return _path;
            }

            /// Nom du fichier
            string name() const {
                return _name;
            }

            /// Données
            const(ubyte)[] data() const {
                return _data;
            }
        }

        private this(string path_, string name_) {
            _path = path_;
            _name = name_;
        }

        private void pack(string path_) {
            _data = cast(ubyte[]) std.file.read(path_);
        }

        private void unpack(string path_) {
            std.file.write(path_, _data);
        }

        private void load(InStream stream) {
            _data = stream.read!(ubyte[])();
        }

        private void save(OutStream stream) {
            stream.write!(ubyte[])(_data);
        }
    }

    private {
        Directory _rootDir;
    }

    /// Init
    this() {
    }

    /// Charge un dossier
    void pack(string path) {
        string name = baseName(path);
        _rootDir = new Directory(name, name);
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
        enforce(stream.read!string() == MagicWord);
        stream.data = cast(ubyte[]) std.file.read(path);
        string name = stream.read!string();
        _rootDir = new Directory(name, name);
        _rootDir.load(stream);
    }

    /// Enregistre une archive
    void save(string path) {
        OutStream stream = new OutStream;
        stream.write(MagicWord);
        if (_rootDir) {
            stream.write(_rootDir.name);
            _rootDir.save(stream);
        }
        std.file.write(path, stream.data);
    }

    /// Itérateur
    int opApply(int delegate(const ref File) dlg) const {
        if (_rootDir)
            return _rootDir.opApply(dlg);

        return 0;
    }
}
