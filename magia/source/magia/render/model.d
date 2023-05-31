module magia.render.model;

import std.algorithm;
import std.conv;
import std.file;
import std.json;
import std.path;
import std.stdio;
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

enum uint uintDefault = -1;

private {
    // Trace (@TODO improve)
    bool s_Trace = false;
    bool s_TraceMesh = false;
    bool s_TraceAnim = false;
    bool s_TraceDeep = false;

    // Debug model
    bool s_DebugModel = false;
}

/// Class handling model data and draw call
final class Model {
    enum ComponentType {
        byte_t = 5120,
        ubyte_t = 5121,
        short_t = 5122,
        ushort_t = 5123,
        uint_t = 5125,
        float_t = 5126
    }

    int nbBones;

    private {
        // JSON data
        ubyte[] _data;
        JSONValue _json;

        // Material data
        Material _material;

        // Mesh data
        Mesh[] _meshes;

        // Raw vertex data
        Vertex[] _vertices;

        // Transformations
        Transform[] _transforms;

        // Directory
        string _fileDirectory;
    }

    /// Constructor
    this(string fileName) {
        // Initialize material
        _material = new Material();

        // Fetch data
        _data = getData(fileName);

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
            traverseAnimation(animation);
        }
    }

    /// Copy constructor
    this(Model other) {
        _data = other._data;
        _json = other._json;
        _meshes = other._meshes;
        _vertices = other._vertices;
        _transforms = other._transforms;
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
        /// Get data
        ubyte[] getData(string fileName) {
            _fileDirectory = dirName(fileName);

            if (s_Trace || s_TraceMesh || s_TraceAnim || s_TraceDeep) {
                writeln("Model file path: ", fileName);
            }

            _json = parseJSON(readText(fileName));
            string uri = _json["buffers"][0]["uri"].get!string;
            return cast(ubyte[]) read(buildNormalizedPath(_fileDirectory, uri));
        }

        /// Get all floats from a JSONValue accessor
        float[] getFloats(JSONValue accessor) {
            const uint bufferViewId = getJsonInt(accessor, "bufferView", 1);
            const uint count = getJsonInt(accessor, "count");
            const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
            const string type = getJsonStr(accessor, "type");

            JSONValue bufferView = _json["bufferViews"][bufferViewId];
            const uint accessorByteOffset = getJsonInt(bufferView, "byteOffset");

            uint nbBytesPerVertex;
            if (type == "SCALAR") {
                nbBytesPerVertex = 1;
            } else if (type == "VEC2") {
                nbBytesPerVertex = 2;
            } else if (type == "VEC3") {
                nbBytesPerVertex = 3;
            } else if (type == "VEC4") {
                nbBytesPerVertex = 4;
            }

            const uint dataStart = byteOffset + accessorByteOffset;
            const uint dataLength = count * 4 * nbBytesPerVertex;

            float[] values;
            for (uint dataId = dataStart; dataId < dataStart + dataLength;) {
                ubyte[] bytes = [
                    _data[dataId++],
                    _data[dataId++],
                    _data[dataId++],
                    _data[dataId++]
                ];

                // Cast data to float
                values ~= *cast(float*)bytes.ptr;
            }

            return values;
        }

        /// Get all floats from a JSONValue accessor
        ubyte[] getUbytes(JSONValue accessor) {
            const uint bufferViewId = getJsonInt(accessor, "bufferView", 1);
            const uint count = getJsonInt(accessor, "count");
            const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
            const string type = getJsonStr(accessor, "type");

            JSONValue bufferView = _json["bufferViews"][bufferViewId];
            const uint accessorByteOffset = getJsonInt(bufferView, "byteOffset");

            uint nbBytesPerVertex;
            if (type == "SCALAR") {
                nbBytesPerVertex = 1;
            } else if (type == "VEC2") {
                nbBytesPerVertex = 2;
            } else if (type == "VEC3") {
                nbBytesPerVertex = 3;
            } else if (type == "VEC4") {
                nbBytesPerVertex = 4;
            }

            const uint dataStart = byteOffset + accessorByteOffset;
            const uint dataLength = count * nbBytesPerVertex;

            ubyte[] values;
            for (uint dataId = dataStart; dataId < dataStart + dataLength;) {
                ubyte[] bytes = [
                    _data[dataId++],
                    _data[dataId++],
                    _data[dataId++],
                    _data[dataId++]
                ];

                // No cast needed here
                values ~= bytes;
            }

            return values;
        }

        GLuint[] getIndices(JSONValue accessor) {
            const uint bufferViewId = getJsonInt(accessor, "bufferView", 0);
            const uint count = getJsonInt(accessor, "count");
            const uint byteOffset = getJsonInt(accessor, "byteOffset", 0);
            const uint componentType = getJsonInt(accessor, "componentType");

            if (s_Trace) {
                writeln("Load indices with bufferViewId ", bufferViewId, " count ", count,
                        " byteOffset ", byteOffset, " componentType ", componentType);
            }

            JSONValue bufferView = _json["bufferViews"][bufferViewId];
            const uint accessorByteOffset = getJsonInt(bufferView, "byteOffset");

            const uint dataStart = byteOffset + accessorByteOffset;

            GLuint[] values;
            if (componentType == ComponentType.uint_t) {
                const uint dataLength = count * 4;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[dataId++],
                        _data[dataId++],
                        _data[dataId++],
                        _data[dataId++]
                    ];

                    // Cast data to uint, then GLuint
                    uint value = *cast(uint*)bytes.ptr;
                    values ~= cast(GLuint) value;
                }
            } else if (componentType == ComponentType.ushort_t) {
                const uint dataLength = count * 2;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[dataId++],
                        _data[dataId++]
                    ];

                    // Cast data to ushort, then GLuint
                    ushort value = *cast(ushort*)bytes.ptr;
                    values ~= cast(GLuint) value;
                }
            } else if (componentType == ComponentType.short_t) {
                const uint dataLength = count * 2;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    ubyte[] bytes = [
                        _data[dataId++],
                        _data[dataId++]
                    ];

                    // Cast data to short, then GLuint
                    short value = *cast(short*)bytes.ptr;
                    values ~= cast(GLuint) value;
                }
            } else if (componentType == ComponentType.ubyte_t) {
                const uint dataLength = count;

                for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
                    // Cast data to GLuint
                    ubyte value = _data[dataId++];
                    values ~= cast(GLuint) value;
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

        /// Assemble all vertices
        Vertex[] assembleVertices(vec3[] positions, vec3[] normals, vec2[] texUVs) {
            if (s_Trace) {
                writeln("Vertices size: ", positions.count);
                writeln("Normals size: ", normals.count);
                writeln("UVs size: ", texUVs.count);
            }

            Vertex[] vertices;
            for (uint i = 0; i < positions.length; ++i) {
                if (s_TraceDeep) {
                    writeln("Assembling vertex with",
                            " position ", positions[i],
                            " normal ", normals[i],
                            " texture UV ", texUVs[i]);
                }

                vertices ~= Vertex(positions[i], texUVs[i], normals[i]);
            }

            return vertices;
        }

        /// Assemble all joints
        Joint[] assembleJoints(vec4i[] boneIds, vec4[] weights) {
            if (s_Trace) {
                writeln("Vertices references size: ", boneIds.count);
                writeln("Weights size: ", weights.count);
            }

            Joint[] joints;
            for (uint i = 0; i < boneIds.length; ++i) {
                if (s_TraceDeep) {
                    writeln("Assembling joint with",
                            " vertexId ", boneIds[i],
                            " weight ", weights[i]);
                }

                joints ~= Joint(boneIds[i], weights[i]);
            }

            return joints;
        }

        /// Load mesh
        void loadMesh(const uint meshId, const uint skinId = uintDefault) {
            if (s_Trace) {
                writeln("Mesh load");
            }

            const JSONValue[] jsonAccessors = getJsonArray(_json, "accessors");
            const JSONValue[] jsonPrimitives = getJsonArray(_json["meshes"][meshId], "primitives");

            foreach(JSONValue jsonPrimitive; jsonPrimitives) {
                const JSONValue jsonAttributes = getJson(jsonPrimitive, "attributes");

                // Load vertices
                const uint positionId = getJsonInt(jsonAttributes, "POSITION");
                const uint normalId = getJsonInt(jsonAttributes, "NORMAL");
                const uint texUVId = getJsonInt(jsonAttributes, "TEXCOORD_0");

                vec3[] positions = groupFloatsVec3(getFloats(jsonAccessors[positionId]));
                vec3[] normals = groupFloatsVec3(getFloats(jsonAccessors[normalId]));
                vec2[] texUVs = groupFloatsVec2(getFloats(jsonAccessors[texUVId]));

                // Pack all vertices into an array
                Vertex[] vertices = assembleVertices(positions, normals, texUVs);

                // Load indices
                const uint indicesId = getJsonInt(jsonPrimitive, "indices");
                GLuint[] indices = getIndices(jsonAccessors[indicesId]);

                // Load textures
                loadTextures();

                // Load skin details (joints and weights) if they exist
                if (skinId != uintDefault) {
                    // Fetch joint data (associated vertices and weight impact)
                    const uint vertexId = getJsonInt(jsonAttributes, "JOINTS_0");
                    const uint weightId = getJsonInt(jsonAttributes, "WEIGHTS_0");

                    vec4i[] boneIds = groupIntsVec4i(getUbytes(jsonAccessors[vertexId]));
                    vec4[] weights = groupFloatsVec4(getFloats(jsonAccessors[weightId]));

                    // Pack all joints into an array
                    Joint[] joints = assembleJoints(boneIds, weights);

                    // Fetch interpolation data
                    JSONValue skin = _json["skins"][skinId];
                    int[] jointIds = getJsonArrayInt(skin, "joints");
                    nbBones += jointIds.length;

                    foreach(int jointId; jointIds) {
                        traverseNode(jointId);
                    }

                    if (s_TraceAnim) {
                        writeln("Bones size: ", boneIds.length);
                        writeln("Weights size: ", weights.length);
                        writeln("Skin joints count: ", jointIds.length);
                    }

                    _meshes ~= new Mesh(new VertexBuffer(vertices, joints, layout3DAnimated), new IndexBuffer(indices));
                } else {
                    _meshes ~= new Mesh(new VertexBuffer(vertices, layout3D), new IndexBuffer(indices));
                }

                _vertices ~= vertices;
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
                } else if (s_Trace) {
                    writeln("Warning: unknown texture type ", path ,", not loaded");
                }
            }

            // If we haven't found any texture, fetch the default one
            if (textureId == 0) {
                _material.textures ~= defaultTexture;
            }
        }

        /// Traverse given node
        void traverseNode(uint nodeId, mat4 matrix = mat4.identity) {
            JSONValue node = _json["nodes"][nodeId];

            vec3 translation = vec3.zero;
            quat rotation = quat.identity;
            vec3 scale = vec3.one;
            mat4 matNode = mat4.identity;

            float[] translationArray = getJsonArrayFloat(node, "translation", []);
            if (translationArray.length == 3) {
                translation = vec3(translationArray[0], translationArray[1], translationArray[2]);

                if (s_Trace) {
                    writeln("Translation: ", translation);
                }
            }

            float[] rotationArray = getJsonArrayFloat(node, "rotation", []);
            if (rotationArray.length == 4) {
                rotation = quat(rotationArray[0], rotationArray[1], rotationArray[2], rotationArray[3]);

                if (s_Trace) {
                    writeln("Rotation: ", rotation);
                }
            }

            float[] scaleArray = getJsonArrayFloat(node, "scale", []);
            if (scaleArray.length == 3) {
                scale = vec3(scaleArray[0], scaleArray[1], scaleArray[2]);

                if (s_Trace) {
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

                if (s_Trace) {
                    writeln("Matrix: ", matNode);
                }
            }

            // Compute object model
            mat4 model = combineModel(translation, quat.identity, scale);

            // Combine parent and current transform matrices
            mat4 matNextNode = matrix * matNode * model;

            // Load current node mesh
            if (hasJson(node, "mesh")) {
                if (s_TraceMesh) {
                    writeln("Load current mesh # ", nodeId);
                    writeln("Combined model: ", model);
                }

                // Record transform for new mesh
                _transforms ~= Transform(model, translation, rotation, scale);

                const uint meshId = getJsonInt(node, "mesh");
                const uint skinId = getJsonInt(node, "skin", uintDefault);

                // Load the new mesh
                loadMesh(meshId, skinId);
            }

            // Traverse children recursively
            if (hasJson(node, "children")) {
                const JSONValue[] children = getJsonArray(node, "children");

                if (s_Trace) {
                    writeln("Load children ", children);
                    writeln("Combined next node model: ", matNextNode);
                }

                for (uint i = 0; i < children.length; ++i) {
                    const uint childrenId = children[i].get!uint;
                    traverseNode(childrenId, matNextNode);
                }
            }
        }

        /// Traverse given animation
        void traverseAnimation(JSONValue animation) {
            string name = getJsonStr(animation, "name");

            if (s_TraceMesh) {
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

                    if (s_TraceAnim) {
                        writeln("SamplerId: ", samplerId, ", nodeId: ", nodeId, ", path: ", path);
                    }

                    JSONValue sampler = samplers[samplerId];

                    const uint inputId = getJsonInt(sampler, "input");
                    const uint outputId = getJsonInt(sampler, "output");
                    const string interpolation = getJsonStr(sampler, "interpolation");

                    if (s_TraceAnim) {
                        writeln("InputId: ", inputId, ", outputId: ", outputId, " interpolation: ", interpolation);
                    }
                }
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
        int nbBones() {
            return _model.nbBones;
        }
    }

    int displayBoneId = -1;

    /// Constructor
    this(string fileName, uint instances = 1, mat4[] instanceMatrices = [mat4.identity]) {
        transform = Transform.identity;
        _shader = fetchPrototype!Shader("model");
        _model = fetchPrototype!Model(fileName);
    }

    /// Render the model
    override void draw() {
        _shader.activate();

        foreach (Camera camera; renderer.cameras) {
            glViewport(camera.viewport.x, camera.viewport.y, camera.viewport.z, camera.viewport.w);
            _shader.uploadUniformVec3("u_CamPos", camera.position);
            _shader.uploadUniformMat4("u_CamMatrix", camera.matrix);
            _shader.uploadUniformInt("u_DisplayBoneId", displayBoneId);

            if (material) {
                _model.draw(_shader, material, transform);
            } else {
                _model.draw(_shader, transform);
            }
        }
    }
}