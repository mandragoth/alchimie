module magia.render.model;

import std.algorithm;
import std.array;
import std.base64;
import std.conv;
import std.file;
import std.format;
import std.json;
import std.path;
import std.stdio;
import std.string;
import std.typecons;

import bindbc.opengl;

import magia.core;
import magia.render.animation;
import magia.render.buffer;
import magia.render.camera;
import magia.render.data;
import magia.render.entity;
import magia.render.joint;
import magia.render.material;
import magia.render.mesh;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;
import magia.render.window;

/// Default uint value
enum uint uintDefault = -1;

private {
    // File to debug + should we trace deep layers?
    string s_DebugFile = "rigged.gltf";
    bool s_TraceDeep = false;
    bool s_TraceData = false;
}

/// Class handling model data and draw call
final class Model {
    /// Component POD type
    enum ComponentType {
        byte_t = 5120,
        ubyte_t = 5121,
        short_t = 5122,
        ushort_t = 5123,
        uint_t = 5125,
        float_t = 5126
    }

    private {
        // JSON data
        ubyte[][] _data;
        JSONValue _json;

        // Material data
        Material _material;

        // Mesh data
        Mesh[] _meshes;

        // Raw vertex data
        Vertex[] _vertices;

        // Raw animated vertex data
        AnimatedVertex[] _animatedVertices;

        // Transformations
        Transform3D[] _transforms;

        // Bones
        Bone[uint] _bones;

        // Animations
        Animation[uint] _animations;

        // Directory
        string _fileDirectory;

        // Trace mechanism
        bool _trace;
        bool _traceDeep;
        bool _traceData;
        bool _traceNormals;
    }

    @property {
        /// Number of bones for the model instance
        int nbBones() {
            return cast(int)_bones.length;
        }
    }

    /// Constructor
    this(string fileName) {
        if (baseName(fileName) == s_DebugFile) {
            _trace = false;
            _traceDeep = s_TraceDeep;
            _traceData = s_TraceData;
        }

        // Initialize material
        _material = new Material();

        // Fetch file data into buffers
        parseFileData(fileName);

        // Fetch root nodes from scenes
        JSONValue scenes = _json["scenes"][0];
        int[] nodes = getJsonArrayInt(scenes, "nodes", []);

        // Traverse all scene nodes
        foreach (int nodeId; nodes) {
            traverseNode(nodeId);
        }

        // @TODO once fixed, uncomment
        if (_trace) {
            //traceMeshData();
            traceBoneData();
        }

        JSONValue[] jsonAnimations = getJsonArray(_json, "animations");

        // Load all animations
        foreach (JSONValue jsonAnimation; jsonAnimations) {
            loadAnimation(jsonAnimation);
        }
    }

    /// Copy constructor
    this(Model other) {
        _data = other._data;
        _json = other._json;
        _material = other._material;
        _meshes = other._meshes;
        _vertices = other._vertices;
        _transforms = other._transforms;
        _bones = other._bones;
        _animations = other._animations;
        _fileDirectory = other._fileDirectory;
    }

    /// Draw the model (by default with its preloaded material)
    void draw(Shader shader, Material material, Transform3D transform) {
        // Model culling is the opposite of usual objects
        glCullFace(GL_BACK);

        for (uint meshId = 0; meshId < _meshes.length; ++meshId) {
            Transform meshTransform = _transforms[meshId] * transform;
            _meshes[meshId].draw(shader, material, meshTransform);

            if (_traceNormals) {
                _vertices[meshId].drawNormal();
            }
        }

        // Revert to usual culling
        glCullFace(GL_FRONT);
    }

    /// Draw the model (with its preloaded material)
    void draw(Shader shader, Transform3D transform) {
        draw(shader, _material, transform);
    }

