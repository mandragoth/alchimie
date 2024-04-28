module alma.script.scommon;

import grimoire;

package void loadAlchimieLibCommon(GrModule library) {
    library.addEnum("Spline", [
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