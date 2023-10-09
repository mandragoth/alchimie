module alma.script.sgraphics;

import magia;
import grimoire;

package void loadAlchimieLibGraphics(GrLibDefinition library) {
    // Maths types
    GrType vec2Type = grGetNativeType("vec2", [grFloat]);
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType mat4Type = grGetNativeType("mat4");

    // Vertex data types
    GrType vertexType = library.addNative("Vertex");
    GrType animatedVertexType = library.addNative("AnimatedVertex");

    // Graphics types
    GrType grLayout = library.addEnum("LayoutType", grNativeEnum!LayoutType);
    GrType bufferElementType = library.addNative("BufferElement");
    GrType bufferLayoutType = library.addNative("BufferLayout");
    GrType vertexBufferType = library.addNative("VertexBuffer");
    GrType indexBufferType = library.addNative("IndexBuffer");
    GrType meshType = library.addNative("Mesh");

    // Graphics constructor
    library.addConstructor(&_newBufferElement, bufferElementType, [grString, grLayout, grInt]);
    library.addConstructor(&_newBufferLayout, bufferLayoutType, [grList(bufferElementType)]);
    library.addConstructor(&_newVertexBuffer, vertexBufferType, [grList(grFloat), bufferLayoutType]);
    library.addConstructor(&_newVertexBuffer2, vertexBufferType, [grList(vec2Type), bufferLayoutType]);
    library.addConstructor(&_newVertexBuffer3, vertexBufferType, [grList(vec3Type), bufferLayoutType]);
    library.addConstructor(&_newVertexBuffer4, vertexBufferType, [grList(mat4Type), bufferLayoutType]);
    library.addConstructor(&_newVertexBuffer5, vertexBufferType, [grList(vertexType), bufferLayoutType]);
    library.addConstructor(&_newVertexBuffer6, vertexBufferType, [grList(animatedVertexType), bufferLayoutType]);
    library.addConstructor(&_newIndexBuffer, indexBufferType, [grList(grUInt)]);
    library.addConstructor(&_newMesh2D, meshType, [vertexBufferType, indexBufferType]);
    library.addConstructor(&_newMesh3D, meshType, [vertexBufferType, indexBufferType]);
}

private void _newBufferElement(GrCall call) {
    BufferElement bufferElement = BufferElement(call.getString(0), call.getEnum!LayoutType(1), call.getInt(2));
    call.setNative(bufferElement);
}

private void _newBufferLayout(GrCall call) {
    BufferLayout bufferLayout = new BufferLayout(call.getList(0).getNatives!BufferElement());
    call.setNative(bufferLayout);
}

private void _newVertexBuffer(GrCall call) {
    VertexBuffer vertexBuffer = new VertexBuffer(call.getList(0).getNatives!float(), call.getNative!BufferLayout(1));
    call.setNative(vertexBuffer);
}

private void _newVertexBuffer2(GrCall call) {
    VertexBuffer vertexBuffer = new VertexBuffer(call.getList(0).getNatives!vec2(), call.getNative!BufferLayout(1));
    call.setNative(vertexBuffer);
}

private void _newVertexBuffer3(GrCall call) {
    VertexBuffer vertexBuffer = new VertexBuffer(call.getList(0).getNatives!vec3(), call.getNative!BufferLayout(1));
    call.setNative(vertexBuffer);
}

private void _newVertexBuffer4(GrCall call) {
    VertexBuffer vertexBuffer = new VertexBuffer(call.getList(0).getNatives!mat4(), call.getNative!BufferLayout(1));
    call.setNative(vertexBuffer);
}

private void _newVertexBuffer5(GrCall call) {
    VertexBuffer vertexBuffer = new VertexBuffer(call.getList(0).getNatives!Vertex(), call.getNative!BufferLayout(1));
    call.setNative(vertexBuffer);
}

private void _newVertexBuffer6(GrCall call) {
    VertexBuffer vertexBuffer = new VertexBuffer(call.getList(0).getNatives!AnimatedVertex(),
                                                 call.getNative!BufferLayout(1));
    call.setNative(vertexBuffer);
}

private void _newIndexBuffer(GrCall call) {
    IndexBuffer indexBuffer = new IndexBuffer(call.getList(0).getNatives!uint());
    call.setNative(indexBuffer);
}

private void _newMesh2D(GrCall call) {
    Mesh2D mesh = new Mesh2D(call.getNative!VertexBuffer(0), call.getNative!IndexBuffer(2));
    call.setNative(mesh);
}

private void _newMesh3D(GrCall call) {
    Mesh3D mesh = new Mesh3D(call.getNative!VertexBuffer(0), call.getNative!IndexBuffer(2));
    call.setNative(mesh);
}

// float[] vertices, BufferLayout layout_
// vec3[] vertices, BufferLayout layout_
// vec2[] vertices, BufferLayout layout_
// Vertex[] vertices, BufferLayout layout_
// AnimatedVertex[] animatedVertices, BufferLayout layout_
// mat4[] mat4s, BufferLayout layout_