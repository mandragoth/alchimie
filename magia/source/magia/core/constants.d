module magia.core.constants;

version (Windows) {
    enum Alchimie_Exe = "redist.exe";
    enum Alchimie_Library = "alchimie.dll";
}
version (posix) {
    enum Alchimie_Exe = "redist";
    enum Alchimie_Library = "alchimie.so";
}

enum Alchimie_Version_Major = 0;
enum Alchimie_Version_Minor = 1;
enum Alchimie_Version_Display = "0.1";

/// Identifiant utilisé dans les fichiers devant être validés
enum Alchimie_Version_ID = Alchimie_Version_Major * 1000 + Alchimie_Version_Minor;

enum Alchimie_Project_File = "alchimie.ffd";

// Initialisation fenêtre
enum Alchimie_Window_Width_Default = 800;

enum Alchimie_Window_Height_Default = 600;

enum Alchimie_Window_Enabled_Default = true;

enum Alchimie_Window_Icon_Default = Alchimie_StandardLibrary_File ~ "/lapis.png";

/// Fichier de configuration
enum Alchimie_Configuration_Extension = ".acf";

/// Fichier d’application
enum Alchimie_Application_Extension = ".alchimie";

/// Fichier de données
enum Alchimie_Archive_Extension = ".pqt";

/// Fichier de ressource farfadet
enum Alchimie_Resource_Extension = ".ffd";

/// Fichier de ressource compilé
enum Alchimie_Resource_Compiled_Extension = ".ffdt";

enum Alchimie_Environment_MagicWord = "alchimie";

enum Alchimie_Resource_Compiled_MagicWord = "farfadet";

enum Alchimie_StandardLibrary_File = "codex";

enum Alchimie_StandardLibrary_Path = Alchimie_StandardLibrary_File ~ Alchimie_Archive_Extension;

static immutable Alchimie_Dependencies = [
    "SDL2.dll", "SDL2_image.dll", "SDL2_ttf.dll"
];
