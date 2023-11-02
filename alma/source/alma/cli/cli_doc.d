module alma.cli.cli_doc;

import std.stdio : writeln, write;
import std.string;
import std.datetime;
import std.conv : to;
import std.path;
import std.file;

import magia, grimoire;
import alma.script;

version (AlmaRuntime) {
    /// Generate documentation
    void cliDoc(Cli.Result cli) {
        if (cli.hasOption("help")) {
            writeln(cli.getHelp(cli.name));
            return;
        }

        string path = getcwd();
        GrLocale locale = GrLocale.fr_FR;

        if (cli.optionalParamCount() >= 1) {
            path = cli.getOptionalParam(0);
        }

        if (cli.hasOption("locale")) {
            try {
                locale = to!GrLocale(cli.getOption("locale").getRequiredParam(0));
            } catch (Exception e) {
                writeln("Erreur: locale invalide `", cli.getOption("locale")
                        .getRequiredParam(0), "`");
                return;
            }
        }

        writeln("Génération de la documentation en `", to!string(locale), "`");

        const auto startTime = MonoTime.currTime();

        _generateDoc(path, locale);

        auto elapsedTime = MonoTime.currTime() - startTime;
        writeln("Documentation générée dans `" ~ path ~ "` en: \t", elapsedTime);
    }

    /// Génère la documentation
    private void _generateDoc(string path, GrLocale locale) {
        GrLibLoader[] libLoaders = grGetStdLibraryLoaders();
        libLoaders ~= getAlchimieLibraryLoaders();

        int i;
        foreach (libLoader; libLoaders) {
            GrDoc doc = new GrDoc(["docgen" ~ to!string(i)]);
            libLoader(doc);

            const string generatedText = doc.generate(locale);

            string fileName;
            foreach (part; doc.getModule()) {
                if (fileName.length)
                    fileName ~= "_";
                fileName ~= part;
            }
            fileName ~= ".md";
            std.file.write(buildNormalizedPath(path, fileName), generatedText);
            i++;
        }
    }
}
