module alchimie.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia, config;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string almaPath = buildNormalizedPath(dirName(thisExePath()), Alchimie_Alma_Exe);
    enforce(almaPath, "impossible de trouver `" ~ almaPath ~ "`");

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(projectFile);

    string sourceFile;
    string configName = json.getString(Alchimie_Project_DefaultConfiguration_Node, "");

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }

    Json[] configsNode = json.getObjects(Alchimie_Project_Configurations_Node, [
        ]);
    foreach (Json configNode; configsNode) {
        if (configNode.getString(Alchimie_Project_Name_Node, "") == configName) {
            sourceFile = buildNormalizedPath(dir,
                configNode.getString(Alchimie_Project_Source_Node));

            enforce(exists(sourceFile),
                "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
                Alchimie_Project_File ~ "` n’existe pas");

            Json[string] resourcesNode = configNode.getObject(Alchimie_Project_Resources_Node)
                .getChildren();
            string[] archives;

            foreach (string resName, Json resNode; resourcesNode) {
                string resFolder = buildNormalizedPath(dir, resNode.getString("path", resName));
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

                archives ~= resName;
            }

            Json windowNode = configNode.getObject(Alchimie_Project_Window_Node);
            string windowTitle = windowNode.getString(Alchimie_Project_Window_Title_Node,
                configName);
            int windowWidth = windowNode.getInt(Alchimie_Project_Window_Width_Node,
                Alchimie_Window_Width_Default);
            int windowHeight = windowNode.getInt(Alchimie_Project_Window_Height_Node,
                Alchimie_Window_Height_Default);
            string windowIcon = windowNode.getString(Alchimie_Project_Window_Icon_Node, "");
            bool windowEnabled = windowNode.getBool(Alchimie_Project_Window_Enabled_Node,
                Alchimie_Window_Enabled_Default);

            string envPath = buildNormalizedPath(dir, setExtension(configName,
                    Alchimie_Environment_Extension));

            if (windowIcon.length) {
                std.file.copy(buildNormalizedPath(dir, windowIcon),
                    buildNormalizedPath(dir, windowIcon));
            }

            {
                OutStream envStream = new OutStream;
                envStream.write!string(Alchimie_Environment_MagicWord);
                envStream.write!size_t(Alchimie_Version_ID);
                envStream.write!bool(windowEnabled);

                if (windowEnabled) {
                    envStream.write!string(windowTitle);
                    envStream.write!uint(windowWidth);
                    envStream.write!uint(windowHeight);
                    envStream.write!string(windowIcon);
                }

                envStream.write!size_t(archives.length);
                foreach (string archive; archives) {
                    envStream.write!string(archive);
                }
                std.file.write(envPath, envStream.data);
            }

            string ret = execute([almaPath, "run", envPath, sourceFile]).output;

            writeln(ret);

            return;
        }
    }

    enforce(false,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Alchimie_Project_File ~ "`");
}
