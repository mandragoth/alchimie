module magia.render.command;

import magia.core.color;
import magia.core.transform;
import magia.render.array;
import magia.render.renderer;
import magia.render.shader;

/// Render command
class Command {
    /// Renderer
    static Renderer renderer;

    /// Setup clear color
    static void setClearColor(Color color) {
        renderer.backgroundColor = color;
    }

    /// Clear rendered frame
    static void clear() {
        renderer.clear();
    }

    /// Draw an indexed vertex array
    static void submit(const Shader shader, const VertexArray vertexArray, const Transform transform) {
        shader.activate();
        //shader.uploadUniformMat4("");

        renderer.drawIndexed(vertexArray);
    }
}