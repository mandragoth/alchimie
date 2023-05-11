module sorcier.cli.exporter;

import std.exception, std.path;

import grimoire, magia;

import sorcier.common, sorcier.script;

void exportProject(string path, string name, GrLocale locale) {
    _compileScript(path, name, locale);
    _compileRessource(path, locale);
}

private void _compileScript(string path, string name, GrLocale locale) {
    const string scriptFile = buildNormalizedPath(path, Alchimie_ScriptDir,
        setExtension(Alchimie_InitScript, Alchimie_ScriptExt));
    const string bootFile = buildNormalizedPath(path, Alchimie_ExportDir,
        setExtension(name, Alchimie_BootExt));

    GrLibrary stdLib = grLoadStdLibrary();
    GrLibrary alchimieLib = loadAlchimieLibrary();

    GrCompiler compiler = new GrCompiler(Alchimie_Version);
    compiler.addLibrary(stdLib);
    compiler.addLibrary(alchimieLib);

    compiler.addFile(scriptFile);

    GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.symbols, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    bytecode.save(bootFile);
}

private void _compileRessource(string path, GrLocale locale) {

}
