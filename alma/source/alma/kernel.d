module alma.kernel;

version(AlmaMagia) {
    public import magia;
    alias Kernel = Magia;
}
else version(AlmaRuna) {
    public import runa;
    alias Kernel = Runa;
}