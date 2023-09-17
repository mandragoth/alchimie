import std.stdio;

import std.algorithm.mutation : remove;
import std.conv : to;
import std.exception : enforce;

import magia, grimoire;

import sorcier.script, sorcier.common, sorcier.runtime;

/// Configuration du ramasse-miettes
extern (C) __gshared string[] rt_options = [
	"gcopt=initReserve:128 minPoolSize:256 parallel:2 profile:0"
];

void main(string[] args) {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    try {
        if (!args.length)
            return;

        version (SorcierDev) {
            string exePath = args[0];
            string exeDir = dirName(exePath);
            string exeName = stripExtension(baseName(exePath));

            args = args[1 .. $];

            if (!args.length) {
                writeln("sorcierdev v0");
                return;
            }

            switch (args[0]) {
            case "-c":
                if (!args.length) {
                    writeln("sorcierdev -c <fichier> [bytecode]");
                    return;
                }
                string inputFile = args[2];
                string outputFile = setExtension(stripExtension(inputFile), ".grb");
                args = args[1 .. $];

                if (args.length) {
                    outputFile = args[3];
                    args = args[1 .. $];
                }

                if (inputFile == outputFile) {
                    writeln("Erreur: le fichier d’entrée et de sortie sont identique");
                }

                _compileScript(inputFile, outputFile, GrLocale.fr_FR);
                break;
            case "-l":
                if (!args.length) {
                    writeln("sorcierdev -c <fichier> [bytecode]");
                    return;
                }
                string filePath = args[2];
                args = args[1 .. $];

                Runtime rt = new Runtime(filePath);
                rt.run();
                break;
            default:
                writeln("mauvais argument");
                return;
            }
        } else version (SorcierDebug) {
            string filePath = "assets/script/main.gr";

            Runtime rt = new Runtime(filePath);
            rt.run();
        } else {
            string filePath;
            if (args.length) {
                string exePath = args[0];
                args = args[1 .. $];
                string exeDir = dirName(exePath);
                string exeName = stripExtension(baseName(exePath));

                filePath = buildNormalizedPath(exeDir, setExtension(exeName, Sorcier_GrimoireCompiledExt));
            } else {
                filePath = setExtension("boot", Sorcier_GrimoireCompiledExt);
            }

            Runtime rt = new Runtime(filePath);
            rt.run();
        }
    } catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}

private void _compileScript(string inputFile, string outputFile, GrLocale locale) {
    /*const string scriptFile = buildNormalizedPath(path, Alchimie_ScriptDir,
        setExtension(Alchimie_InitScript, Sorcier_GrimoireSourceExt));
    const string bootFile = buildNormalizedPath(path, Alchimie_ExportDir,
        setExtension(name, Sorcier_GrimoireCompiledExt));*/

    GrLibrary stdLib = grLoadStdLibrary();
    GrLibrary alchimieLib = loadAlchimieLibrary();

    GrCompiler compiler = new GrCompiler(Sorcier_Version);
    compiler.addLibrary(stdLib);
    compiler.addLibrary(alchimieLib);

    compiler.addFile(inputFile);

    GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.symbols, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    bytecode.save(outputFile);
}
