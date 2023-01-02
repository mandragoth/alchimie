module app;

import std.stdio;

import magia.core.vec;
import magia.common.application;

void main() {
    try {
        currentApplication = new Application(vec2u(800, 800), "Sorcier");
        //currentApplication.setIcon("logo.png");
        currentApplication.run();
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}