module magia.render.particle;

import magia.core.color;
import magia.core.mat;
import magia.core.type;
import magia.core.vec;
import magia.main;
import magia.render.array;
import magia.render.buffer;
import magia.render.camera;
import magia.render.data;
import magia.render.drawable;
import magia.render.element;
import magia.render.layout;
import magia.render.mesh;
import magia.render.renderer;
import magia.render.shader;

import bindbc.opengl;

import std.random;
import std.stdio;

/// Number of particles in simulation
const uint nbParticles = 100;

/// Instance data
struct ParticleData {
    /// Position
    vec4 position;

    /// Color
    vec4 color;

    /// Speed
    vec4 speed;
}

/// Particle pool
class ParticlePool : Drawable2D {
    private {
        Mesh3D _mesh;
        VertexArray _vertexArray;
        Shader _shader;
        GLuint _ssboBuffer;
    }

    /// Ctr
    this() {
        _mesh = new Mesh3D(GL_POINTS);
        _shader = Magia.res.get!Shader("particles");
        _shader.setComputeDispatch(nbParticles, 1, 1);
        initBuffers();
    }

    /// Init buffers
    private void initBuffers() {
        ParticleData[] particleData;
        computePositions(particleData);

        glCreateBuffers(1, &_ssboBuffer);

        // Information to forward for each rendered instance
        BufferLayout bufferLayout = new BufferLayout([
            BufferElement("position", LayoutType.ltFloat4),
            BufferElement("color", LayoutType.ltFloat4),
            BufferElement("speed", LayoutType.ltFloat4),
        ]);

        const GLsizeiptr bufferSize = particleData.length * ParticleData.sizeof;

        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, _ssboBuffer);
        glBufferData(GL_SHADER_STORAGE_BUFFER, bufferSize, particleData.ptr, GL_DYNAMIC_DRAW);

        _vertexArray = new VertexArray();
        // TODO replacement for test here
        //_mesh.bindToSSBO(bufferLayout, _ssboBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _ssboBuffer);
        bufferLayout.setupElements();
    }

    /// Compute position for each particle
    private void computePositions(ref ParticleData[] particleData) {
        for (int i = 0; i < nbParticles; ++i) {
            const float x = 800f * uniform01!float() - 400;
            const float y = 600f * uniform01!float() - 300;
            particleData ~= ParticleData(vec4(x, y, 0f, 1.0f), vec4(0f, 0.6f, 1f, 1f), vec4.zero);
        }
    }

    /// Draw particles
    void draw(Renderer2D renderer) {
        // Setup shader
        _shader.activate();
        _shader.uploadUniformMat4("u_CamMatrix", renderer.cameras[0].matrix);

        // Draw the particles
        _vertexArray.bind();
        glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
        glDrawArrays(GL_POINTS, 0, nbParticles);
        _vertexArray.unbind();

        // Should be replacable with:
        //renderer.draw(_mesh, _shader);
    }
}