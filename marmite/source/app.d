import std.stdio;

import std.exception;
import std.path, std.file;

import magia, grimoire;

void main(string[] args) {
    writeln("Marmite est en train de mijoter");
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }

    try {
        _compileScript("assets", GrLocale.fr_FR);
    } catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}

enum Alchimie_Version = 0;

enum Alchimie_InitScript = "test_marmite";

enum Alchimie_ScriptExt = "gr";

enum Alchimie_BootExt = "alchimie";

enum Alchimie_ScriptDir = "script";

enum Alchimie_ExportDir = "export";

private void _compileScript(string path, GrLocale locale) {
    const string scriptFile = buildNormalizedPath(path, Alchimie_ScriptDir,
        setExtension(Alchimie_InitScript, Alchimie_ScriptExt));

    GrLibrary stdLib = grLoadStdLibrary();
    //GrLibrary alchimieLib = loadAlchimieLibrary();

    GrCompiler compiler = new GrCompiler(Alchimie_Version);
    compiler.addLibrary(stdLib);
    //compiler.addLibrary(alchimieLib);

    compiler.addFile(scriptFile);

    GrBytecode bytecode = compiler.compile(GrOption.safe | GrOption.symbols, locale);
    enforce(bytecode, compiler.getError().prettify(locale));

    writeln(bytecode.prettify());
    foreach (opcode; bytecode.opcodes) {
        txt ~= parse(opcode);
    }
    //string txt;
    //std.file.write("gen.d", txt);
}

struct Token {
    
}

void generateToken(uint opcode) {
    final switch (opcode & 0xFF) with (GrOpcode) {
    case nop:
        break;
    case throw_:
        break;
    case try_:
        break;
    case catch_:
        break;
    case die:
        break;
    case exit:
        break;
    case yield:
        break;
    case task:
        break;
    case anonymousTask:
        break;
    case new_:
        break;
    case channel:
        break;
    case send:
        break;
    case receive:
        break;
    case startSelectChannel:
        break;
    case endSelectChannel:
        break;
    case tryChannel:
        break;
    case checkChannel:
        break;
    case shiftStack:
        break;
    case localStore:
        break;
    case localStore2:
        break;
    case localLoad:
        break;
    case globalStore:
        break;
    case globalStore2:
        break;
    case globalLoad:
        break;
    case refStore:
        break;
    case refStore2:
        break;
    case fieldRefStore:
        break;
    case fieldRefLoad:
        break;
    case fieldRefLoad2:
        break;
    case fieldLoad:
        break;
    case fieldLoad2:
        break;
    case parentStore:
        break;
    case parentLoad:
        break;
    case const_int:
        break;
    case const_uint:
        break;
    case const_byte:
        break;
    case const_float:
        break;
    case const_double:
        break;
    case const_bool:
        break;
    case const_string:
        break;
    case const_meta:
        break;
    case const_null:
        break;
    case globalPush:
        break;
    case globalPop:
        break;
    case equal_int:
        break;
    case equal_uint:
        break;
    case equal_byte:
        break;
    case equal_float:
        break;
    case equal_double:
        break;
    case equal_string:
        break;
    case notEqual_int:
        break;
    case notEqual_uint:
        break;
    case notEqual_byte:
        break;
    case notEqual_float:
        break;
    case notEqual_double:
        break;
    case notEqual_string:
        break;
    case greaterOrEqual_int:
        break;
    case greaterOrEqual_uint:
        break;
    case greaterOrEqual_byte:
        break;
    case greaterOrEqual_float:
        break;
    case greaterOrEqual_double:
        break;
    case lesserOrEqual_int:
        break;
    case lesserOrEqual_uint:
        break;
    case lesserOrEqual_byte:
        break;
    case lesserOrEqual_float:
        break;
    case lesserOrEqual_double:
        break;
    case greater_int:
        break;
    case greater_uint:
        break;
    case greater_byte:
        break;
    case greater_float:
        break;
    case greater_double:
        break;
    case lesser_int:
        break;
    case lesser_uint:
        break;
    case lesser_byte:
        break;
    case lesser_float:
        break;
    case lesser_double:
        break;
    case checkNull:
        break;
    case optionalTry:
        break;
    case optionalOr:
        break;
    case optionalCall:
        break;
    case optionalCall2:
        break;
    case and_int:
        break;
    case or_int:
        break;
    case not_int:
        break;
    case concatenate_string:
        break;
    case add_int:
        break;
    case add_uint:
        break;
    case add_byte:
        break;
    case add_float:
        break;
    case add_double:
        break;
    case substract_int:
        break;
    case substract_uint:
        break;
    case substract_byte:
        break;
    case substract_float:
        break;
    case substract_double:
        break;
    case multiply_int:
        break;
    case multiply_uint:
        break;
    case multiply_byte:
        break;
    case multiply_float:
        break;
    case multiply_double:
        break;
    case divide_int:
        break;
    case divide_uint:
        break;
    case divide_byte:
        break;
    case divide_float:
        break;
    case divide_double:
        break;
    case remainder_int:
        break;
    case remainder_uint:
        break;
    case remainder_byte:
        break;
    case remainder_float:
        break;
    case remainder_double:
        break;
    case negative_int:
        break;
    case negative_float:
        break;
    case negative_double:
        break;
    case increment_int:
        break;
    case increment_uint:
        break;
    case increment_byte:
        break;
    case increment_float:
        break;
    case increment_double:
        break;
    case decrement_int:
        break;
    case decrement_uint:
        break;
    case decrement_byte:
        break;
    case decrement_float:
        break;
    case decrement_double:
        break;
    case copy:
        break;
    case swap:
        break;
    case setupIterator:
        break;
    case localStack:
        break;
    case call:
        break;
    case address:
        break;
    case closure:
        break;
    case anonymousCall:
        break;
    case primitiveCall:
        break;
    case safePrimitiveCall:
        break;
    case return_:
        break;
    case unwind:
        break;
    case defer:
        break;
    case jump:
        break;
    case jumpEqual:
        break;
    case jumpNotEqual:
        break;
    case list:
        break;
    case length_list:
        break;
    case index_list:
        break;
    case index2_list:
        break;
    case index3_list:
        break;
    case concatenate_list:
        break;
    case append_list:
        break;
    case prepend_list:
        break;
    case equal_list:
        break;
    case notEqual_list:
        break;
    case debugProfileBegin:
        break;
    case debugProfileEnd:
        break;
    }
}
