cd ..
mkdir export

chcp 65001

echo "[ATELIER] Génération"
cd atelier
dub build --config=export --build=release -a=x86_64

echo "[ALMA] Génération"
cd ../alma
dub build --config=export --build=release -a=x86_64

echo "[ALCHIMIE] Génération"
cd ../alchimie
dub build --config=export --build=release -a=x86_64

echo "Archivage des ressources"
cd ../export
alchimie.exe pack "../codex" "codex.cmg"

echo "Copie des fichiers nécessaires"
copy ..\\libx86_64\\*.dll ..\\export


