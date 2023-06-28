module magia.render.hierarchy;

import magia.render.entity;

/// Represents a hierarchy
struct Node {
    /// Current node
    Instance _current;

    /// Children
    Instance[] _children;

    /// Constructor
    this(Entity current, Instance[] children = null) {
        _current = current;
        _children = children;
    }

    /// Add a child to the current node
    void addChild(Instance entity) {
        _children ~= entity;
    }
}