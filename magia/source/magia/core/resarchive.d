module magia.core.resarchive;

import std.file;
import std.path;
import std.stdio;
import std.exception : enforce;

import magia.audio;
import magia.core.archive;
import magia.core.stream;
import magia.core.resource;

/// Conteneur indexant les ressources de magia
final class ResourceArchive : IArchive {
    private enum MagicWord = "ResArchiveMagia";

    /// ARC: **ARC**chive
    enum Ext = ".arc";

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
                        if (extension(entry) == File.Ext)
                            continue;

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

        void cache() {
            foreach (file; _files) {
                file.cache();
            }

            foreach (dir; _dirs) {
                dir.cache();
            }
        }
    }

    /// Fichier
    private final class File {
        enum Type : ubyte {
            unknown,
            image,
            audio,
            farfadet,
            shader,
            model
        }

        private {
            string _name;
            bool _hasRes;
            Type _type;
            ubyte[] _res, _data;
        }

        /// ARS: **A**lchimie **R**e**S**source
        enum Ext = ".ars";

        @property {
            /// Nom
            const(string) name() const {
                return _name;
            }

            /// Données de configuration
            const(ubyte[]) res() const {
                return _res;
            }

            /// Données de ressource
            const(ubyte[]) data() const {
                return _data;
            }

            bool canHaveRes() {
                final switch (_type) with (Type) {
                case unknown:
                case image:
                case audio:
                case shader:
                case model:
                    return true;
                case farfadet:
                    return false;
                }
            }
        }

        this(string name_) {
            _name = name_;
        }

        void pack(string path) {
            switch (extension(path)) {
                // Images
            case ".bmp":
            case ".gif":
            case ".jpg":
            case ".jpeg":
            case ".png":
                _type = Type.image;
                break;
                // Sons
            case ".ogg":
            case ".wav":
            case ".mp3":
                _type = Type.audio;
                break;
                // Animations Farfadet
            case ".ffd":
                _type = Type.farfadet;
                break;
                // Shaders
            case ".glsl":
                _type = Type.shader;
                break;
                // Modèles
            case ".gltf":
                _type = Type.model;
                break;
            default:
                _type = Type.unknown;
                break;
            }

            _data = cast(ubyte[]) std.file.read(path);
            string resPath = path ~ Ext;
            if (canHaveRes() && exists(resPath)) {
                _res = cast(ubyte[]) std.file.read(resPath);
                _hasRes = true;
            }
        }

        void unpack(string path) {
            std.file.write(path, _data);
            if (canHaveRes() && _hasRes)
                std.file.write(path ~ Ext, _res);
        }

        void load(InStream stream) {
            _type = stream.read!Type;
            _hasRes = stream.read!bool;
            _data = stream.read!(ubyte[])();
            if (canHaveRes() && _hasRes)
                _res = stream.read!(ubyte[])();
        }

        void save(OutStream stream) {
            stream.write!Type(_type);
            stream.write!bool(_hasRes);
            stream.write!(ubyte[])(_data);
            if (canHaveRes() && _hasRes)
                stream.write!(ubyte[])(_res);
        }

        void cache() {
            final switch (_type) with (Type) {
            case unknown:
                return;
            case image:
                /*if (_hasRes) {
                    //Texture tex = new Texture(data, TextureType.sprite);
                    
                    foreach (node; json.getObjects("atlas", [])) {
                        string id = node.getString("id");
                        string subType = node.getString("subtype");

                        uint x, y, w = tex.width, h = tex.height;
                        if (node.has("pos")) {
                            Json posNode = node.getObject("pos");
                            x = clamp(posNode.getInt("x", x), 0, tex.width);
                            y = clamp(posNode.getInt("y", y), 0, tex.height);
                            w = clamp(posNode.getInt("w", w), 0, tex.width);
                            h = clamp(posNode.getInt("h", h), 0, tex.height);
                        }

                        node.getString("script", "");

                        //Sprite sprite = new Sprite(id, )

                        //storePrototype!Sprite()
                    }
                } else {
                    //storePrototype!Texture(id, new Texture(data, TextureType.diffuse));
                }*/
                return;
            case audio:
                storePrototype!Sound(_name, new Sound(_data));
                return;
            case shader:
                return;
            case model:
                return;
            case farfadet:
                return;
            }
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
        enforce(stream.read!string() == MagicWord);
        stream.data = cast(ubyte[]) std.file.read(path);
        _rootDir = new Directory(baseName(path));
        _rootDir.load(stream);
    }

    /// Enregistre une archive
    void save(string path) {
        OutStream stream = new OutStream;
        stream.write(MagicWord);
        if (_rootDir)
            _rootDir.save(stream);
        std.file.write(path, stream.data);
    }

    /// Met en cache le contenu de l’archive
    void cache() {
        if (_rootDir)
            _rootDir.cache();
    }
}
