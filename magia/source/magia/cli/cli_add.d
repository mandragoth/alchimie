/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.cli_add;

import std.stdio, std.file, std.path;
import std.exception;

import farfadet;
import magia.core;
import magia.kernel;

void cliAdd(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    string ffdPath = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(ffdPath), "aucun projet `" ~ Alchimie_Project_File ~
            "` trouvable dans `" ~ dir ~ "`");

    Farfadet ffd = Farfadet.fromFile(ffdPath);

    string configName = cli.getRequiredParam(0);
    string srcPath = setExtension(configName, "gr");

    if (cli.hasOption("source")) {
        Cli.Result.Option option = cli.getOption("source");
        srcPath = buildNormalizedPath(option.getRequiredParam(0));
    }

    {
        const Farfadet[] configNodes = ffd.getNodes("config", 1);

        foreach (configNode; configNodes) {
            enforce(configNode.get!string(0) != configName,
                "le nom `" ~ configName ~ "` est déjà utilisé");
        }
    }

    {
        Farfadet configNode = ffd.addNode("config").add(configName);
        configNode.addNode("source").add(srcPath);
        configNode.addNode("export").add("export");

        Farfadet resNode = configNode.addNode("resource").add("res");
        resNode.addNode("path").add("res");
        resNode.addNode("archived").add(true);

        Farfadet windowNode = configNode.addNode("window");
        windowNode.addNode("size").add(Alchimie_Window_Width_Default)
            .add(Alchimie_Window_Height_Default);
    }

    std.file.write(ffdPath, ffd.generate());

    log("Ajout de `" ~ configName ~ "` dans `", dirName, "`");
}
