module alchimie.cmd_init;

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

void _cmdInit(Cli.Result result) {
    string dir = getcwd();
    string name = baseName(dir);

    if (result.optionalParams.length == 1) {
        enforce(isValidPath(result.optionalParams[0]), "chemin non valide");
        name = baseName(result.optionalParams[0]);
        dir = buildNormalizedPath(dir, result.optionalParams[0]);

        if (!exists(dir))
            mkdir(dir);
    }
    enforce(!extension(name).length, "le nom du projet ne peut pas être un fichier");

    Json json = new Json;
    json.set("name", name);
    json.set("source", "app.gr");
    json.set("resources", "res");
    json.set("export", "export");
    json.save(buildNormalizedPath(dir, "alchimie.json"));

    foreach (subDir; ["res", "export"]) {
        string resDir = buildNormalizedPath(dir, subDir);
        if (!exists(resDir))
            mkdir(resDir);
    }

    std.file.write(buildNormalizedPath(dir, ".gitignore"), Default_GitIgnoreContent);
    std.file.write(buildNormalizedPath(dir, "app.gr"), Default_SourceFileContent);
}
