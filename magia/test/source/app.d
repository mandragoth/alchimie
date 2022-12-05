import std.stdio;

import std.datetime, core.thread;

import magia;

private {
    float _deltatime = 1f;
    float _currentFps;
    long _tickStartFrame;
}

void main() {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    try {
        runApplication();
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}

/// Lance l’application
void runApplication() {
    createWindow(Vec2u(800, 800), "Magia - Test");
    initializeEvents();
    _tickStartFrame = Clock.currStdTime();

    initFont();

    initializeScene();

    initUI();

    test();

    while (processEvents()) {
        // Màj
        updateEvents(_deltatime);

        if (getButtonDown(KeyButton.escape)) {
            stopApplication();
            return;
        }

        updateScene(_deltatime);
        updateUI(_deltatime);

        // Rendu
        // 3D
        setup3DRender();
        drawScene();

        // 2D
        setup2DRender();
        drawUI();

        renderWindow();

        // IPS
        long deltaTicks = Clock.currStdTime() - _tickStartFrame;
        if (deltaTicks < (10_000_000 / getNominalFPS()))
            Thread.sleep(dur!("hnsecs")((10_000_000 / getNominalFPS()) - deltaTicks));

        deltaTicks = Clock.currStdTime() - _tickStartFrame;
        _deltatime = (cast(float)(deltaTicks) / 10_000_000f) * getNominalFPS();
        _currentFps = (_deltatime == .0f) ? .0f : (10_000_000f / cast(float)(deltaTicks));
        _tickStartFrame = Clock.currStdTime();
    }
}

void test() {
    Label label = new Label("Bonjour !");
    appendRoot(label);
}
