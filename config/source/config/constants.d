module config.constants;

version (Windows) {
    enum Alchimie_Alma_Exe = "alma.exe";
}
version (posix) {
    enum Alchimie_Alma_Exe = "alma";
}

enum Alchimie_Version_Major = 0;
enum Alchimie_Version_Minor = 1;
enum Alchimie_Version_Display = "0.1";

/// Identifiant utilisé dans les fichiers devant être validés
enum Alchimie_Version_ID = Alchimie_Version_Major * 1000 + Alchimie_Version_Minor;

enum Alchimie_Project_File = "alchimie.json";

// alchimie.json
enum Alchimie_Project_DefaultConfiguration_Node = "defaultConfig";

enum Alchimie_Project_Configurations_Node = "configs";

enum Alchimie_Project_DefaultConfigurationName = "app";

enum Alchimie_Project_Name_Node = "name";

enum Alchimie_Project_Source_Node = "source";

enum Alchimie_Project_Resources_Node = "resources";

enum Alchimie_Project_Export_Node = "export";

enum Alchimie_Project_Window_Node = "window";

enum Alchimie_Project_Window_Enabled_Node = "enabled";

enum Alchimie_Project_Window_Title_Node = "title";

enum Alchimie_Project_Window_Width_Node = "width";

enum Alchimie_Project_Window_Height_Node = "height";

enum Alchimie_Project_Window_Icon_Node = "icon";

// Initialisation fenêtre
enum Alchimie_Window_Width_Default = 800;

enum Alchimie_Window_Height_Default = 600;

enum Alchimie_Window_Enabled_Default = true;

enum Alchimie_Window_Icon_Default = Alchimie_StandardLibrary_File ~ "/lapis.png";

/// GRB: **GR**imoire **B**ytecode
enum Alchimie_Bytecode_Extension = ".grb";

/// ACFG: **A**lchimie **C**on**F**iguration
enum Alchimie_Configuration_Extension = ".acf";

/// AME: **A**lchimie **M**achine **E**nvironement
enum Alchimie_Environment_Extension = ".ame";

/// ARC: **P**a**Q**ue**T**
enum Alchimie_Archive_Extension = ".pqt";

/// ARS: **A**lchimie **R**e**S**source
enum Alchimie_Resource_Extension = ".ars";

/// ARSC: **A**lchimie **R**e**S**source **C**ompiled
enum Alchimie_Resource_Compiled_Extension = ".arsc";

enum Alchimie_StandardLibrary_File = "codex";

enum Alchimie_StandardLibrary_Path = Alchimie_StandardLibrary_File ~ Alchimie_Archive_Extension;

enum Alchimie_Environment_MagicWord = "ame";

enum Alchimie_Resource_Compiled_MagicWord = "rscmp";
