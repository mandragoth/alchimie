module magia.render.node;

import magia.core.mat;

/// Model node
struct Node {
    /// Index
    uint id;
    /// Transform matrix
    mat4 model;
}