module app;

import std.stdio;

import std.algorithm.mutation : remove;
import std.conv : to;

import magia, grimoire;

import sorcier.script, sorcier.cli, sorcier.common;

private {
    float _deltatime = 1f;
    float _currentFps;
    long _tickStartFrame;

    GrEngine _engine;
    GrLibrary _stdlib;
    GrLibrary _magialib;
}

void main(string[] args) {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    try {
        version (AlchimieDist) {
            bootUp(args);
        }
        else {
            parseArguments(args);
        }
    }
    catch (Exception e) {
        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}