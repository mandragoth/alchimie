module magia.script.core.spline;

import grimoire;
import magia.core;

package void loadLibCore_spline(GrModule mod) {
    mod.setModule("common.spline");
    mod.setModuleInfo(GrLocale.fr_FR, "Courbes d’accélération.
Des exemples de ces fonctions sont visibles sur [ce site](https://easings.net/fr).");

    mod.setDescription(GrLocale.fr_FR, "Décrit une fonction d’accélération");
    GrType splineType = mod.addEnum("Spline", grNativeEnum!Spline());

    mod.setDescription(GrLocale.fr_FR, "Applique une courbe d’acccélération.
`value` doit être compris entre 0 et 1.
La fonction retourne une valeur entre 0 et 1.");
    mod.setParameters(["value", "spline"]);
    mod.addFunction(&_ease, "ease", [grFloat, splineType], [grFloat]);
}

private void _ease(GrCall call) {
    SplineFunc easeFunc = getSplineFunc(call.getEnum!Spline(1));
    call.setFloat(easeFunc(call.getFloat(0)));
}
