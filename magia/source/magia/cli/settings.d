/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.settings;

import std.file;
import std.path;
import farfadet;

final class ProjectSettings {
    class Config {
        private {
            string _name;
            string _sourceName, _exportName;

            bool[string] _medias;

            bool _hasWindow;
            string _title;
            string _icon;
            uint _width, _height;
        }

        this(string name_) {
            _name = name_;
        }

        void setSource(string name) {
            _sourceName = name;
        }

        string getSource() const {
            return _sourceName;
        }

        void setExport(string path) {
            _exportName = path;
        }

        string getExport() const {
            return _exportName;
        }

        void clearMedias() {
            _medias.clear();
        }

        void addMedia(string name, bool isArchived) {
            _medias[name] = isArchived;
        }

        bool[string] getMedias() {
            return _medias;
        }

        void setWindow(uint width, uint height, string title, string icon) {
            _width = width;
            _height = height;
            _title = title;
            _icon = icon;
            _hasWindow = true;
        }

        bool hasWindow() const {
            return _hasWindow;
        }

        uint getWidth() const {
            return _width;
        }

        uint getHeight() const {
            return _height;
        }

        string getTitle() const {
            return _title;
        }

        string getIcon() const {
            return _icon;
        }

        void removeWindow() {
            _hasWindow = false;
        }

        void load(Farfadet ffd) {
            _name = ffd.get!string(0);

            if (ffd.hasNode("source"))
                _sourceName = ffd.getNode("source", 1).get!string(0);

            if (ffd.hasNode("export"))
                _exportName = ffd.getNode("export", 1).get!string(0);

            _medias.clear();
            foreach (mediaNode; ffd.getNodes("media", 2)) {
                string name = mediaNode.get!string(0);
                bool isArchived = mediaNode.get!bool(1);
                _medias[name] = isArchived;
            }

            _hasWindow = ffd.hasNode("window");

            if (_hasWindow) {
                Farfadet windowNode = ffd.getNode("window");
                Farfadet sizeNode = windowNode.getNode("size", 2);
                _width = sizeNode.get!uint(0);
                _height = sizeNode.get!uint(1);

                _title = "";
                if (windowNode.hasNode("title")) {
                    _title = windowNode.getNode("title", 1).get!string(0);
                }
                _icon = "";
                if (windowNode.hasNode("icon")) {
                    _icon = windowNode.getNode("icon", 1).get!string(0);
                }
            }
        }

        void save(Farfadet ffd) {
            Farfadet configNode = ffd.addNode("config").add(_name);

            if (_sourceName.length)
                configNode.addNode("source").add(_sourceName);

            if (_exportName.length)
                configNode.addNode("export").add(_exportName);

            foreach (name, isArchived; _medias) {
                configNode.addNode("media").add(name).add(isArchived);
            }

            if (_hasWindow) {
                Farfadet windowNode = configNode.addNode("window");
                windowNode.addNode("size").add(_width).add(_height);
                if (_title.length)
                    windowNode.addNode("title").add(_title);
                if (_icon.length)
                    windowNode.addNode("icon").add(_icon);
            }
        }
    }

    private {
        Config[string] _configs;
        string _default;
    }

    void setDefault(string name) {
        _default = name;
    }

    string getDefault() const {
        return _default;
    }

    bool hasConfig(string name) {
        auto p = name in _configs;
        return p !is null;
    }

    Config addConfig(string name) {
        Config cfg = getConfig(name);
        if (cfg)
            return cfg;
        cfg = new Config(name);
        _configs[name] = cfg;
        return cfg;
    }

    Config getConfig(string name) {
        auto p = name in _configs;
        return p ? *p : null;
    }

    void load(string filePath) {
        Farfadet ffd = Farfadet.fromFile(filePath);
        _default = ffd.getNode("default", 1).get!string(0);

        _configs.clear();
        foreach (configNode; ffd.getNodes("config", 1)) {
            Config config = new Config(configNode.get!string(0));
            config.load(configNode);
            _configs[config._name] = config;
        }
    }

    void save(string filePath) {
        Farfadet ffd = new Farfadet;
        if (_default.length)
            ffd.addNode("default").add(_default);
        foreach (config; _configs) {
            config.save(ffd);
        }
        ffd.save(filePath);
    }
}

private enum Default_SourceFileContent = `
event app {
    // Début du programme
    print("Bonjour le monde !");
}
`;

private enum Default_GitIgnoreContent = `
# Dossiers
export/

# Fichiers
*.pqt
*.atl
*.exe
*.dll
*.so
`;

private enum Default_MediaContent = `
1/ Ajoutez vos dossiers media dans ce répertoire
2/ Dans le fichier de projet, ajouter la ligne correspondante dans la configuration voulue:
media "NOM_DU_DOSSIER" true/false (ex: media "img" true)
(true si le fichier doit être compressé durant l’export.)
`;

private enum Default_ExportContent = `
Le projet sera généré dans ce dossier sous le nom donné par le champ export de la configuration (si renseigné)
`;

void generateProjectLayout(string path, string sourceName) {
    if (!exists(path))
        mkdir(path);

    std.file.write(buildNormalizedPath(path, ".gitignore"), Default_GitIgnoreContent);

    foreach (subDir; ["media", "source", "export"]) {
        string dir = buildNormalizedPath(path, subDir);
        if (!exists(dir))
            mkdir(dir);

        switch (subDir) {
        case "media":
            std.file.write(buildNormalizedPath(dir, "media.txt"), Default_MediaContent);
            break;
        case "source":
            std.file.write(buildNormalizedPath(dir, sourceName), Default_SourceFileContent);
            break;
        case "export":
            std.file.write(buildNormalizedPath(dir, "export.txt"), Default_ExportContent);
            break;
        default:
            break;
        }
    }
}
