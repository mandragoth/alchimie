module sorcier.runtime.compiler;

import std.exception;

import magia, grimoire;

import sorcier.common, sorcier.script;

private {
    bool _areLibLoaded;
    GrLibrary[] _libraries;
}

private void loadLibraries() {
    if (_areLibLoaded)
        return;

    _libraries ~= grLoadStdLibrary();
    _libraries ~= loadAlchimieLibrary();
    _areLibLoaded = true;
}

GrLibrary[] getLibraries() {
    loadLibraries();
    return _libraries;
}

GrBytecode compileSource(string inputFile, GrLocale locale) {
    GrCompiler compiler = new GrCompiler(Sorcier_Version);

    foreach (GrLibrary lib; getLibraries()) {
        compiler.addLibrary(lib);
    }

    compiler.addFile(inputFile);

    GrBytecode bytecode = compiler.compile(
        GrOption.profile | GrOption.safe | GrOption.symbols, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    return bytecode;
}

GrBytecode compileSource(string inputFile, string outputFile, GrLocale locale) {
    GrCompiler compiler = new GrCompiler(Sorcier_Version);

    foreach (GrLibrary lib; getLibraries()) {
        compiler.addLibrary(lib);
    }

    compiler.addFile(inputFile);

    GrBytecode bytecode = compiler.compile(GrOption.none, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    bytecode.save(outputFile);

    return bytecode;
}
