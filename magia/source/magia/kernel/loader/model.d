module magia.kernel.loader.model;

import farfadet;
import magia.core;
import magia.render;
import magia.kernel.runtime;

/// Crée un modèle
package void compileModel(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
}

package void loadModel(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Magia.res.store(rid, {
        Model model = new Model(filePath);
        return model;
    });
}
