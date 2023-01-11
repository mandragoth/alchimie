module magia.main.magia;

import magia.core, magia.input, magia.ui, magia.render;

/// Le moteur Magia
final class Magia {
    private {
        Input _input;
        UI _ui;
    }

    @property {
        /// Est-ce que magia tourne toujours ?
        bool isRunning() const {
            return !_input.hasQuit();
        }

        /// Module d’entrées
        Input input() {
            return _input;
        }

        /// Module d’interface
        UI ui() {
            return _ui;
        }
    }

    /// Init
    this(vec2u windowSize, string title) {
        createWindow(windowSize, title);

        _input = new Input;
        _ui = new UI;

        initFont();
        initializeScene();
    }

    /// Récupère les événements (clavier/souris/manette/etc)
    /// et les événements de la fenêtre (redimmensionnement/glisser-déposer/etc)
    /// et les redistribue sous forme d’InputEvent
    InputEvent[] pollEvents() {
        return _input.pollEvents();
    }

    /// Mise à jour des événements, de l’ui et de la scène
    void update(float deltatime) {
        updateScene(deltatime);
        _ui.update(deltatime);
    }

    /// Rendu de la fenêtre
    void render() {
        // 3D
        setup3DRender();
        drawScene(); /// @ERROR: crash ici quand le script ne compile pas

        // 2D
        setup2DRender();
        _ui.draw();

        renderWindow();
    }
}
