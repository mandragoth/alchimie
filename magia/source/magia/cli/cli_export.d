/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.cli_export;

import std.conv : to;
import std.datetime;
import std.exception;
import std.file;
import std.path;
import std.zlib;

import farfadet;
import grimoire;
import magia.core;
import magia.kernel;
import magia.script;
import magia.cli.settings;

void cliExport(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

    string redistPath = buildNormalizedPath(dirName(thisExePath()), Alchimie_Exe);
    enforce(redistPath, "impossible de trouver `" ~ redistPath ~ "`");

    string libraryPath = buildNormalizedPath(dirName(thisExePath()), Alchimie_Library);
    enforce(libraryPath, "impossible de trouver `" ~ libraryPath ~ "`");

    string dir = getcwd();
    string dirBaseName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirBaseName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirBaseName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Alchimie_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de projet `" ~ Alchimie_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    ProjectSettings settings = new ProjectSettings;
    settings.load(projectFile);

    string sourceFile;
    string configName;

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }
    else {
        configName = settings.getDefault();
    }

    ProjectSettings.Config config = settings.getConfig(configName);
    enforce(config,
        "aucune configuration `" ~ configName ~ "` défini dans `" ~ Alchimie_Project_File ~ "`");

    sourceFile = buildNormalizedPath(dir, "source", config.getSource());
    enforce(exists(sourceFile),
        "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
        Alchimie_Project_File ~ "` n’existe pas");

    string exportName = config.getExport();

    if (!exportName.length) {
        exportName = configName;
    }

    string exportDir = buildNormalizedPath(dir, "export", exportName);

    if (!exists(exportDir))
        mkdirRecurse(exportDir);

    string newRedistPath = buildNormalizedPath(exportDir, setExtension(configName, "exe"));
    std.file.copy(redistPath, newRedistPath);

    string newLibraryPath = buildNormalizedPath(exportDir, Alchimie_Library);
    std.file.copy(libraryPath, newLibraryPath);

    string envPath = buildNormalizedPath(exportDir, setExtension(configName,
            Alchimie_Application_Extension));

    string[] archives;

    ResourceManager res = new ResourceManager;
    setupDefaultResourceLoaders(res);

    foreach (media, isArchived; config.getMedias()) {
        string mediaDir = buildNormalizedPath(dir, "media", media);
        enforce(exists(mediaDir),
            "le dossier de ressources `" ~ mediaDir ~ "` référencé dans `" ~
            Alchimie_Project_File ~ "` n’existe pas");

        Archive archive = new Archive;
        archive.pack(mediaDir);

        if (isArchived) {
            string archiveDir = buildNormalizedPath(exportDir,
                setExtension(media, Alchimie_Archive_Extension));
            log("Archivage de `" ~ mediaDir ~ "` vers `", archiveDir, "`");

            foreach (file; archive) {
                if (extension(file.name) == Alchimie_Resource_Extension) {
                    try {
                        OutStream stream = new OutStream;
                        stream.write!string(Alchimie_Resource_Compiled_MagicWord);

                        Farfadet resFfd = Farfadet.fromBytes(file.data);
                        stream.write!uint(cast(uint) resFfd.getNodes().length);
                        foreach (resNode; resFfd.getNodes()) {
                            stream.write!string(resNode.name);

                            ResourceManager.Loader loader = res.getLoader(resNode.name);
                            loader.compile(dirName(file.path) ~ Archive.Separator, resNode, stream);
                        }

                        file.name = setExtension(file.name, Alchimie_Resource_Compiled_Extension);
                        file.data = cast(ubyte[]) stream.data;
                    }
                    catch (FarfadetSyntaxException e) {
                        string msg = file.path ~ "(" ~ to!string(
                            e.tokenLine) ~ "," ~ to!string(e.tokenColumn) ~ "): ";
                        e.msg = msg ~ e.msg;
                        throw e;
                    }
                }
            }

            archive.save(archiveDir);
            archives ~= setExtension(media, Alchimie_Archive_Extension);
        }
        else {
            string archiveDir = buildNormalizedPath(exportDir, media);
            log("Copie de `" ~ mediaDir ~ "` vers `", archiveDir, "`");
            archive.unpack(archiveDir);
            archives ~= media;
        }
    }

    foreach (fileName; Alchimie_Dependencies) {
        string filePath = buildNormalizedPath(dirName(thisExePath()), fileName);
        enforce(exists(filePath), "fichier manquant `" ~ filePath ~ "`");

        std.file.copy(filePath, buildNormalizedPath(exportDir, fileName));
    }

    GrLibrary[] libraries = [grGetStandardLibrary(), getAlchimieLibrary()];

    GrCompiler compiler = new GrCompiler(Alchimie_Version_ID);
    foreach (library; libraries) {
        compiler.addLibrary(library);
    }

    compiler.addFile(sourceFile);

    int options = GrOption.none;

    if (cli.hasOption("profile")) {
        options |= GrOption.profile;
    }
    if (cli.hasOption("safe")) {
        options |= GrOption.safe;
    }
    if (cli.hasOption("symbols")) {
        options |= GrOption.symbols;
    }
    log("compilation de `", sourceFile, "`");

    ubyte[] bytecodeBinary;

    try {
        long startTime = Clock.currStdTime();
        GrBytecode bytecode = compiler.compile(options, GrLocale.fr_FR);
        enforce(bytecode, compiler.getError().prettify(GrLocale.fr_FR));
        double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
        log("compilation effectuée en ", to!string(loadDuration), "sec");
        bytecodeBinary = bytecode.serialize();
    }
    catch (Exception e) {
        log(e.msg);
        log("compilation échouée");
        return;
    }

    {
        OutStream envStream = new OutStream;
        envStream.write!string(Alchimie_Environment_MagicWord);
        envStream.write!size_t(Alchimie_Version_ID);
        envStream.write!bool(config.hasWindow());

        if (config.hasWindow()) {
            envStream.write!string(config.getTitle());
            envStream.write!uint(config.getWidth());
            envStream.write!uint(config.getHeight());
            envStream.write!string(config.getIcon());
        }

        envStream.write!size_t(archives.length);
        foreach (string archive; archives) {
            envStream.write!string(archive);
        }
        envStream.write!(ubyte[])(bytecodeBinary);
        std.file.write(envPath, compress(envStream.data));
        log("génération de l’application `", envPath, "`");
    }
}
