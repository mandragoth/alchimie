import std.stdio;

import magia;

import alchimie.cli_add;
import alchimie.cli_create;
import alchimie.cli_default;
import alchimie.cli_export;
import alchimie.cli_run;
import alchimie.cli_pack;
import alchimie.cli_unpack;
import alchimie.constants;

void main(string[] args) {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }

    import std.file, std.path;

    chdir("test_prj");
    args = [args[0], "unpack"];

    try {
        Cli cli = new Cli("alchimie");
        cli.setDefault(&cliDefault);
        cli.addOption("v", "version", "Affiche la version du programme");
        cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
        cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
        cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], ["command"]);

        cli.addCommand(&cliCreate, "create", "Crée un projet vide", [], [
                "directory"
            ]);
        cli.addCommandOption("create", "h", "help", "Affiche l’aide de la commande");
        cli.addCommandOption("create", "a", Alchimie_Project_App,
            "Change le nom de l’application", [Alchimie_Project_Name]);
        cli.addCommandOption("create", "s", "source",
            "Change le chemin du fichier source", ["path"]);

        cli.addCommand(&cliAdd, "add", "Ajoute un programme au projet", [
                Alchimie_Project_Name
            ]);
        cli.addCommandOption("add", "h", "help", "Affiche l’aide de la commande");
        cli.addCommandOption("add", "s", "source", "Change le chemin du fichier source", [
                "path"
            ]);

        cli.addCommand(&cliRun, "run", "Exécute un programme", [], [
                Alchimie_Project_Name
            ]);
        cli.addCommand(&cliExport, "export", "Exporte un projet", [], [
                Alchimie_Project_Name
            ]);
        cli.addCommand(&cliPack, "pack", "Archive les ressources");
        cli.addCommand(&cliUnpack, "unpack", "Désarchive les ressources");
        cli.parse(args);
    } catch (Exception e) {
        writeln(e.msg);
    }
}
