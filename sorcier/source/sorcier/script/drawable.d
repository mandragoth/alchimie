module sorcier.script.drawable;

import grimoire;

import gl3n.linalg;

import magia.core, magia.render, magia.shape;

import std.stdio;

/// Dirty
class MatWrapper {
    /// As heck
    mat4 matrix;

    /// Constructor
    this(mat4 matrix_) {
        matrix = matrix_;
    }
}

void loadMagiaLibDrawable(GrLibrary library) {
    GrType vec3Type = grGetClassType("vec3");
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [
            grFloat, grFloat, grFloat, grFloat
        ]);
    GrType mat4Type = library.addNative("mat4");

    GrType entityType = library.addNative("Entity");
    GrType lightType = library.addNative("Light", [], "Entity");
    GrType modelType = library.addNative("Model", [], "Entity");
    GrType lineType = library.addNative("Line", [], "Entity");
    GrType quadType = library.addNative("Quad", [], "Entity");
    GrType planetType = library.addNative("Planet", [], "Entity");
    GrType skyboxType = library.addNative("Skybox", [], "Entity");
    GrType terrainType = library.addNative("Terrain", [], "Entity");

    GrType lightEnumType = library.addEnum("LightKind", [
            "DIRECTIONAL", "POINT", "SPOT"
        ]);

    library.addFunction(&_quat, "quat", [grFloat, grFloat, grFloat, grFloat], [
            quatType
        ]);
    library.addFunction(&_position1, "position", [
            entityType, grFloat, grFloat, grFloat
        ], []);
    library.addFunction(&_position2, "position", [entityType, vec3Type], []);
    library.addFunction(&_scale1, "scale", [
            entityType, grFloat, grFloat, grFloat
        ], []);
    library.addFunction(&_scale2, "scale", [entityType, vec3Type], []);
    library.addFunction(&_packInstanceMatrix, "packInstanceMatrix", [
            vec3Type, quatType, vec3Type
        ], [mat4Type]);
    library.addFunction(&_light, "loadLight", [lightEnumType], [lightType]);
    library.addFunction(&_model1, "loadModel", [grString], [modelType]);
    library.addFunction(&_model2, "loadModel", [
            grString, grInt, grList(mat4Type)
        ], [modelType]);
    library.addFunction(&_quad, "loadQuad", [], [quadType]);
    library.addFunction(&_planet, "loadPlanet", [
            grInt, grFloat, vec3Type, grInt, grFloat, grFloat, grFloat, grFloat
        ], [planetType]);
    library.addFunction(&_line, "loadLine", [vec3Type, vec3Type, vec3Type], [
            lineType
        ]);
    library.addFunction(&_skybox, "loadSkybox", [], [skyboxType]);
    library.addFunction(&_terrain, "loadTerrain", [
            grInt, grInt, grInt, grInt, grInt, grInt
        ], [terrainType]);
}

private void _quat(GrCall call) {
    GrObject q = call.createObject("quat");
    q.setFloat("w", call.getFloat(0));
    q.setFloat("x", call.getFloat(1));
    q.setFloat("y", call.getFloat(2));
    q.setFloat("z", call.getFloat(3));
    call.setObject(q);
}

private void _position1(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    instance.transform.position = vec3(call.getFloat(1), call.getFloat(2), call.getFloat(3));
}

private void _position2(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    GrObject position = call.getObject(1);
    instance.transform.position = vec3(position.getFloat("x"),
        position.getFloat("y"), position.getFloat("z"));
}

private void _scale1(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    instance.transform.position = vec3(call.getFloat(1), call.getFloat(2), call.getFloat(3));
}

private void _scale2(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    GrObject scale = call.getObject(1);
    instance.transform.scale = vec3(scale.getFloat("x"), scale.getFloat("y"), scale.getFloat("z"));
}

private void _packInstanceMatrix(GrCall call) {
    GrObject positionObj = call.getObject(0);
    GrObject rotationObj = call.getObject(1);
    GrObject scaleObj = call.getObject(2);

    vec3 position = vec3(positionObj.getFloat("x"), positionObj.getFloat("y"),
        positionObj.getFloat("z"));
    quat rotation = quat(rotationObj.getFloat("w"), rotationObj.getFloat("x"),
        rotationObj.getFloat("y"), rotationObj.getFloat("z"));
    vec3 scale = vec3(scaleObj.getFloat("x"), scaleObj.getFloat("y"), scaleObj.getFloat("z"));
    mat4 instanceMatrix = combineModel(position, rotation, scale);

    MatWrapper wrapper = new MatWrapper(instanceMatrix);
    call.setNative(wrapper);
}

private void _light(GrCall call) {
    LightInstance lightInstance = new LightInstance(call.getEnum!LightType(0));
    call.setNative(lightInstance);
    setGlobalLight(lightInstance);
}

private void _model1(GrCall call) {
    ModelInstance modelInstance = new ModelInstance(call.getString(0));
    call.setNative(modelInstance);
    addEntity(modelInstance);
}

private void _model2(GrCall call) {
    GrList list = call.getList(2);

    mat4[] matrices;
    foreach (const MatWrapper matWrapper; list.getNatives!MatWrapper) {
        matrices ~= matWrapper.matrix;
    }

    ModelInstance modelInstance = new ModelInstance(call.getString(0), call.getInt(1), matrices);
    call.setNative(modelInstance);
    addEntity(modelInstance);
}

private void _line(GrCall call) {
    GrObject startObj = call.getObject(0);
    GrObject endObj = call.getObject(1);
    GrObject colorObj = call.getObject(2);

    const vec3 start = vec3(startObj.getFloat("x"), startObj.getFloat("y"),
        startObj.getFloat("z"));
    const vec3 end = vec3(endObj.getFloat("x"), endObj.getFloat("y"), endObj.getFloat("z"));
    const vec3 color = vec3(colorObj.getFloat("x"), colorObj.getFloat("y"),
        colorObj.getFloat("z"));

    Line line = new Line(start, end, color);
    call.setNative(line);
    addLine(line);
}

private void _quad(GrCall call) {
    QuadInstance quadInstance = new QuadInstance();
    call.setNative(quadInstance);
    addEntity(quadInstance);
}

private void _planet(GrCall call) {
    const int resolution = call.getInt(0);
    const float radius = call.getFloat(1);

    GrObject offset = call.getObject(2);
    const vec3 noiseOffset = vec3(offset.getFloat("x"), offset.getFloat("y"),
        offset.getFloat("z"));

    const int nbLayers = call.getInt(3);
    const float strength = call.getFloat(4);
    const float roughness = call.getFloat(5);
    const float persistence = call.getFloat(6);
    const float minHeight = call.getFloat(7);

    Planet planet = new Planet(resolution, radius, noiseOffset, nbLayers,
        strength, roughness, persistence, minHeight);
    //Sphere planet = new Sphere(resolution, radius);
    call.setNative(planet);
    addEntity(planet);
}

private void _skybox(GrCall call) {
    Skybox skybox = new Skybox(getCamera());
    call.setNative(skybox);
    setSkybox(skybox);
}

private void _terrain(GrCall call) {
    const int gridX = call.getInt(0);
    const int gridZ = call.getInt(1);
    const int sizeX = call.getInt(2);
    const int sizeZ = call.getInt(3);
    const int nbVertices = call.getInt(4);
    const int tiling = call.getInt(5);

    Terrain terrain = new Terrain(vec2(gridX, gridZ), vec2(sizeX, sizeZ), nbVertices, tiling);
    call.setNative(terrain);
    setTerrain(terrain);
}