    private {
        /// Get data from files and build internal buffers
        void parseFileData(string fileName) {
            _fileDirectory = dirName(fileName);

            if (_trace) {
                writeln("*".replicate(100));
                writeln("Model file path: ", fileName);
            }

            _json = parseJSON(readText(fileName));

            JSONValue[] jsonBuffers = getJsonArray(_json, "buffers");
            _data.length = jsonBuffers.length;

            for (uint bufferId = 0; bufferId < jsonBuffers.length; ++bufferId) {
                string uri = jsonBuffers[bufferId]["uri"].get!string;

                if (canFind(uri, ".bin")) {
                    _data[bufferId] = cast(ubyte[]) read(buildNormalizedPath(_fileDirectory, uri));
                } else {
                    string[] data = uri.split(",");
                    assert(canFind(data[0], "base64"));
                    _data[bufferId] = Base64.decode(data[1]);
                }
            }
        }

        /// Get data from buffers with accessor
        castType[] parseBufferData(castType)(JSONValue accessor) {
            const uint bufferViewId = getJsonInt(accessor, "bufferView", 0);
            const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
            const uint componentType = getJsonInt(accessor, "componentType");
            const uint count = getJsonInt(accessor, "count");
            const string accessorType = getJsonStr(accessor, "type");

            JSONValue bufferView = _json["bufferViews"][bufferViewId];
            const uint bufferId = getJsonInt(bufferView, "buffer");
            const uint bufferByteOffset = getJsonInt(bufferView, "byteOffset", 0);
            const uint bufferByteStride = getJsonInt(bufferView, "byteStride", 0);

            uint nbBytesPerVertex;
            if (accessorType == "SCALAR") {
                nbBytesPerVertex = 1;
            } else if (accessorType == "VEC2") {
                nbBytesPerVertex = 2;
            } else if (accessorType == "VEC3") {
                nbBytesPerVertex = 3;
            } else if (accessorType == "VEC4") {
                nbBytesPerVertex = 4;
            } else if (accessorType == "MAT4") {
                nbBytesPerVertex = 16;
            } else {
                throw new Exception("Unsupported accessor data type " ~ accessorType);
            }

            const uint dataStart = byteOffset + bufferByteOffset;

            final switch(componentType) with (ComponentType) {
            case float_t:
                return parseData!(float, castType)(bufferId, dataStart, bufferByteStride, count, nbBytesPerVertex);
            case uint_t:
                return parseData!(uint, castType)(bufferId, dataStart, bufferByteStride, count, nbBytesPerVertex);
            case ushort_t:
                return parseData!(ushort, castType)(bufferId, dataStart, bufferByteStride, count, nbBytesPerVertex);
            case short_t:
                return parseData!(short, castType)(bufferId, dataStart, bufferByteStride, count, nbBytesPerVertex);
            case ubyte_t:
                return parseData!(ubyte, castType)(bufferId, dataStart, bufferByteStride, count, nbBytesPerVertex);
            case byte_t:
                return parseData!(uint, castType)(bufferId, dataStart, bufferByteStride, count, nbBytesPerVertex);
            }
        }

        /// Parse data
        castType[] parseData(fileType, castType)(uint bufferId, uint dataStart, uint bufferStride, uint count, uint nbBytesPerVertex) {
            // Values array to return
            castType[] values;

            // Size in bytes of internal file type
            const uint fileTypeSize = fileType.sizeof;

            // Size in bytes of an entry = number of values * size of value
            const uint entrySize = nbBytesPerVertex * fileTypeSize;

            // Stride is either buffer view defined or the entry size
            const uint stride = bufferStride ? bufferStride : entrySize;

            // Until what buffer portion shall we iterate?
            const uint dataEnd = dataStart + count * stride;

            uint parsedEntries = 0;
            uint remainingToParse = nbBytesPerVertex;
            for (uint dataId = dataStart; dataId < dataEnd; dataId) {
                ubyte[] bytes;
                for (uint byteId = 0; byteId < fileTypeSize; ++byteId) {
                    bytes ~= _data[bufferId][dataId++];
                }

                // Cast data to fileType, then castType
                fileType value = *cast(fileType*)bytes.ptr;
                values ~= cast(castType) value;

                // Decrement remaining entries to parse
                remainingToParse--;

                // When no more remaining entries, fetch next batch
                if (remainingToParse == 0) {
                    remainingToParse = nbBytesPerVertex;
                    ++parsedEntries;
                    dataId = dataStart + parsedEntries * stride;
                }
            }

            return values;
        }

        /// Group given float array as a vec2
        vec2[] groupFloatsVec2(float[] floats) {
            vec2[] values;
            for (uint i = 0; i < floats.length;) {
                values ~= vec2(floats[i++], floats[i++]);
            }
            return values;
        }

        /// Group given float array as a vec3
        vec3[] groupFloatsVec3(float[] floats) {
            vec3[] values;
            for (uint i = 0; i < floats.length;) {
                values ~= vec3(floats[i++], floats[i++], floats[i++]);
            }
            return values;
        }

        /// Group given float array as a vec4
        vec4[] groupFloatsVec4(float[] inputs) {
            vec4[] values;
            for (uint i = 0; i < inputs.length;) {
                values ~= vec4(inputs[i++], inputs[i++], inputs[i++], inputs[i++]);
            }
            return values;
        }

        /// Group given float array as a quat
        quat[] groupFloatsQuat(float[] inputs) {
            quat[] values;
            for (uint i = 0; i < inputs.length; i += 4) {
                // Gltf format is X, Y, Z, W (internal one is W, X, Y, Z)
                values ~= quat(inputs[i + 3], inputs[i + 1], inputs[i + 2], inputs[i]);
            }
            return values;
        }

        /// Group given GLuint array as vec4i
        vec4i[] groupIntsVec4i(T)(T[] inputs) {
            vec4i[] values;
            for (uint i = 0; i < inputs.length;) {
                values ~= vec4i(inputs[i++], inputs[i++], inputs[i++], inputs[i++]);
            }
            return values;
        }

        /// Group given float array as mat4 (we transpose them because stored column by column)
        mat4[] groupFloatsMat4(float[] floats) {
            mat4[] values;
            for (uint i = 0; i < floats.length;) {
                mat4 value = mat4(floats[i++], floats[i++], floats[i++], floats[i++],
                                  floats[i++], floats[i++], floats[i++], floats[i++],
                                  floats[i++], floats[i++], floats[i++], floats[i++],
                                  floats[i++], floats[i++], floats[i++], floats[i++]);
                values ~= value.transposed();
            }
            return values;
        }

        /// Assemble all vertices
        Vertex[] assembleVertices(vec3[] positions, vec3[] normals, vec2[] texUVs) {
            Vertex[] vertices;
            for (uint i = 0; i < positions.length; ++i) {
                vec3 normal = i < normals.length ? normals[i] : vec3.zero;
                vec2 texUV = i < texUVs.length ? texUVs[i] : vec2.zero;
                vertices ~= Vertex(positions[i], texUV, normal);
            }

            if (_traceData) {
                for (uint i = 0; i < positions.length; ++i) {
                    writefln("    positions[%u]: %s", i, positions[i]);
                }

                for (uint i = 0; i < normals.length; ++i) {
                    writefln("    normals[%u]: %s", i, normals[i]);
                }

                for (uint i = 0; i < texUVs.length; ++i) {
                    writefln("    texUVs[%u]: %s", i, texUVs[i]);
                }
            }

            return vertices;
        }

        /// Assemble all joints
        Joint[] assembleJoints(vec4i[] boneIds, vec4[] weights) {
            assert(boneIds.length == weights.length);

            if (_traceData) {
                for (uint i = 0; i < boneIds.length; ++i) {
                    writefln("    boneIds[%d]: %s", i, boneIds[i]);
                }

                for (uint i = 0; i < weights.length; ++i) {
                    writefln("    weights[%u]: %s", i, weights[i]);
                }
            }

            Joint[] joints;
            for (uint i = 0; i < boneIds.length; ++i) {
                joints ~= Joint(boneIds[i], weights[i]);
            }

            return joints;
        }

        void assembleBones(int[] boneNodeIds, mat4[] boneMatrices) {
            assert(boneMatrices.length == boneNodeIds.length);

            for (uint boneId = 0; boneId < boneMatrices.length; ++boneId) {
                // Get related nodeId
                uint nodeId = boneNodeIds[boneId];

                // Fetch bone name from json
                JSONValue boneNode = _json["nodes"][nodeId];
                string name = getJsonStr(boneNode, "name", "");

                if (_traceDeep) {
                    writefln("    Associating node # %u to bone # %u", nodeId, boneId);
                    writeln("    Offset matrix: ");
                    boneMatrices[boneId].print();
                }

                // Create new bone and index it internally by its node index
                _bones[nodeId] = new Bone(boneId, name, boneMatrices[boneId]);
            }
        }

        /// Load mesh
        void loadMesh(const uint meshId, const uint skinId = uintDefault) {
            const JSONValue[] jsonAccessors = getJsonArray(_json, "accessors");

            const JSONValue jsonMesh = _json["meshes"][meshId];
            const JSONValue[] jsonPrimitives = getJsonArray(jsonMesh, "primitives");

            foreach(JSONValue jsonPrimitive; jsonPrimitives) {
                const JSONValue jsonAttributes = getJson(jsonPrimitive, "attributes");

                // Load vertices
                const uint positionId = getJsonInt(jsonAttributes, "POSITION");
                vec3[] positions = groupFloatsVec3(parseBufferData!float(jsonAccessors[positionId]));

                const uint normalId = getJsonInt(jsonAttributes, "NORMAL", -1);

                vec3[] normals;
                if (normalId != -1) {
                    normals = groupFloatsVec3(parseBufferData!float(jsonAccessors[normalId]));
                }

                const uint texUVId = getJsonInt(jsonAttributes, "TEXCOORD_0", -1);
                vec2[] texUVs;
                if (texUVId != -1) {
                    texUVs = groupFloatsVec2(parseBufferData!float(jsonAccessors[texUVId]));
                }

                // Pack all vertices into an array
                Vertex[] vertices = assembleVertices(positions, normals, texUVs);

                // Load indices
                const uint indicesId = getJsonInt(jsonPrimitive, "indices");
                GLuint[] indices = parseBufferData!GLuint(jsonAccessors[indicesId]);

                // Load textures
                loadTextures();

                AnimatedVertex[] animatedVertices;

                // Load skin details (joints and weights) if they exist
                const bool hasSkin = skinId != uintDefault;
                if (hasSkin) {
                    if (_traceDeep) {
                        writefln("  Loading skin");
                    }

                    // Fetch joint data (associated vertices and weight impact)
                    const uint jointId = getJsonInt(jsonAttributes, "JOINTS_0");
                    const uint weightId = getJsonInt(jsonAttributes, "WEIGHTS_0");

                    vec4i[] boneIds = groupIntsVec4i(parseBufferData!ushort(jsonAccessors[jointId]));
                    vec4[] weights = groupFloatsVec4(parseBufferData!float(jsonAccessors[weightId]));

                    // Pack all joints into an array
                    Joint[] joints = assembleJoints(boneIds, weights);

                    // Fetch interpolation data
                    JSONValue skin = _json["skins"][skinId];

                    // Parse bone indices referenced if any
                    int[] boneNodeIds = getJsonArrayInt(skin, "joints");

                    // Parse inverse bind matrices
                    const uint boneMatrixId = getJsonInt(skin, "inverseBindMatrices");
                    mat4[] boneMatrices = groupFloatsMat4(parseBufferData!float(jsonAccessors[boneMatrixId]));

                    // Pack all bones into global array
                    assembleBones(boneNodeIds, boneMatrices);

                    // Pack vertex and joints as animation data @TODO
                    for (uint i = 0; i < vertices.length; ++i) {
                        animatedVertices ~= AnimatedVertex(vertices[i], joints[i]);
                    }
                }

                if (hasSkin) {
                    _meshes ~= new Mesh(new VertexBuffer(animatedVertices, layout3DAnimated), new IndexBuffer(indices));
                    _animatedVertices ~= animatedVertices;
                } else {
                    _meshes ~= new Mesh(new VertexBuffer(vertices, layout3D), new IndexBuffer(indices));
                    _vertices ~= vertices;
                }
            }
        }

        /// Trace mesh data
        void traceMeshData() {
            foreach (const Mesh mesh; _meshes) {
                // @TODO a mesh needs to have an id, name, vertices or animated vertices, indices and bones
                // They should be moved away from the model
                //writefln("  Mesh %u '%s': vertices %u indices %u bones %u", meshId, name, nbVertices, nbIndices, nbBones);
                //traceBoneData(meshId);
            }
        }

        /// Trace bone data (each bone and their name, affected vertices and weights, hierarchy)
        void traceBoneData() {
            uint[] aBoneNbVertices;
            aBoneNbVertices.length = _bones.length;

            foreach (const AnimatedVertex animatedVertex; _animatedVertices) {
                foreach (const Bone bone; _bones) {
                    for (uint entryId = 0; entryId < 4; ++entryId) {
                        if (animatedVertex.boneIds[entryId] == bone.id && animatedVertex.weights[entryId] != 0) {
                            ++aBoneNbVertices[bone.id];
                        }
                    }
                }
            }

            foreach (const Bone bone; _bones) {
                writefln("    Bone %u '%s': affects %u vertices", bone.id, bone.name, aBoneNbVertices[bone.id]);
            }
        }

        /// Load textures
        void loadTextures() {
            uint textureId = 0;

            // Load through textures references
            const JSONValue[] jsonTextures = getJsonArray(_json, "images");
            foreach (const JSONValue jsonTexture; jsonTextures) {
                const string path = buildNormalizedPath(_fileDirectory, getJsonStr(jsonTexture, "uri"));

                if (canFind(path, "baseColor") || canFind(path, "diffuse")) {
                    _material.textures ~= new Texture(path, TextureType.diffuse, textureId);
                    ++textureId;
                } else if (canFind(path, "metallicRoughness") || canFind(path, "specular")) {
                    _material.textures ~= new Texture(path, TextureType.specular, textureId);
                    ++textureId;
                } else if (_trace) {
                    writeln("Warning: unknown texture type ", path ,", not loaded");
                }
            }

            // If we haven't found any texture, fetch the default one
            if (textureId == 0) {
                if (_trace) {
                    writeln("  Using default texture");
                }

                _material.textures ~= defaultTexture;
            }
        }

        /// Traverse given node
        void traverseNode(uint nodeId, mat4 parentModel = mat4.identity, bool isRoot = true) {
            JSONValue jsonNode = _json["nodes"][nodeId];

            vec3 translation = vec3.zero;
            quat rotation = quat.identity;
            vec3 scale = vec3.one;
            mat4 matNode = mat4.identity;

            if (_traceDeep) {
                string name = getJsonStr(jsonNode, "name", "");
                string hierarchy = isRoot ? "root" : "child";
                writefln("Loading %s node # %u '%s'", hierarchy, nodeId, name);
            }

            float[] translationArray = getJsonArrayFloat(jsonNode, "translation");
            if (translationArray.length == 3) {
                translation = vec3(translationArray[0], translationArray[1], translationArray[2]);

                if (_traceDeep) {
                    writeln("  Translation: ", translation);
                }
            }

            float[] rotationArray = getJsonArrayFloat(jsonNode, "rotation");
            if (rotationArray.length == 4) {
                rotation = quat(rotationArray[3], rotationArray[1], rotationArray[2], rotationArray[0]);

                if (_traceDeep) {
                    writeln("  Rotation: ", rotation);
                }
            }

            float[] scaleArray = getJsonArrayFloat(jsonNode, "scale");
            if (scaleArray.length == 3) {
                scale = vec3(scaleArray[0], scaleArray[1], scaleArray[2]);

                if (_traceDeep) {
                    writeln("  Scale: ", scale);
                }
            }

            float[] matrixArray = getJsonArrayFloat(jsonNode, "matrix");
            if (matrixArray.length == 16) {
                uint arrayId = 0;
                for (uint i = 0 ; i < 4; ++i) {
                    for (uint j = 0 ; j < 4; ++j) {
                        matNode[i][j] = matrixArray[arrayId];
                        ++arrayId;
                    }
                }

                if (_traceDeep) {
                    writeln("  Matrix: ", matNode);
                }
            }

            // Compute current node model
            const mat4 currentModel = matNode * combineModel(translation, rotation, scale);

            // Combine parent and current transform matrices
            const mat4 globalModel = parentModel * currentModel;

            if (_traceDeep) {
                writefln("  Node local model:");
                currentModel.print();
                writefln("  Node global model:");
                globalModel.print();
            }

            // Load current node mesh if any
            if (hasJson(jsonNode, "mesh")) {
                if (_trace) {
                    writeln("  Loading mesh");
                }

                // Record transform for new mesh
                _transforms ~= Transform(translation, rotation, scale);

                const uint meshId = getJsonInt(jsonNode, "mesh");
                const uint skinId = getJsonInt(jsonNode, "skin", uintDefault);

                // Load the new mesh
                loadMesh(meshId, skinId);
            }

            // Traverse children recursively
            if (hasJson(jsonNode, "children")) {
                const JSONValue[] children = getJsonArray(jsonNode, "children");

                if (_traceDeep) {
                    writeln("  Loading children nodes ", children);
                }

                isRoot = false;
                for (uint i = 0; i < children.length; ++i) {
                    const uint childrenId = children[i].get!uint;
                    traverseNode(childrenId, globalModel, isRoot);
                }
            }

            if (_traceDeep) {
                writeln("HERE");
                writeln("nodeId: ", nodeId);
                writeln("Bones: ", _bones);
            }

            // @TODO we need to loop through mesh, THEN bones as we could visit bones before they are marked as joints of a skin
            // Maybe avoid performing a recursive call ?
            // If this node is a bone, compute its final transform
            if (nodeId in _bones) {
                if (_traceDeep) {
                    writefln("  This node is a bone");
                }

                Bone bone = _bones[nodeId];
                bone.computeBindPose(globalModel);
            }
        }

        /// Traverse given animation
        void loadAnimation(JSONValue jsonAnimation) {
            const JSONValue[] jsonAccessors = getJsonArray(_json, "accessors");

            string name = getJsonStr(jsonAnimation, "name", "");

            if (_trace) {
                writefln("Animations layer '%s'", name);
            }

            /// Fetch related samplers
            JSONValue[] samplers = getJsonArray(jsonAnimation, "samplers");

            /// Fetch related channels
            if (hasJson(jsonAnimation, "channels")) {
                JSONValue[] channels = getJsonArray(jsonAnimation, "channels");

                /// Loop on all channels
                foreach(JSONValue channel; channels) {
                    JSONValue target = getJson(channel, "target");

                    const uint samplerId = getJsonInt(channel, "sampler");
                    const uint nodeId = getJsonInt(target, "node");
                    const string path = getJsonStr(target, "path");

                    if (_traceDeep) {
                        writeln("  SamplerId: ", samplerId, ", nodeId: ", nodeId, ", path: ", path);
                    }

                    JSONValue sampler = samplers[samplerId];

                    const uint inputId = getJsonInt(sampler, "input");
                    const uint outputId = getJsonInt(sampler, "output");
                    const string interpolation = getJsonStr(sampler, "interpolation");

                    if (_traceDeep) {
                        writeln("  InputId: ", inputId, ", outputId: ", outputId, " interpolation: ", interpolation);
                    }

                    JSONValue jsonTimes = jsonAccessors[inputId];
                    JSONValue jsonData = jsonAccessors[outputId];

                    vec3[] translations;
                    if (path == "translation") {
                        translations = groupFloatsVec3(parseBufferData!float(jsonData));
                    }

                    quat[] rotations;
                    if (path == "rotation") {
                        rotations = groupFloatsQuat(parseBufferData!float(jsonData));
                    }

                    vec3[] scales;
                    if (path == "scale") {
                       scales = groupFloatsVec3(parseBufferData!float(jsonData));
                    }

                    _animations[nodeId] = new Animation(getJsonArrayFloat(jsonTimes, "min")[0],
                                                        getJsonArrayFloat(jsonTimes, "max")[0],
                                                        parseBufferData!float(jsonTimes),
                                                        interpolation,
                                                        translations,
                                                        rotations,
                                                        scales);
                }
            }
        }

        /// Update all animations
        void updateAnimations() {
            // Loop through all bones
            foreach (nodeId, bone; _bones) {
                // If this bone has an animation
                if (nodeId in _animations) {
                    Animation animation = _animations[nodeId];
                    bone.computeAnimatedPose(animation);
                }
            }
        }

        /// Upload bone transformations to shader
        void uploadBoneTransforms(Shader shader) {
            foreach (bone; _bones) {
                const char* uniformName = toStringz(format("u_BoneMatrix[%u]", bone.id));
                shader.uploadUniformMat4(uniformName, bone.model);
            }
        }
    }
}

