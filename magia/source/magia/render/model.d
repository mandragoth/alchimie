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
import magia.render.material;
import magia.render.mesh;
import magia.render.renderer;
import magia.render.shader;
import magia.render.texture;
import magia.render.vertex;

private {
    // Trace
    bool s_Trace = false;
    bool s_TraceDeep = false;

    // Debug model
    bool s_DebugModel = false;
}

/// Class handling model data and draw call
final class Model {
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

        static const uint uintType = 5125;
        static const uint ushortType = 5123;
        static const uint shortType = 5122;
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

        // Traverse all nodes
        foreach (int nodeId; nodes) {
            traverseNode(nodeId);
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

        // @TODO optimize this step
        transform.recomputeModel();

        for (uint meshId = 0; meshId < _meshes.length; ++meshId) {
            _meshes[meshId].draw(shader, material, _transforms[meshId] * transform);

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

            if (s_Trace) {
                writeln("Model directory: ", _fileDirectory);
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
            for (uint dataId = dataStart; dataId < dataStart + dataLength; dataId) {
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
            if (componentType == uintType) {
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
            } else if (componentType == ushortType) {
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
            } else if (componentType == shortType) {
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
            } else {
                throw new Exception("Unsupported indice data type " ~ to!string(componentType));
            }
            
            return values;
        }

        /// Group given float array as a vec2
        vec2[] groupFloatsVec2(float[] floats) {
            vec2[] values;
            for (uint i = 0; i < floats.length; i) {
                values ~= vec2(floats[i++], floats[i++]);
            }
            return values;
        }

        /// Group given float array as a vec3
        vec3[] groupFloatsVec3(float[] floats) {
            vec3[] values;
            for (uint i = 0; i < floats.length; i) {
                values ~= vec3(floats[i++], floats[i++], floats[i++]);
            }
            return values;
        }

        /// Group given float array as a vec4
        vec4[] groupFloatsVec4(float[] floats) {
            vec4[] values;
            for (uint i = 0; i < floats.length; i) {
                values ~= vec4(floats[i++], floats[i++], floats[i++], floats[i++]);
            }
            return values;
        }

        /// Assemble all vertices
        Vertex[] assembleVertices(vec3[] positions, vec3[] normals, vec2[] texUVs) {
            if (s_Trace) {
                writeln("Vertices size: ", positions.count);
                writeln("Normals size: ", positions.count);
                writeln("UVs size: ", positions.count);
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

        /// Load textures
        void getTextures() {
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

        /// Load mesh
        void loadMesh(uint meshId) {
            if (s_Trace) {
                writeln("Mesh load");
            }

            JSONValue jsonMesh = _json["meshes"][meshId];
            JSONValue jsonPrimitive = jsonMesh["primitives"][0];
            JSONValue jsonAttributes = jsonPrimitive["attributes"];

            const uint positionId = getJsonInt(jsonAttributes, "POSITION");
            const uint normalId = getJsonInt(jsonAttributes, "NORMAL");
            const uint texUVId = getJsonInt(jsonAttributes, "TEXCOORD_0");
            const uint indicesId = getJsonInt(jsonPrimitive, "indices");

            vec3[] positions = groupFloatsVec3(getFloats(_json["accessors"][positionId]));
            vec3[] normals = groupFloatsVec3(getFloats(_json["accessors"][normalId]));
            vec2[] texUVs = groupFloatsVec2(getFloats(_json["accessors"][texUVId]));
            
            Vertex[] vertices = assembleVertices(positions, normals, texUVs);
            GLuint[] indices = getIndices(_json["accessors"][indicesId]);
            getTextures();

            _meshes ~= new Mesh(new VertexBuffer(vertices, layout3D), new IndexBuffer(indices));
            _vertices ~= vertices;
        }

        /// Traverse given node
        void traverseNode(uint nextNode, mat4 matrix = mat4.identity) {
            JSONValue node = _json["nodes"][nextNode];

            vec3 translation = vec3(0.0f, 0.0f, 0.0f);
            quat rotation = quat.identity;
            vec3 scale = vec3(1.0f, 1.0f, 1.0f);
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
                rotation = quat(rotationArray[3], rotationArray[0], rotationArray[1], rotationArray[2]);

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

            // Combine parent and current transform matrices
            mat4 matNextNode = matrix * matNode;

            // Load current node mesh
            if (hasJson(node, "mesh")) {
                if (s_Trace) {
                    writeln("Load current mesh");
                }

                _transforms ~= Transform(matNextNode, translation, rotation, scale);
                loadMesh(getJsonInt(node, "mesh"));
            }

            // Traverse children recursively
            if (hasJson(node, "children")) {
                const JSONValue[] children = getJsonArray(node, "children");

                if (s_Trace) {
                    writeln("Load children ", children);
                }

                for (uint i = 0; i < children.length; ++i) {
                    const uint childrenId = children[i].get!uint;
                    traverseNode(childrenId, matNextNode);
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

            if (material) {
                _model.draw(_shader, material, transform);
            } else {
                _model.draw(_shader, transform);
            }
        }
    }
}