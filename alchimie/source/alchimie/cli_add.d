module alchimie.cli_add;

import std.stdio, std.file, std.path;
import std.exception;

import magia;

void cliAdd(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    string jsonPath = buildNormalizedPath(dir, "alchimie.json");
    enforce(exists(jsonPath), "aucun projet `alchimie.json` trouvable dans `" ~ dir ~ "`");

    Json json = new Json(jsonPath);

    string appName = cli.requiredParams[0];
    string srcPath = setExtension(appName, "gr");

    if (cli.hasOption("source")) {
        Cli.Result.Option option = cli.getOption("source");
        srcPath = buildNormalizedPath(option.requiredParams[0]);
    }

    {
        Json appNode = json.getObject("app");
        enforce(appNode.getString("name") != appName, "le nom `" ~ appName ~ "` est déjà utilisé");
    }

    {
        Json programNode = new Json;
        programNode.set("name", appName);
        programNode.set("source", srcPath);

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", 800);
            windowNode.set("height", 600);
            programNode.set("window", windowNode);
        }

        Json[] programNodes = json.getObjects("programs", []);

        foreach (Json node; programNodes) {
            enforce(node.getString("name") != appName, "le nom `" ~ appName ~
                    "` est déjà utilisé");
        }
        programNodes ~= programNode;
        json.set("programs", programNodes);
    }

    json.save(jsonPath);

    writeln("Ajout de `" ~ appName ~ "` dans `", dirName, "`");
}