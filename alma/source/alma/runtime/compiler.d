module alma.runtime.compiler;

import std.exception;

import magia, grimoire;

import alma.common, alma.script;

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

GrBytecode compileSource(string inputFile, int options, GrLocale locale) {
    GrCompiler compiler = new GrCompiler(Alma_Version_ID);

    foreach (GrLibrary lib; getLibraries()) {
        compiler.addLibrary(lib);
    }

    compiler.addFile(inputFile);

    GrBytecode bytecode = compiler.compile(options, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    return bytecode;
}
