module magia.script.sbullet;

import grimoire;
import magia.core;
import magia.kernel;
import magia.render;
import magia.script.common;

package void loadAlchimieLibBullet(GrModule library) {
    // Maths types
    GrType vec2Type = grGetNativeType("vec2", [grFloat]);

    // Bullet types
    GrType bulletType = library.addNative("Bullet");

    // Bullet constructors
    library.addConstructor(&_newBullet, bulletType, [grString, vec2Type, grFloat, grFloat]);
}

private void _newBullet(GrCall call) {
    Sprite sprite = Magia.res.get!Sprite(call.getString(0));
    vec2f position = cast(vec2f) call.getNative!SVec2f(1);
    float speed = call.getFloat(2);
    float angle = call.getFloat(3);

    Bullet bullet = new Bullet(sprite, position, speed, angle * degToRad);
    Magia.addDrawable(bullet);
    Magia.addUpdatable(bullet);

    call.setNative(bullet);
}