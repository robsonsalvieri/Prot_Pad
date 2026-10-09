#Include 'Protheus.ch'

Function STFDefFont()

Local aFontes := {}
Local oFonte1
Local oFonte2
Local oFonte3

DEFINE FONT oFonte1 NAME "Arial" BOLD
DEFINE FONT oFonte2 NAME "Arial" SIZE 08,17 BOLD
DEFINE FONT oFonte3 NAME "Courier New"

aAdd(aFontes, oFonte1)
aAdd(aFontes, oFonte2)
aAdd(aFontes, oFonte3)

Return aFontes