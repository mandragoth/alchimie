/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import farfadet;
import grimoire;
import magia.core;
import magia.kernel;
import magia.script;
import magia.cli.settings;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

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

    ProjectSettings settings = new ProjectSettings;
    settings.load(projectFile);

    string sourceFile;
    string configName;

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    } else {
        configName = settings.getDefault();
    }

    ProjectSettings.Config config = settings.getConfig(configName);
    enforce(config,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Alchimie_Project_File ~ "`");

    sourceFile = buildNormalizedPath(dir, "source", config.getSource());
    enforce(exists(sourceFile),
        "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
        Alchimie_Project_File ~ "` n’existe pas");

    string[] archives;
    foreach (media; config.getMedias().byKey) {
        string mediaPath = buildNormalizedPath(dir, "media", media);
        enforce(exists(mediaPath),
            "le dossier de ressources `" ~ mediaPath ~ "` référencé dans `" ~
            Alchimie_Project_File ~ "` n’existe pas");
        archives ~= mediaPath;
    }

    Magia magia = new Magia(false, (GrLibrary[] libraries) {
        GrCompiler compiler = new GrCompiler(Alchimie_Version_ID);
        foreach (library; libraries) {
            compiler.addLibrary(library);
        }

        compiler.addFile(sourceFile);

        GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.profile | GrOption.symbols,
            GrLocale.fr_FR);

        enforce!GrCompilerException(bytecode, compiler.getError().prettify(GrLocale.fr_FR));

        return bytecode;
    }, [grGetStandardLibrary(), getAlchimieLibrary()], config.getWidth(),
        config.getHeight(), config.getTitle());

    version (MagiaExe) {
        magia.addArchive(buildNormalizedPath("..", Alchimie_StandardLibrary_File));
    }

    foreach (string archive; archives) {
        magia.addArchive(archive);
    }

    magia.loadResources();

    if (config.getIcon().length) {
        magia.window.setIcon(config.getIcon());
    } else {
        magia.window.setIcon(Alchimie_Window_Icon_Default);
    }

    magia.run();
}
