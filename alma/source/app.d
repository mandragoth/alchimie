import std.stdio;

import std.algorithm.mutation : remove;
import std.conv : to;
import std.path : buildNormalizedPath;
import std.file : exists;
import std.exception : enforce;

import magia, grimoire;

import alma.script, alma.common, alma.runtime;
import alma.cli;

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
        version (AlmaDebug) {
            string filePath = buildNormalizedPath("assets", "script", "main.gr");
            enforce(exists(filePath), "le fichier source `" ~ filePath ~ "` n’existe pas");
            GrBytecode bytecode = compileSource(filePath,
                GrOption.safe | GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

            Runtime rt = new Runtime(bytecode);
            rt.run();
        } else {
            if (!args.length)
                return;

            Cli cli = new Cli("alma");

            cli.setDefault(&cliDefault);
            cli.addOption("v", "version", "Affiche la version du programme");
            cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
            cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
            cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], ["command"]);

            cli.addCommand(&cliRun, "run", "Exécute un fichier source", [
                    "source"
                ]);
            cli.addCommandOption("run", "b", "symbols",
                "Génère des symboles de débogage dans le bytecode");
            cli.addCommandOption("run", "h", "help", "Affiche l’aide");
            cli.addCommandOption("run", "p", "profile",
                "Ajoute des commandes de profilage dans le bytecode");
            cli.addCommandOption("run", "s", "safe",
                "Change certaines instructions par des versions plus sécurisés");

            cli.addCommand(&cliBuild, "build",
                "Compile un fichier source en bytecode", ["source"], [
                    "bytecode"
                ]);
            cli.addCommandOption("build", "h", "help", "Affiche l’aide");
            cli.addCommandOption("build", "b", "symbols",
                "Génère des symboles de débogage dans le bytecode");
            cli.addCommandOption("build", "p", "profile",
                "Ajoute des commandes de profilage dans le bytecode");
            cli.addCommandOption("build", "s", "safe",
                "Change certaines instructions par des versions plus sécurisés");

            cli.parse(args);
        }
    } catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
