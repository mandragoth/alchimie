module alchimie.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;

void cliRun(Cli.Result cli) {
    string dir = getcwd();
    string name = baseName(dir);

    string sorcierPath = buildNormalizedPath(dirName(thisExePath()), "sorcierdev.exe");

    if (cli.optionalParams.length == 1) {
        enforce(isValidPath(cli.optionalParams[0]), "chemin non valide");
        name = baseName(cli.optionalParams[0]);
        dir = buildNormalizedPath(dir, cli.optionalParams[0]);
    }

    string configFile = buildNormalizedPath(dir, "alchimie.json");
    enforce(exists(configFile),
        "aucun fichier de project `alchimie.json` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    string sourceFile = buildNormalizedPath(dir, json.getString("source"));
    enforce(exists(sourceFile),
        "le fichier source `" ~ sourceFile ~ "` référencé dans `alchimie.json` n’existe pas");
        
    string resFolder = buildNormalizedPath(dir, json.getString("resources"));
    enforce(exists(resFolder),
        "le dossier de ressources `" ~ resFolder ~ "` référencé dans `alchimie.json` n’existe pas");

    string ret = execute([sorcierPath, "run", sourceFile, "––res", resFolder]).output;

    writeln(ret);
}
