module alchimie.cli_add;

import std.stdio, std.file, std.path;
import std.exception;

import magia, config;

void cliAdd(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    string jsonPath = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(jsonPath),
        "aucun projet `" ~ Alchimie_Project_File ~ "` trouvable dans `" ~ dir ~ "`");

    Json json = new Json(jsonPath);

    string appName = cli.requiredParams[0];
    string srcPath = setExtension(appName, "gr");

    if (cli.hasOption(Alchimie_Project_Source_Node)) {
        Cli.Result.Option option = cli.getOption(Alchimie_Project_Source_Node);
        srcPath = buildNormalizedPath(option.requiredParams[0]);
    }

    {
        Json configurationsNode = json.getObject(Alchimie_Project_Configurations_Node);
        enforce(configurationsNode.getString(Alchimie_Project_Name_Node) != appName,
            "le nom `" ~ appName ~ "` est déjà utilisé");
    }

    {
        Json programNode = new Json;
        programNode.set(Alchimie_Project_Name_Node, appName);
        programNode.set(Alchimie_Project_Source_Node, srcPath);

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", 800);
            windowNode.set("height", 600);
            programNode.set("window", windowNode);
        }

        Json[] programNodes = json.getObjects(Alchimie_Project_DefaultConfigurationName, []);

        foreach (Json node; programNodes) {
            enforce(node.getString(Alchimie_Project_Name_Node) != appName,
                "le nom `" ~ appName ~ "` est déjà utilisé");
        }
        programNodes ~= programNode;
        json.set(Alchimie_Project_DefaultConfigurationName, programNodes);
    }

    json.save(jsonPath);

    writeln("Ajout de `" ~ appName ~ "` dans `", dirName, "`");
}
