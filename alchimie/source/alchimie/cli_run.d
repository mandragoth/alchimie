module alchimie.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia;
import alchimie.constants;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);

    string almaPath = buildNormalizedPath(dirName(thisExePath()), Alchimie_Alma_Exe);

    string projectFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(projectFile);

    string sourceFile;
    string appName = Alchimie_Project_App;

    if (cli.optionalParams.length >= 1) {
        Json appNode = json.getObject(Alchimie_Project_App);
        appName = cli.optionalParams[0];
        if (appNode.getString(Alchimie_Project_Name) == appName) {
            sourceFile = buildNormalizedPath(dir, appNode.getString(Alchimie_Project_Source));
        } else {
            Json[] programNodes = json.getObjects(Alchimie_Project_Programs, []);
            bool found;
            foreach (node; programNodes) {
                if (node.getString(Alchimie_Project_Name) == appName) {
                    found = true;
                    sourceFile = buildNormalizedPath(dir, node.getString(Alchimie_Project_Source));
                    break;
                }
            }

            enforce(found,
                "aucun programme `" ~ sourceFile ~ "` défini dans `" ~ Alchimie_Project_File ~ "`");
        }

    } else {
        Json appNode = json.getObject(Alchimie_Project_App);
        appName = json.getString(Alchimie_Project_Name);
        sourceFile = buildNormalizedPath(dir, appNode.getString(Alchimie_Project_Source));
    }

    enforce(exists(sourceFile),
        "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
        Alchimie_Project_File ~ "` n’existe pas");

    string resFolder = buildNormalizedPath(dir, json.getString(Alchimie_Project_Resources));
    enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
            "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

    string ret = execute([almaPath, "run", sourceFile, "––res", resFolder]).output;

    writeln(ret);
}
