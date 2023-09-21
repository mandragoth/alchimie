module alchimie.cli_create;

import std.stdio, std.file, std.path;
import std.exception;

import magia;

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
    string srcPath = setExtension("app", "gr");

    if (cli.hasOption("app")) {
        Cli.Result.Option option = cli.getOption("app");
        appName = option.requiredParams[0];
    }

    if (cli.hasOption("source")) {
        Cli.Result.Option option = cli.getOption("source");
        srcPath = buildNormalizedPath(option.requiredParams[0]);
    }

    Json json = new Json;
    {
        Json configNode = new Json;
        configNode.set("resources", "res");
        configNode.set("export", "export");
        json.set("config", configNode);
    }

    {
        Json appNode = new Json;
        appNode.set("name", appName);
        appNode.set("source", srcPath);

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", 800);
            windowNode.set("height", 600);
            appNode.set("window", windowNode);
        }

        json.set("app", appNode);
    }

    json.save(buildNormalizedPath(dir, "alchimie.json"));

    foreach (subDir; ["res", "src", "export"]) {
        string resDir = buildNormalizedPath(dir, subDir);
        if (!exists(resDir))
            mkdir(resDir);
    }

    std.file.write(buildNormalizedPath(dir, ".gitignore"), Default_GitIgnoreContent);
    std.file.write(buildNormalizedPath(dir, srcPath), Default_SourceFileContent);

    writeln("Projet `", dirName, "` créé");
}
