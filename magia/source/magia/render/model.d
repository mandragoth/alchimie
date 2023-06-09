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

/// Default uint value
enum uint uintDefault = -1;

private {
    // File to debug + should we trace deep layers?
    string s_DebugFile = "skin.gltf";
    bool s_TraceDeep = true;

    // Debug model
    bool s_DebugModel = false;
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

        // Transformations
        Transform[] _transforms;

        // Bone data (optional)
        Bone[] _bones;
        int[] _boneNodeIds;

        // Directory
        string _fileDirectory;

        // Trace mechanism
        bool _trace;
        bool _traceDeep;
    }

    @property {
        /// Number of bones for the model instance
        int nbBones() {
            return cast(int)_bones.length;
        }
    }

    /// Constructor
    this(string fileName) {
        if (fileName.canFind(s_DebugFile)) {
            _trace = true;
            _traceDeep = s_TraceDeep;
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

        JSONValue[] animations = getJsonArray(_json, "animations");

        // Traverse all animations
        foreach (JSONValue animation; animations) {
            //traverseAnimation(animation);
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
        _boneNodeIds = other._boneNodeIds;
        _fileDirectory = other._fileDirectory;
    }

    /// Draw the model (by default with its preloaded material)
    void draw(Shader shader, Material material, Transform transform) {
        // Model culling is the opposite of usual objects
        glCullFace(GL_BACK);

        // Recompute model of transform in case it is not yet done
        transform.recomputeModel();

        for (uint meshId = 0; meshId < _meshes.length; ++meshId) {
            Transform meshTransform = _transforms[meshId] * transform;
            _meshes[meshId].draw(shader, material, meshTransform);

            if (s_DebugModel) {
                _vertices[meshId].drawNormal();
            }
        }

        // Revert to usual culling
        glCullFace(GL_FRONT);
    }

    /// Draw the model (with its preloaded material)
    void draw(Shader shader, Transform transform) {
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

            for (ulong bufferId = 0; bufferId < jsonBuffers.length; ++bufferId) {
                string uri = jsonBuffers[bufferId]["uri"].get!string;

                if (canFind(uri, ".bin")) {
                    _data[bufferId] = cast(ubyte[]) read(buildNormalizedPath(_fileDirectory, uri));
                } else {
                    string data = uri.replace("data:application/gltf-buffer;base64,", "");
                    _data[bufferId] = Base64.decode(data);
                }
            }
        }

        /// Get data from buffers with accessor
        T[] parseBufferData(T)(JSONValue accessor) {
            const uint bufferViewId = getJsonInt(accessor, "bufferView", 0);
            const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
            const uint componentType = getJsonInt(accessor, "componentType");
            const uint count = getJsonInt(accessor, "count");
            const string type = getJsonStr(accessor, "type");

            if (_traceDeep) {
                writeln("Load indices with bufferViewId ", bufferViewId, " count ", count,
                        " byteOffset ", byteOffset, " componentType ", componentType);
            }

            JSONValue bufferView = _json["bufferViews"][bufferViewId];
            const uint bufferId = getJsonInt(bufferView, "buffer");
            const uint accessorByteOffset = getJsonInt(bufferView, "byteOffset", 0);

            uint nbBytesPerVertex;
            if (type == "SCALAR") {
                nbBytesPerVertex = 1;
            } else if (type == "VEC2") {
                nbBytesPerVertex = 2;
            } else if (type == "VEC3") {
                nbBytesPerVertex = 3;
            } else if (type == "VEC4") {
                nbBytesPerVertex = 4;
            } else if (type == "MAT4") {
                nbBytesPerVertex = 16;
            }

            const uint dataStart = byteOffset + accessorByteOffset;

            T[] values;
            if (componentType == ComponentType.float_t) {
                const uint dataLength = count * 4 * nbBytesPerVertex;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++]
                    ];

                    // Cast data to uint, then GLuint
                    float value = *cast(float*)bytes.ptr;
                    values ~= cast(T) value;
                }
            } else if (componentType == ComponentType.uint_t) {
                const uint dataLength = count * 4 * nbBytesPerVertex;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++]
                    ];

                    // Cast data to uint, then GLuint
                    uint value = *cast(uint*)bytes.ptr;
                    values ~= cast(T) value;
                }
            } else if (componentType == ComponentType.ushort_t) {
                const uint dataLength = count * 2 * nbBytesPerVertex;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++]
                    ];

                    // Cast data to ushort, then GLuint
                    ushort value = *cast(ushort*)bytes.ptr;
                    values ~= cast(T) value;
                }
            } else if (componentType == ComponentType.short_t) {
                const uint dataLength = count * 2 * nbBytesPerVertex;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[bufferId][dataId++],
                        _data[bufferId][dataId++]
                    ];

                    // Cast data to short, then GLuint
                    short value = *cast(short*)bytes.ptr;
                    values ~= cast(T) value;
                }
            } else if (componentType == ComponentType.ubyte_t) {
                const uint dataLength = count * nbBytesPerVertex;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    // Cast data to GLuint
                    const ubyte value = _data[bufferId][dataId++];
                    values ~= cast(T) value;
                }
            } else {
                throw new Exception("Unsupported indice data type " ~ to!string(componentType));
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
        vec4[] groupFloatsVec4(float[] floats) {
            vec4[] values;
            for (uint i = 0; i < floats.length;) {
                values ~= vec4(floats[i++], floats[i++], floats[i++], floats[i++]);
            }
            return values;
        }

        /// Group given GLuint array as vec4i
        vec4i[] groupIntsVec4i(ubyte[] uints) {
            vec4i[] values;
            for (uint i = 0; i < uints.length;) {
                values ~= vec4i(uints[i++], uints[i++], uints[i++], uints[i++]);
            }
            return values;
        }

        /// Group given float array as mat4
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
            if (_traceDeep) {
                writeln("Vertices size: ", positions.length);
                writeln("Normals size: ", normals.length);
                writeln("UVs size: ", texUVs.length);
            }

            Vertex[] vertices;
            for (ulong i = 0; i < positions.length; ++i) {
                vec3 normal = i < normals.length ? normals[i] : vec3.zero;
                vec2 texUV = i < texUVs.length ? texUVs[i] : vec2.zero;

                if (_traceDeep) {
                    writeln("Assembling vertex with",
                            " position ", positions[i],
                            " normal ", normal,
                            " texture UV ", texUV);
                }

                vertices ~= Vertex(positions[i], texUV, normal);
            }

            return vertices;
        }

        /// Assemble all joints
        Joint[] assembleJoints(vec4i[] boneIds, vec4[] weights) {
            assert(boneIds.length == weights.length);

            if (_traceDeep) {
                for (uint i = 0; i < boneIds.length; ++i) {
                    writefln("  boneIds[%u]: %s", i, boneIds[i]);
                }

                for (uint i = 0; i < weights.length; ++i) {
                    writefln("  weights[%u]: %s", i, weights[i]);
                }
            }

            Joint[] joints;
            for (uint i = 0; i < boneIds.length; ++i) {
                joints ~= Joint(boneIds[i], weights[i]);
            }

            return joints;
        }

        Bone[] assembleBones(mat4[] boneMatrices) {
            if (_traceDeep) {
                writeln("Bone matrices size: ", boneMatrices.length);
            }

            Bone[] bones;
            for (uint i = 0; i < boneMatrices.length; ++i) {
                if (_traceDeep) {
                    writeln("Assembling bone with matrix ", boneMatrices[i]);
                }

                bones ~= Bone(boneMatrices[i]);
            }

            return bones;
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

                AnimatedVertexData[] animationData;
                int[] boneNodeIds;
                mat4[] boneMatrices;

                // Load skin details (joints and weights) if they exist
                if (skinId != uintDefault) {
                    if (_traceDeep) {
                        writefln("Joint # %u", skinId);
                    }

                    // Fetch joint data (associated vertices and weight impact)
                    const uint vertexId = getJsonInt(jsonAttributes, "JOINTS_0");
                    const uint weightId = getJsonInt(jsonAttributes, "WEIGHTS_0");

                    vec4i[] boneIds = groupIntsVec4i(parseBufferData!ubyte(jsonAccessors[vertexId]));
                    vec4[] weights = groupFloatsVec4(parseBufferData!float(jsonAccessors[weightId]));

                    // Pack all joints into an array
                    Joint[] joints = assembleJoints(boneIds, weights);

                    // Fetch interpolation data
                    JSONValue skin = _json["skins"][skinId];

                    // Parse inverse bind matrices
                    const uint boneMatrixId = getJsonInt(skin, "inverseBindMatrices");
                    boneMatrices = groupFloatsMat4(parseBufferData!float(jsonAccessors[boneMatrixId]));

                    // Pack all bones into global array
                    Bone[] bones = assembleBones(boneMatrices);
                    _bones ~= bones;

                    // Parse bone indices referenced if any
                    boneNodeIds = getJsonArrayInt(skin, "joints");
                    _boneNodeIds ~= boneNodeIds;

                    // Pack vertex and joints as animation data
                    for (uint i = 0; i < vertices.length; ++i) {
                        animationData ~= AnimatedVertexData(vertices[i], joints[i]);
                    }
                }

                if (_trace) {
                    traceMeshData(meshId, getJsonStr(jsonMesh, "name", ""), vertices.length, indices.length, nbBones);
                    traceBoneData(animationData, boneNodeIds, boneMatrices);
                }

                if (animationData.empty()) {
                    _meshes ~= new Mesh(new VertexBuffer(vertices, layout3D), new IndexBuffer(indices));
                } else {
                    _meshes ~= new Mesh(new VertexBuffer(animationData, layout3DAnimated), new IndexBuffer(indices));
                }

                _vertices ~= vertices;
            }
        }

        /// Trace mesh data
        void traceMeshData(uint meshId, string name, ulong nbVertices, ulong nbIndices, ulong nbBones) {
            writefln("  Mesh %u '%s': vertices %u indices %u bones %u", meshId, name, nbVertices, nbIndices, nbBones);
        }

        /// Trace bone data (each bone and their name, affected vertices and weights, hierarchy)
        /// Note: Only for debug purposes, this one is rather heavy as it remaps vertices to bones
        void traceBoneData(AnimatedVertexData[] animationData, int[] jointIds, mat4[] boneMatrices) {
            ulong[] aBoneNbVertices;
            aBoneNbVertices.length = boneMatrices.length;

            for (ulong animationId = 0; animationId < animationData.length; ++animationId) {
                const AnimatedVertexData boneData = animationData[animationId];
                vec4i boneIds = boneData.boneIds;

                for (int boneId = 0; boneId < boneMatrices.length; ++boneId) {
                    if (boneIds.contains(boneId)) {
                        ++aBoneNbVertices[boneId];
                    }
                }
            }

            for (ulong boneId = 0; boneId < boneMatrices.length; ++boneId) {
                JSONValue boneNode = _json["nodes"][jointIds[boneId]];
                writefln("    Bone '%s': affects %u vertices", getJsonStr(boneNode, "name", ""), aBoneNbVertices[boneId]);
                writefln("      Bone offset matrix:");
                boneMatrices[boneId].print();
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
                    writeln("Using default texture");
                }

                _material.textures ~= defaultTexture;
            }
        }

        /// Traverse given node
        void traverseNode(uint nodeId, mat4 parentModel = mat4.identity) {
            JSONValue node = _json["nodes"][nodeId];

            vec3 translation = vec3.zero;
            quat rotation = quat.identity;
            vec3 scale = vec3.one;
            mat4 matNode = mat4.identity;

            float[] translationArray = getJsonArrayFloat(node, "translation", []);
            if (translationArray.length == 3) {
                translation = vec3(translationArray[0], translationArray[1], translationArray[2]);

                if (_traceDeep) {
                    writeln("Translation: ", translation);
                }
            }

            float[] rotationArray = getJsonArrayFloat(node, "rotation", []);
            if (rotationArray.length == 4) {
                rotation = quat(rotationArray[0], rotationArray[1], rotationArray[2], rotationArray[3]);

                if (_traceDeep) {
                    writeln("Rotation: ", rotation);
                }
            }

            float[] scaleArray = getJsonArrayFloat(node, "scale", []);
            if (scaleArray.length == 3) {
                scale = vec3(scaleArray[0], scaleArray[1], scaleArray[2]);

                if (_traceDeep) {
                    writeln("Scale: ", scale);
                }
            }

            float[] matrixArray = getJsonArrayFloat(node, "matrix", []);
            if (matrixArray.length == 16) {
                uint arrayId = 0;
                for (uint i = 0 ; i < 4; ++i) {
                    for (uint j = 0 ; j < 4; ++j) {
                        matNode[i][j] = matrixArray[arrayId];
                        ++arrayId;
                    }
                }

                if (_traceDeep) {
                    writeln("Matrix: ", matNode);
                }
            }

            // Compute current node model
            mat4 currentModel = matNode * combineModel(translation, rotation, scale);

            // Combine parent and current transform matrices
            mat4 globalModel = parentModel * currentModel;

            // If this node is a bone, compute its final transform
            for(ulong boneId = 0; boneId < _boneNodeIds.length; ++boneId) {
                if (_boneNodeIds[boneId] == nodeId) {
                    _bones[boneId].finalTransform = globalModel * _bones[boneId].offsetMatrix;

                    if (_trace) {
                        writefln("    Bone # %u", boneId);
                        writefln("      Global model: ");
                        globalModel.print();
                        writefln("      Final transform: ");
                        _bones[boneId].finalTransform.print();
                    }

                    break;
                }
            }

            // Load current node mesh
            if (hasJson(node, "mesh")) {
                if (_trace) {
                    writeln("  Loading mesh # ", nodeId);
                    writeln("    Combined model: ");
                    currentModel.print();
                }

                // Record transform for new mesh
                _transforms ~= Transform(currentModel, translation, rotation, scale);

                const uint meshId = getJsonInt(node, "mesh");
                const uint skinId = getJsonInt(node, "skin", uintDefault);

                // Load the new mesh
                loadMesh(meshId, skinId);
            }

            // Traverse children recursively
            if (hasJson(node, "children")) {
                const JSONValue[] children = getJsonArray(node, "children");

                if (_traceDeep) {
                    writeln("  Loading children nodes ", children);
                    writeln("    Combined global model: ");
                    globalModel.print();
                }

                for (uint i = 0; i < children.length; ++i) {
                    const uint childrenId = children[i].get!uint;
                    traverseNode(childrenId, globalModel);
                }
            }
        }

        /// Traverse given animation
        void traverseAnimation(JSONValue animation) {
            string name = getJsonStr(animation, "name", "");

            if (_trace) {
                writeln("Animation name: ", name);
            }

            /// Fetch related samplers
            JSONValue[] samplers = getJsonArray(animation, "samplers");

            /// Fetch related channels
            if (hasJson(animation, "channels")) {
                JSONValue[] channels = getJsonArray(animation, "channels");

                /// Loop on all channels
                foreach(JSONValue channel; channels) {
                    JSONValue target = getJson(channel, "target");

                    const uint samplerId = getJsonInt(channel, "sampler");
                    const uint nodeId = getJsonInt(target, "node");
                    const string path = getJsonStr(target, "path");

                    if (_trace) {
                        writeln("SamplerId: ", samplerId, ", nodeId: ", nodeId, ", path: ", path);
                    }

                    JSONValue sampler = samplers[samplerId];

                    const uint inputId = getJsonInt(sampler, "input");
                    const uint outputId = getJsonInt(sampler, "output");
                    const string interpolation = getJsonStr(sampler, "interpolation");

                    if (_trace) {
                        writeln("InputId: ", inputId, ", outputId: ", outputId, " interpolation: ", interpolation);
                    }
                }
            }
        }

        /// Upload bone transformations to shader
        void uploadBoneTransforms(Shader shader) {
            for(ulong boneId = 0; boneId < _bones.length; ++boneId) {
                const char* uniformName = toStringz(format("u_BoneMatrix[%u]", boneId));
                shader.uploadUniformMat4(uniformName, _bones[boneId].finalTransform);
            }
        }
    }
}

/// Instance of a **Model** to render
final class ModelInstance : Entity {
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

            _shader.activate();
            _model.uploadBoneTransforms(_shader);
        }
    }

    /// Render the model
    override void draw() {
        _shader.activate();

        if (nbBones) {
            _shader.uploadUniformInt("u_DisplayBoneId", displayBoneId);
        }

        foreach (Camera camera; renderer.cameras) {
            glViewport(camera.viewport.x, camera.viewport.y, camera.viewport.z, camera.viewport.w);
            _shader.uploadUniformVec3("u_CamPos", camera.position);
            _shader.uploadUniformMat4("u_CamMatrix", camera.matrix);

            if (material) {
                _model.draw(_shader, material, transform);
            } else {
                _model.draw(_shader, transform);
            }
        }
    }
}