/// Instance of a **Model** to render
final class ModelInstance : Entity3D {
    private {
        Model _model;
        Shader _shader;
    }

    @property {
        /// Number of bones for the model instance
        int nbBones() {
            return cast(int)_model.nbBones;
        }
    }

    /// Index of bone to display
    int displayBoneId = -1;

    /// Constructor
    this(string fileName, uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        transform = Transform.identity;
        _model = fetchPrototype!Model(fileName);

        if (nbBones == 0) {
            _shader = fetchPrototype!Shader("model");
        } else {
            _shader = fetchPrototype!Shader("animated");
        }
    }

    /// Render the model
    override void draw() {
        _shader.activate();

        //_model.updateAnimations();
        _model.uploadBoneTransforms(_shader);

        if (nbBones) {
            _shader.uploadUniformInt("u_DisplayBoneId", displayBoneId);
        }

        foreach (Camera camera; renderer.cameras) {
            glViewport(camera.viewport.x, camera.viewport.y, camera.viewport.z, camera.viewport.w);
            _shader.uploadUniformVec3("u_CamPos", camera.globalPosition);
            _shader.uploadUniformMat4("u_CamMatrix", camera.matrix);

            if (material) {
                _model.draw(_shader, material, globalTransform);
            } else {
                _model.draw(_shader, globalTransform);
            }
        }
    }
}