/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.cli_init;

import std.stdio, std.file, std.path;
import std.exception;

import farfadet;
import magia.core;
import magia.kernel;
import magia.cli.settings;

void cliInit(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParamCount() == 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));

        if (!exists(dir))
            mkdir(dir);
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string appName = dirName;
    string sourceName = setExtension("app", "gr");

    if (cli.hasOption("app")) {
        Cli.Result.Option option = cli.getOption("app");
        appName = option.getRequiredParam(0);
    }

    if (cli.hasOption("source")) {
        Cli.Result.Option option = cli.getOption("source");
        sourceName = buildNormalizedPath(option.getRequiredParam(0));
    }

    generateProjectLayout(dir, sourceName);

    ProjectSettings settings = new ProjectSettings;
    settings.setDefault(appName);

    ProjectSettings.Config config = settings.addConfig(appName);
    config.setSource(sourceName);
    config.setWindow(Alchimie_Window_Width_Default, Alchimie_Window_Height_Default, appName, "");

    settings.save(buildNormalizedPath(dir, Alchimie_Project_File));

    log("Projet `", dirName, "` créé");
}
