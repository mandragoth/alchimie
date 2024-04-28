/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.parser;

import std.string;
import std.algorithm;

import magia.core;
import magia.kernel;
import magia.cli.cli_add;
import magia.cli.cli_default;
import magia.cli.cli_export;
import magia.cli.cli_init;
import magia.cli.cli_run;

void parseCli(string[] args) {
    Cli cli = new Cli("magia");
    cli.setDefault(&cliDefault);
    cli.addOption("v", "version", "Affiche la version du programme");
    cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
    cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
    cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], ["command"]);

    cli.addCommand(&cliInit, "init", "Crée un projet vide", [], ["directory"]);
    cli.addCommandOption("init", "h", "help", "Affiche l’aide de la commande");
    cli.addCommandOption("init", "a", "app", "Change le nom de l’application", [
            "name"
        ]);
    cli.addCommandOption("init", "s", "source", "Change le chemin du fichier source", [
            "path"
        ]);

    cli.addCommand(&cliAdd, "add", "Ajoute un programme au projet", ["name"]);
    cli.addCommandOption("add", "h", "help", "Affiche l’aide de la commande");
    cli.addCommandOption("add", "s", "source", "Change le chemin du fichier source", [
            "path"
        ]);

    cli.addCommand(&cliRun, "run", "Exécute un programme", [], ["dir"]);
    cli.addCommandOption("run", "h", "help", "Affiche l’aide de la commande");
    cli.addCommandOption("run", "c", "config",
        "Exécute la configuration spécifiée", ["config"]);

    cli.addCommand(&cliExport, "export", "Exporte un projet", [], ["name"]);
    cli.addCommandOption("export", "h", "help", "Affiche l’aide de la commande");
    cli.parse(args);
}
