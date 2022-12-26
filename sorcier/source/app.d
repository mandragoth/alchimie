module app;

import std.stdio;

import magia.core.vec;
import magia.common.application;

void main() {
    try {
        _currentApplication = new Application(vec2u(800, 800), "Sorcier");
        //application.setIcon("logo.png");
        _currentApplication.run();
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}