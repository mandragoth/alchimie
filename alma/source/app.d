import std.stdio;

import magia, grimoire, config;
import alma.script, alma.runtime;
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
            boot("test/app.gr", [Alchimie_StandardLibrary_File, "test/assets"]);
        } else {
            if (args.length > 1) {
                Cli cli = new Cli("alma");

                // Default
                cli.setDefault(&cliDefault);
                cli.addOption("v", "version", "Affiche la version du programme");
                cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
                cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
                cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], [
                        "command"
                    ]);

                // Run
                cli.addCommand(&cliRun, "run", "Exécute un fichier source",
                    ["environment", "source"]);
                cli.addCommandOption("run", "h", "help", "Affiche l’aide");
                cli.addCommandOption("run", "b", "symbols",
                    "Génère des symboles de débogage dans le bytecode");
                cli.addCommandOption("run", "p", "profile",
                    "Ajoute des commandes de profilage dans le bytecode");
                cli.addCommandOption("run", "s", "safe",
                    "Change certaines instructions par des versions plus sécurisés");

                // Build
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

                // Doc
                cli.addCommand(&cliRun, "doc", "Exécute un fichier source", [], [
                        "outputDir"
                    ]);
                cli.addCommandOption("doc", "h", "help", "Affiche l’aide");
                cli.addCommandOption("doc", "l", "locale",
                    "Langue dans laquelle la documentation est écrite");

                cli.parse(args);
            } else {
                boot();
            }
        }
    } catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
