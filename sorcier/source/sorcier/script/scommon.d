module sorcier.script.scommon;

import grimoire;

package void loadAlchimieLibCommon(GrLibDefinition library) {
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grFloat, grFloat, grFloat, grFloat]);
    GrType mat4Type = library.addNative("mat4");
    GrType splineType = library.addEnum("Spline", [
            "linear",
            "sineIn",
            "sineOut",
            "sineInOut",
            "quadIn",
            "quadOut",
            "quadInOut",
            "cubicIn",
            "cubicOut",
            "cubicInOut",
            "quartIn",
            "quartOut",
            "quartInOut",
            "quintIn",
            "quintOut",
            "quintInOut",
            "expIn",
            "expOut",
            "expInOut",
            "circIn",
            "circOut",
            "circInOut",
            "backIn",
            "backOut",
            "backInOut",
            "elasticIn",
            "elasticOut",
            "elasticInOut",
            "bounceIn",
            "bounceOut",
            "bounceInOut"]);
}