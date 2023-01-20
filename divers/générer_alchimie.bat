cd ..
mkdir export
mkdir export/res

echo "Génération d’Atelier"
cd atelier
dub build --config=export -a=x86_64

echo "Génération d’Alchimie"
cd ../alchimie
dub build --config=export_dev -a=x86_64
dub build --config=export_dist -a=x86_64

echo "Copie des fichiers nécessaires"
copy ..\\libx86_64\\*.dll ..\\export
copy ..\\res\\* ..\\export\\res


