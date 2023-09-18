import std.stdio;

import magia;

import alchimie.cli_default;
import alchimie.cli_export;
import alchimie.cli_init;
import alchimie.cli_run;

void main(string[] args) {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }

    args = [args[0], "run"];
    try {
        Cli cli = new Cli("alchimie");
        cli.setDefault(&cliDefault);
        cli.addOption("v", "version", "Affiche la version du programme");
        cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
        cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
        cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], ["command"]);

        cli.addCommand(&cliInit, "init", "Initialise un projet vide", [], [
                "directory"
            ]);
        cli.addCommandOption("init", "h", "help", "Affiche l’aide de la commande");

        cli.addCommand(&cliRun, "run", "Exécute un projet", [], ["project"]);
        cli.addCommand(&cliExport, "export", "Exporte un projet", [], [
                "project"
            ]);
        cli.addCommand(&cliExport, "pack", "Archive les ressources");
        cli.addCommand(&cliExport, "unpack", "Désarchive les ressources");
        cli.parse(args);
    } catch (Exception e) {
        writeln(e.msg);
    }
}
