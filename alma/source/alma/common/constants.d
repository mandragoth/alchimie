module alma.common.constants;

enum Alma_Version_Major = 0;
enum Alma_Version_Minor = 1;
enum Alma_Version_Display = "0.1";

/// Identifiant utilisé dans les fichiers devant être validés
enum Alma_Version_ID = Alma_Version_Major * 1000 + Alma_Version_Minor;

/// AME: **A**lchimie **M**achine **E**nvironement **E**xécutable
enum Alma_Bytecode_Extension = ".ame";

/// ACFG: **A**lchimie **C**on**F**i**G**uration
enum Alma_Configuration_Extension = ".acfg";

/// AMI: **A**lchimie **M**achine **I**ninitalisation
enum Alma_Initialization_Extension = ".ami";
