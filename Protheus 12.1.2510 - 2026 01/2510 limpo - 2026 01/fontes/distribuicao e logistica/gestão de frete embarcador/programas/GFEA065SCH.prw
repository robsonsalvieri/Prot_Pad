#INCLUDE 'PROTHEUS.CH'

Function GFEA065SCH(aParam)

	GFEA065GFF(.F.)

Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd := {}

	aParam := {;
	"P"         ,;  // Tipo: R para relatorio P para processo
	"GFEA065GFF"   ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GW3"       ,;  // Alias
	aOrd        ,;  // Array de ordens
	Nil         ,;
	}

Return aParam