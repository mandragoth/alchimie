module magia.script.kernel.runtime;

import grimoire;
import magia.kernel;
import magia.render;
import magia.script.common;

package void loadLibCore_runtime(GrModule mod) {
    mod.setModule("kernel.runtime");
    mod.setModuleInfo(GrLocale.fr_FR, "Informations système");

    GrType appType = mod.addNative("App");

    GrType vec2fType = grGetNativeType("vec2", [grFloat]);
    GrType vec2iType = grGetNativeType("vec2", [grInt]);
/*
    mod.setDescription(GrLocale.fr_FR, "Algorithme de mise à l’échelle (voir: setScaling)");
    GrType scalingType = mod.addEnum("Scaling", grNativeEnum!(Renderer.Scaling)());

    mod.setDescription(GrLocale.fr_FR, "La largeur en pixel de l’écran.");
    mod.addStatic(&_width, appType, "width", [], [grInt]);

    mod.setDescription(GrLocale.fr_FR, "La hauteur en pixel de l’écran.");
    mod.addStatic(&_height, appType, "height", [], [grInt]);

    mod.setDescription(GrLocale.fr_FR, "La taille en pixel de l’écran.");
    mod.addStatic(&_size, appType, "size", [], [vec2iType]);

    mod.setDescription(GrLocale.fr_FR, "Les coordonnées du centre de l’écran.
Égal à `@App.size() / 2`.");
    mod.addStatic(&_center, appType, "center", [], [vec2iType]);
*/
    mod.setDescription(GrLocale.fr_FR,
        "Renvoie `true` si l’application est en mode exporté, `false` en mode développement.");
    mod.addStatic(&_isRedist, appType, "isRedist", [], [grBool]);
/*
    mod.setDescription(GrLocale.fr_FR, "Facteur de netteté des pixels.
Plus cette valeur est grande, plus la qualité est grande mais plus le jeu sera gourmand en ressources graphiques.
Le canvas du jeu de base est d’abord multiplié par ce facteur, avant de passer à l’algorithme de mise à l’échelle.
Exemple:
    Un jeu qui a un canvas de 640×360 et un facteur de netteté de 2 sera rendu avec une résolution de 1280×720
    avant d’être mise à l’échelle de la fenêtre grace à la méthode de `setScaling`.");
    mod.setParameters(["sharpness"]);
    mod.addStatic(&_setPixelSharpness, appType, "setPixelSharpness", [grUInt]);

    mod.setDescription(GrLocale.fr_FR, "Applique un algorithme de mise à l’échelle.
- **Scaling.none**: aucun redimensionnement
- **Scaling.integer**: seul le facteur de `setPixelSharpness` est appliqué
- **Scaling.fit**: comme `integer`, puis mise à l’échelle de la fenêtre en respectant le ratio largeur/hauteur de l’écran. Peut induire des bandes noires sur les côtés.
- **Scaling.contain**: comme `fit`, mais en dépassant de la fenêtre afin d’éviter les bandes noires.
- **Scaling.stretch**: comme `integer`, puis redimensionnement à la taille de la fenêtre sans respecter le ratio");
    mod.setParameters(["scaling"]);
    mod.addStatic(&_setScaling, appType, "setScaling", [scalingType]);
*/
    mod.setDescription(GrLocale.fr_FR, "(En mode développement seulement) Relance l’application.
- `reloadResources` recharge les dossiers de ressources.
- `reloadScript` recompile le programme.");
    mod.setParameters(["reloadResources", "reloadScript"]);
    mod.addStatic(&_reload, appType, "reload", [grBool, grBool]);

    mod.setDescription(GrLocale.fr_FR, "Ferme l’application.");
    mod.setParameters();
    mod.addStatic(&_close, appType, "close");
}
/*
private void _width(GrCall call) {
    call.setInt(Magia.renderer.size.x);
}

private void _height(GrCall call) {
    call.setInt(Magia.renderer.size.y);
}

private void _size(GrCall call) {
    call.setNative(svec2(Magia.renderer.size));
}

private void _center(GrCall call) {
    call.setNative(svec2(Magia.renderer.center));
}

private void _setPixelSharpness(GrCall call) {
    Magia.renderer.setPixelSharpness(call.getUInt(0));
}

private void _setScaling(GrCall call) {
    Magia.renderer.setScaling(call.getEnum!(Renderer.Scaling)(0));
}
*/
private void _isRedist(GrCall call) {
    call.setBool(Magia.isRedist());
}

private void _reload(GrCall call) {
    Magia.reload(call.getBool(0), call.getBool(1));
}

private void _close(GrCall call) {
    Magia.close();
}
