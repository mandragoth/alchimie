module alchimie.cli_export;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import magia, config;

void cliExport(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string almaPath = buildNormalizedPath(dirName(thisExePath()), Alchimie_Alma_Exe);
    enforce(almaPath, "impossible de trouver `" ~ almaPath ~ "`");

    string dir = getcwd();
    string dirBaseName = baseName(dir);

    if (cli.optionalParams.length >= 1) {
        enforce(isValidPath(cli.optionalParams[0]), "chemin non valide");
        dirBaseName = baseName(cli.optionalParams[0]);
        dir = buildNormalizedPath(dir, cli.optionalParams[0]);
    }
    enforce(!extension(dirBaseName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(projectFile);

    string sourceFile;
    string configName = json.getString(Alchimie_Project_DefaultConfiguration_Node, "");

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").requiredParams[0];
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

            string exportDir = buildNormalizedPath(dir,
                configNode.getString(Alchimie_Project_Export_Node));

            if (!exists(exportDir))
                mkdir(exportDir);

            string newAlmaPath = buildNormalizedPath(exportDir, setExtension(configName, "exe"));
            std.file.copy(almaPath, newAlmaPath);

            string envPath = buildNormalizedPath(exportDir,
                setExtension(configName, Alchimie_Environment_Extension));

            Json[string] resourcesNode = configNode.getObject(Alchimie_Project_Resources_Node)
                .getChildren();
            string[] archives;

            foreach (string resName, Json resNode; resourcesNode) {
                string resFolder = buildNormalizedPath(dir, resNode.getString("path", resName));
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

                Archive archive = new Archive;
                archive.pack(resFolder);
                if (resNode.getBool("archived", true)) {
                    string resDir = buildNormalizedPath(exportDir,
                        setExtension(resName, Alchimie_Archive_Extension));
                    writeln("Archivage de `" ~ resFolder ~ "` vers `", resDir, "`");
                    archive.save(resDir);
                    archives ~= setExtension(resName, Alchimie_Archive_Extension);
                } else {
                    string resDir = buildNormalizedPath(exportDir, resName);
                    writeln("Copie de `" ~ resFolder ~ "` vers `", resDir, "`");
                    archive.unpack(resDir);
                    archives ~= resName;
                }
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

            if (windowIcon.length) {
                std.file.copy(buildNormalizedPath(dir, windowIcon),
                    buildNormalizedPath(exportDir, windowIcon));
            }

            foreach (fileName; [Alchimie_StandardLibrary_Path, "SDL2.dll", "SDL2_image.dll", "SDL2_ttf.dll", "OpenAL32.dll"]) {
                string filePath = buildNormalizedPath(dirName(thisExePath()), fileName);
                enforce(exists(filePath), "fichier manquant `" ~ filePath ~ "`");

                std.file.copy(filePath, buildNormalizedPath(exportDir, fileName));
            }

            string bytecodePath = buildNormalizedPath(exportDir,
                setExtension(configName, Alchimie_Bytecode_Extension));

            {
                OutStream envStream = new OutStream;
                envStream.write!string("alma");
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

            writeln("CMD: ", [almaPath, "build", sourceFile, bytecodePath]);

            string ret = execute([almaPath, "build", sourceFile, bytecodePath]).output;

            writeln(ret);

            return;
        }
    }

    enforce(false,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Alchimie_Project_File ~ "`");
}
/*{
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string name = baseName(dir);
    string almaPath = buildNormalizedPath(dirName(thisExePath()), "almadev.exe");

    string configFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(configFile),
        "aucun fichier de project `" ~ Alchimie_Project_File ~ "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(configFile);

    Json configNode = json.getObject("config");

    string resPath = buildNormalizedPath(dir, configNode.getString(Alchimie_Project_Resources_Node));
    enforce(exists(resPath),
        "le dossier de ressources `" ~ resPath ~
        "` référencé dans `" ~ Alchimie_Project_File ~ "` n’existe pas");

    string exportPath = buildNormalizedPath(dir, configNode.getString(Alchimie_Project_Resources_Node));
    if (!exists(exportPath))
        mkdir(exportPath);

    string archivePath = setExtension(exportPath, "arc");
    Archive archive = new Archive;

    archive.pack(resPath);
    archive.save(archivePath);

    writeln("Le dossier `" ~ resPath ~ "` a été archivé dans `" ~ archivePath ~ "`");

    Json configurationsNode = json.getObject(Alchimie_Project_Configurations_Node);
    string appName = json.getString(Alchimie_Project_Name_Node);
    string sourceFile = buildNormalizedPath(dir, configurationsNode.getString(Alchimie_Project_Source_Node));

    string ret = execute([
        almaPath, "build", sourceFile]).output;
    writeln(ret);

    writeln("Export terminé");
}*/
