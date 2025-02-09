module magia.render.particle;

import magia.core.mat;
import magia.core.vec;
import magia.main;
import magia.render.array;
import magia.render.drawable;
import magia.render.element;
import magia.render.layout;
import magia.render.renderer;
import magia.render.shader;

import bindbc.opengl;

import std.stdio;

///
const uint nbParticlesX = 100;
///
const uint nbParticlesY = 100;
///
const uint nbParticlesZ = 100;
///
const uint nbTotalParticles = nbParticlesX * nbParticlesY * nbParticlesZ;

/// Particle pool
class ParticlePool : Drawable3D {
    private {
        VertexArray _vertexArray;
        Shader _shader;
        GLuint _posBuffer;
    }

    /// Ctr
    this() {
        _shader = Magia.res.get!Shader("particles");
        _shader.setComputeDispatch(nbTotalParticles, 1, 1);
        initBuffers();
    }

    /// Init buffers
    private void initBuffers() {
        vec4[] positions;
        computePositions(positions);

        glCreateBuffers(1, &_posBuffer);

        const GLsizeiptr bufferSize = positions.length * vec4.sizeof;

        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, _posBuffer);
        glBufferData(GL_SHADER_STORAGE_BUFFER, bufferSize, positions.ptr, GL_DYNAMIC_DRAW);

        _vertexArray = new VertexArray();

        glBindBuffer(GL_ARRAY_BUFFER, _posBuffer);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 0, null);
        glEnableVertexAttribArray(0);

        glBindVertexArray(0);
    }

    /// Compute position for each particle
    private void computePositions(ref vec4[] positions) {
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
                    positions ~= p;
                }
            }
        }
    }

    /// Draw particles
    void draw(Renderer3D renderer) {
        _shader.activate();

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        // Draw the particles
        glPointSize(2.0f);
        _vertexArray.bind();
        glDrawArrays(GL_POINTS, 0, nbTotalParticles);
        _vertexArray.unbind();
    }
}