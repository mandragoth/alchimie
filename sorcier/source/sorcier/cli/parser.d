module sorcier.cli.parser;

import grimoire;

import sorcier.common, sorcier.runtime;

import sorcier.cli.doc, sorcier.cli.exporter, sorcier.cli.help;

void parseArguments(string[] args) {
    version (AlchimieDev) {
        GrLocale locale = GrLocale.fr_FR;

        if (args.length >= 1)
            args = args[1 .. $];

        if (args.length) {
            bool hasFlag;
            do {
                hasFlag = false;
                if (args[0].length && args[0][0] == '-') {
                    hasFlag = true;

                    // À faire: traiter les options
                }
                args = args[1 .. $];
            }
            while (args.length && hasFlag);

            switch (args[0]) {
            case "aide":
            case "help":
                displayHelp();
                break;
            case "lance":
            case "launch":
                if (args.length != 2)
                    throw new Exception("manque le chemin du projet");
                launchProject(args[1]);
                break;
            case "exporte":
            case "export":
                if (args.length != 2)
                    throw new Exception("manque le chemin du projet");
                exportProject(args[1], "game", locale);
                break;
            case "documente":
            case "document":
                generateDoc();
                break;
            default:
                break;
            }
        }
    }
    else {
        launchProject("assets/script/main.gr");
    }
}
