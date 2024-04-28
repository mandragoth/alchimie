module magia.kernel.loader.shader;

import farfadet;
import magia.core;
import magia.render;
import magia.kernel.runtime;

/// Crée une ressource shader
package void compileShader(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
}

package void loadShader(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Magia.res.store(rid, { return new Shader(filePath); });
}
