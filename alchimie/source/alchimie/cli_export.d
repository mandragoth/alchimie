module alchimie.cli_export;

import std.exception;
import std.path;

import magia;

void cliExport(Cli.Result cli) {
    //_compileScript(path, name, locale);
    //_compileRessource(path, locale);
}
/*
private void _compileScript(string path, string name, GrLocale locale) {
    const string scriptFile = buildNormalizedPath(path, Alchimie_ScriptDir,
        setExtension(Alchimie_InitScript, Sorcier_GrimoireSourceExt));
    const string bootFile = buildNormalizedPath(path, Alchimie_ExportDir,
        setExtension(name, Sorcier_GrimoireCompiledExt));

    GrLibrary stdLib = grLoadStdLibrary();
    GrLibrary alchimieLib = loadAlchimieLibrary();

    GrCompiler compiler = new GrCompiler(Sorcier_Version);
    compiler.addLibrary(stdLib);
    compiler.addLibrary(alchimieLib);

    compiler.addFile(scriptFile);

    GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.symbols, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    bytecode.save(bootFile);
}

private void _compileRessource(string path, GrLocale locale) {

}
*/