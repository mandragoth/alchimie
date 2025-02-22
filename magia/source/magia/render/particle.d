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

import std.stdio;

///
const uint nbParticlesX = 10;
///
const uint nbParticlesY = 10;
///
const uint nbParticlesZ = 10;
///
const uint nbTotalParticles = nbParticlesX * nbParticlesY * nbParticlesZ;

/// Instance data
struct ParticleData {
    /// Positions
    vec4 position;

    /// Colors
    vec4 color;
}

/// Particle pool
class ParticlePool : Drawable3D {
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
        _shader.setComputeDispatch(nbTotalParticles, 1, 1);
        initBuffers();
    }

    /// Init buffers
    private void initBuffers() {
        ParticleData[] particleData;
        computePositions(particleData);

        glCreateBuffers(1, &_ssboBuffer);

        // Information to forward for each rendered instance
        BufferLayout bufferLayout = new BufferLayout([
            BufferElement("pos", LayoutType.ltFloat4),
            BufferElement("color", LayoutType.ltFloat4),
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
        vec4 p = vec4(0f, 0f, 0f, 1f);

        const float dx = 2.0f / nbParticlesX;
        const float dy = 2.0f / nbParticlesY;
        const float dz = 2.0f / nbParticlesZ;

        for (int x = 0; x < nbParticlesX; ++x) {
            for (int y = 0; y < nbParticlesY; ++y) {
                for (int z = 0; z < nbParticlesZ; ++z) {
                    p.x = dx * x - 1f;
                    p.y = dy * y - 1f;
                    p.z = dz * z - 1f;
                    p.w = 1.0f;
                    particleData ~= ParticleData(p);
                }
            }
        }
    }

    /// Draw particles
    void draw(Renderer3D renderer) {
        // Setup shader
        _shader.activate();
        _shader.uploadUniformMat4("u_CamMatrix", renderer.cameras[0].matrix);

        // Draw the particles
        _vertexArray.bind();
        glDrawArrays(GL_POINTS, 0, nbTotalParticles);
        _vertexArray.unbind();

        // Should be replacable with:
        //renderer.draw(_mesh, _shader);
    }
}