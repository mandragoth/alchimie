module magia.kernel.loader.sprite;

import farfadet;
import magia.core;
import magia.render;
import magia.kernel.runtime;

/// Crée des sprites
package void compileSprite(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["texture", "clip"]);
    string textureRID = ffd.getNode("texture", 1).get!string(0);

    vec4u clip;
    Farfadet clipNode = ffd.getNode("clip", 4);
    clip.x = clipNode.get!uint(0);
    clip.y = clipNode.get!uint(1);
    clip.z = clipNode.get!uint(2);
    clip.w = clipNode.get!uint(3);

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!vec4u(clip);
}

package void loadSprite(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    vec4u clip = stream.read!vec4u();

    Magia.res.store(rid, {
        Texture texture = Magia.res.get!Texture(textureRID);
        SpritePool spritePool = Magia.res.get!SpritePool(textureRID);
        Sprite sprite = new Sprite(texture, spritePool, clip);
        return sprite;
    });
}
