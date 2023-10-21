module magia.core.resource;

import std.typecons;
import std.algorithm : count;
import std.conv : to;
import std.exception : enforce;
import std.traits : isCopyable;

import magia.core.json;

/// Classe gérée par le système de ressource
interface Resource {
    /// Fabrique une ressource à partir du prototype
    Resource make();
}

/// Gestionnaire des ressources
final class ResourceManager {
    private alias LoaderFunc = void function(string, Json);
    private alias FileData = const(ubyte)[];

    private {
        FileData[string] _files;
        LoaderFunc[string] _loaders;
        Cache[string] _caches;
    }

    /// Cache pour les ressources d’un type donné
    private final class Cache {
        private {
            Resource[string] _data;
        }

        /// Ajoute le prototype d’une ressource
        void setPrototype(string name, Resource value) {
            _data[name] = value;
        }

        /// Récupère le prototype d’une ressource
        Resource getPrototype(string name) {
            auto p = (name in _data);
            enforce(p, "la ressource `" ~ name ~ "` n’existe pas");
            return *p;
        }

        /// Récupère le prototype d’une ressource
        Resource get(string name) {
            auto p = getPrototype(name);
            return p.make();
        }
    }

    /// Init
    this() {

    }

    /// Charge un fichier
    void write(string path, FileData data) {
        _files[path] = data;
    }

    /// Retourne les données d’un fichier chargé
    FileData read(string path) const {
        auto p = path in _files;
        enforce(p, "le fichier `" ~ path ~ "` n’existe pas");
        return *p;
    }

    /// Ditto
    string readText(string path) const {
        import std.utf : validate;

        string text = cast(string) read(path);
        validate(text);
        return text;
    }

    /// Ajoute un type de ressource
    void setLoader(string type, LoaderFunc callback) {
        _loaders[type] = callback;
    }

    LoaderFunc getLoader(string type) const {
        auto p = type in _loaders;
        enforce(p, "aucune fonction de définie pour le type `" ~ type ~ "`");
        return *p;
    }

    /// Definit un prototype d’une ressource
    void store(T : Resource)(string name, T prototype) {
        static assert(!__traits(isAbstractClass, T), "`" ~ T.stringof ~ "` est une classe abstraite");

        auto p = T.stringof in _caches;
        Cache cache;

        if (p) {
            cache = *p;
        } else {
            cache = new Cache;
            _caches[T.stringof] = cache;
        }

        cache.setPrototype(name, prototype);
    }

    /// Retourne le prototype d’une ressource
    T getPrototype(T : Resource)(string name) {
        static assert(!__traits(isAbstractClass, T), "`" ~ T.stringof ~ "` est une classe abstraite");

        auto p = T.stringof in _caches;
        enforce(p, "la ressource `" ~ name ~ "` n’existe pas");
        return cast(T)(cast(Cache)*p).getPrototype(name);
    }

    /// Retourne une ressource
    T get(T : Resource)(string name) {
        static assert(!__traits(isAbstractClass, T), "`" ~ T.stringof ~ "` est une classe abstraite");

        auto p = T.stringof in _caches;
        enforce(p, "la ressource `" ~ name ~ "` n’existe pas");
        return cast(T)(cast(Cache)*p).get(name);
    }
}
