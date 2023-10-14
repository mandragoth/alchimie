module alchimie.cli_create;

import std.stdio, std.file, std.path;
import std.exception;

import magia;
import alchimie.constants;

private enum Default_SourceFileContent = `
event app {
    // Début du programme
    print("Hello World !");
}
`;

private enum Default_GitIgnoreContent = `
# Dossiers
export/

# Fichiers
*.arc
*.grc
`;

void cliCreate(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParams.length == 1) {
        enforce(isValidPath(cli.optionalParams[0]), "chemin non valide");
        dirName = baseName(cli.optionalParams[0]);
        dir = buildNormalizedPath(dir, cli.optionalParams[0]);

        if (!exists(dir))
            mkdir(dir);
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string appName = dirName;
    string srcPath = setExtension(Alchimie_Project_App, "gr");

    if (cli.hasOption(Alchimie_Project_App)) {
        Cli.Result.Option option = cli.getOption(Alchimie_Project_App);
        appName = option.requiredParams[0];
    }

    if (cli.hasOption(Alchimie_Project_Source)) {
        Cli.Result.Option option = cli.getOption(Alchimie_Project_Source);
        srcPath = buildNormalizedPath(option.requiredParams[0]);
    }

    Json json = new Json;
    {
        Json configNode = new Json;
        configNode.set(Alchimie_Project_Resources, "res");
        configNode.set("export", "export");
        json.set("config", configNode);
    }

    {
        Json appNode = new Json;
        appNode.set(Alchimie_Project_Name, appName);
        appNode.set(Alchimie_Project_Source, srcPath);

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", 800);
            windowNode.set("height", 600);
            appNode.set("window", windowNode);
        }

        json.set(Alchimie_Project_App, appNode);
    }

    json.save(buildNormalizedPath(dir, Alchimie_Project_File));

    foreach (subDir; ["res", "src", "export"]) {
        string resDir = buildNormalizedPath(dir, subDir);
        if (!exists(resDir))
            mkdir(resDir);
    }

    std.file.write(buildNormalizedPath(dir, ".gitignore"), Default_GitIgnoreContent);
    std.file.write(buildNormalizedPath(dir, srcPath), Default_SourceFileContent);

    writeln("Projet `", dirName, "` créé");
}
