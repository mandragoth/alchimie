module alma.runtime.boot;

import std.exception : enforce;
import std.file : exists, thisExePath, read;
import std.path : dirName, buildNormalizedPath, setExtension;
import std.stdio : writeln;

import magia, grimoire, config;

import alma.runtime.compiler;
import alma.runtime.runtime;

/// Démarre la machine virtuelle
version (AlmaDebug) {
    void boot(string srcPath, string[] archives) {
        GrBytecode bytecode;
        string windowTitle = "Alchimie Machine ~ v" ~ Alchimie_Version_Display ~ " (Debug)";
        uint windowWidth = Alchimie_Window_Width_Default;
        uint windowHeight = Alchimie_Window_Height_Default;
        bool windowEnabled = Alchimie_Window_Enabled_Default;
        string windowIcon;
        string exeDir = dirName(thisExePath());

        enforce(exists(srcPath), "le fichier source `" ~ srcPath ~ "` n’existe pas");

        bytecode = compileSource(srcPath,
            GrOption.safe | GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

        Alma alma = new Alma(bytecode, windowWidth, windowHeight, windowTitle);
        if (windowIcon.length)
            alma.window.icon = windowIcon;

        foreach (string archive; archives) {
            writeln("Archive chargé: ", archive);
            alma.loadResources(archive);
        }

        alma.run();
    }
} else {
    void boot(string envPath = "", string srcPath = "") {
        GrBytecode bytecode;
        string windowTitle = "Alchimie Machine ~ v" ~ Alchimie_Version_Display;
        uint windowWidth = Alchimie_Window_Width_Default;
        uint windowHeight = Alchimie_Window_Height_Default;
        bool windowEnabled = Alchimie_Window_Enabled_Default;
        string windowIcon;
        string[] archives;
        string exeDir = dirName(thisExePath());
        string envDir = exeDir;

        if (envPath.length) {
            envDir = dirName(envPath);
        }

        if (!envPath.length) {
            envPath = setExtension(thisExePath(), Alchimie_Environment_Extension);
        }
        enforce(exists(envPath), "le fichier d’initialisation `" ~ envPath ~ "` n’existe pas");

        InStream envStream = new InStream;
        envStream.set(cast(const ubyte[]) read(envPath));
        enforce(envStream.read!string() == "alma", "le fichier `" ~ envPath ~ "` est invalide");
        enforce(envStream.read!size_t() == Alchimie_Version_ID,
            "le fichier `" ~ envPath ~ "` est invalide");

        windowEnabled = envStream.read!bool();
        if (windowEnabled) {
            windowTitle = envStream.read!string();
            windowWidth = envStream.read!uint();
            windowHeight = envStream.read!uint();

            windowIcon = buildNormalizedPath(envDir, envStream.read!string());
            if (!exists(windowIcon))
                windowIcon.length = 0;
        }

        archives ~= Alchimie_StandardLibrary_Path;
        size_t archiveCount = envStream.read!size_t();
        for (int i; i < archiveCount; ++i) {
            archives ~= envStream.read!string();
        }

        if (srcPath.length) {
            enforce(exists(srcPath), "le fichier source `" ~ srcPath ~ "` n’existe pas");
            bytecode = compileSource(srcPath,
                GrOption.safe | GrOption.profile | GrOption.symbols, GrLocale.fr_FR);
        } else {
            string bytecodePath = setExtension(thisExePath(), Alchimie_Bytecode_Extension);
            enforce(exists(bytecodePath), "le fichier bytecode `" ~ bytecodePath ~
                    "` n’existe pas");
            bytecode = new GrBytecode(bytecodePath);
        }

        Alma alma = new Alma(bytecode, windowWidth, windowHeight, windowTitle);
        if (windowIcon.length)
            alma.window.icon = windowIcon;

        foreach (string archive; archives) {
            alma.loadResources(archive);
        }

        alma.run();
    }
}
