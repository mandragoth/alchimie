module alchimie.constants;

version (Windows) {
    enum Alchimie_Alma_Exe = "alma.exe";
}
version (posix) {
    enum Alchimie_Alma_Exe = "alma";
}

enum Alchimie_Project_File = "alchimie.json";

enum Alchimie_Project_App = "app";

enum Alchimie_Project_Programs = "programs";

enum Alchimie_Project_Name = "name";

enum Alchimie_Project_Source = "source";

enum Alchimie_Project_Resources = "resources";
