module alma.runtime.boot;

import std.exception : enforce;
import std.file : exists, thisExePath;
import std.path : dirName, buildNormalizedPath, setExtension;
import std.stdio : writeln;

import magia, grimoire;
import alma.common;
import alma.runtime.compiler;
import alma.runtime.runtime;

/// Démarre la machine virtuelle
void boot() {
    GrBytecode bytecode;
    string windowName = "Achimie Machine ~ v" ~ Alma_Version_Display;
    uint windowWidth = 800;
    uint windowHeight = 600;
    string windowIcon;

    version (AlmaDebug) {
        windowName ~= " (Debug)";
        string filePath = buildNormalizedPath("assets", "script", "main.gr");
        enforce(exists(filePath), "le fichier source `" ~ filePath ~ "` n’existe pas");
        bytecode = compileSource(filePath,
            GrOption.safe | GrOption.profile | GrOption.symbols, GrLocale.fr_FR);
    } else {
        string dir = dirName(thisExePath());
        string iniPath = setExtension(thisExePath(), Alma_Initialization_Extension);
        enforce(exists(iniPath), "le fichier d’initialisation `" ~ iniPath ~ "` n’existe pas");

        InStream iniStream = new InStream;
        enforce(iniStream.read!string() == "ars", "le fichier `" ~ iniPath ~ "` est invalide");
        enforce(iniStream.read!size_t() == Alma_Version_ID,
            "le fichier `" ~ iniPath ~ "` est invalide");

        windowName = iniStream.read!string();
        windowWidth = iniStream.read!uint();
        windowHeight = iniStream.read!uint();

        windowIcon = buildNormalizedPath(dir, iniStream.read!string());
        if (!exists(windowIcon))
            windowIcon.length = 0;

        string[] archives;
        size_t archiveCount = iniStream.read!size_t();
        for (int i; i < archiveCount; ++i) {
            archives ~= iniStream.read!string();
        }

        string bytecodePath = setExtension(thisExePath(), Alma_Bytecode_Extension);
        enforce(exists(bytecodePath), "le fichier bytecode `" ~ bytecodePath ~ "` n’existe pas");
        bytecode = new GrBytecode(bytecodePath);
    }

    Runtime rt = new Runtime(bytecode, windowWidth, windowHeight, windowName);
    if (windowIcon.length)
        rt.window.icon = windowIcon;
    rt.run();
}
