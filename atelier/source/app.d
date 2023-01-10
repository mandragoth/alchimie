module app;

import std.stdio;

import magia.core.vec;
import magia.common.application;

void main() {
	try {
        currentApplication = new Application(vec2u(1280, 720), "Atelier");
        //application.setIcon("logo.png");
        currentApplication.run();
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}