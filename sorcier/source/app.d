import std.stdio;

import std.algorithm.mutation : remove;
import std.conv : to;
import std.path : buildNormalizedPath;
import std.file : exists;
import std.exception : enforce;

import magia, grimoire;

import sorcier.script, sorcier.common, sorcier.runtime;
import sorcier.cli;

/// Configuration du ramasse-miettes
extern (C) __gshared string[] rt_options = [
    "gcopt=initReserve:128 minPoolSize:256 parallel:2 profile:0"
];

void main(string[] args) {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    try {
        if (!args.length)
            return;

        version (SorcierDev) {
            Cli cli = new Cli("sorcierdev");

            cli.setDefault(&cliDefault);
            cli.addOption("v", "version", "Affiche la version du programme");
            cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
            cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
            cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], ["command"]);

            cli.addCommand(&cliRun, "run", "Exécute un fichier source", [
                    "source"
                ]);
            cli.addCommand(&cliBuild, "build",
                "Compile un fichier source en bytecode", ["source"], [
                    "bytecode"
                ]);

            cli.parse(args);
        } else {
            GrBytecode bytecode;

            version (SorcierDebug) {
                string filePath = buildNormalizedPath("assets", "script", "main.gr");
                enforce(exists(filePath), "le fichier source `" ~ filePath ~ "` n’existe pas");
                bytecode = compileSource(filePath, GrLocale.fr_FR);
            } else {
                string filePath = withExtension(thisExePath(), Sorcier_GrimoireCompiledExt);
                enforce(exists(filePath), "le fichier bytecode `" ~ filePath ~ "` n’existe pas");
                bytecode = new GrBytecode(filePath);
            }

            Runtime rt = new Runtime(bytecode);
            rt.run();
        }
    } catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
