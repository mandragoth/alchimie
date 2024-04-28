module magia.doc;

import std.algorithm : min;
import std.string;
import std.datetime;
import std.conv : to;
import std.path;
import std.file;
import grimoire;

import magia.core;
import magia.kernel;
import magia.script;

void generateDoc() {
    const GrLocale locale = GrLocale.fr_FR;
    auto startTime = MonoTime.currTime();

    generate(locale);

    auto elapsedTime = MonoTime.currTime() - startTime;
    log("Documentation générée en ", elapsedTime);
}

void generate(GrLocale locale) {
    GrLibrary library = getAlchimieLibrary();

    string[] modules;

    int i;
    foreach (libLoader; library.loaders) {
        GrModuleDoc doc = new GrModuleDoc("docgen" ~ to!string(i));
        libLoader(doc);

        const string generatedText = doc.generate(locale);

        string fileName = doc.getModule();
        modules ~= fileName;
        fileName ~= ".md";
        string folderName = to!string(locale);
        auto parts = folderName.split("_");
        if (parts.length >= 1)
            folderName = parts[0];
        std.file.write(buildNormalizedPath("docs", "lib", fileName), generatedText);
        i++;
    }

    { // Barre latérale
        string generatedText = "* [Accueil](/)\n";
        generatedText ~= "* [Ressources](/resources)\n";
        generatedText ~= "* [Bibliothèque](/lib/)\n";

        string[] oldParts;
        foreach (fileName; modules) {
            string line;

            string[] parts = fileName.split(".");

            if (parts.length > 1) {
                if (parts.length > oldParts.length) {
                    for (int k = 1; k < parts.length; k++) {
                        generatedText ~= "\t";
                    }

                    int count = (cast(int) parts.length) - (cast(int) oldParts.length);
                    generatedText ~= "* ";
                    for (int k = 0; k < count - 1; k++) {
                        if (k > 0)
                            generatedText ~= ".";
                        generatedText ~= parts[k];
                    }
                    generatedText ~= "\n";
                }
                else {
                    int count = (cast(int) min(oldParts.length, parts.length)) - 1;
                    for (int p; p < count; p++) {
                        if (oldParts[p] != parts[p]) {
                            for (int k = 1; k < parts.length; k++) {
                                generatedText ~= "\t";
                            }

                            generatedText ~= "* ";
                            for (int k = p; k < cast(int)(parts.length) - 1; k++) {
                                if (k > 0)
                                    generatedText ~= ".";
                                generatedText ~= parts[k];
                            }
                            generatedText ~= "\n";
                            break;
                        }
                    }
                }
            }
            oldParts = parts;

            foreach (string key; parts) {
                line ~= "\t";
            }
            line ~= "- [" ~ parts[$ - 1] ~ "](" ~ "lib/" ~ fileName ~ ")\n";

            generatedText ~= line;
        }
        std.file.write(buildNormalizedPath("docs", "_sidebar.md"), generatedText);
    }
}
