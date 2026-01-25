#Include 'Protheus.ch'

Function GFEA117SCH(aParam)

	GFEA117IMP() // começa as importações

Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd := {}
	
	aParam := {;
	"P"                                 	,;  // Tipo: R para relatorio P para processo
	"GFEA117" 	,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GXL"                           	,;  // Alias
	aOrd                                	,;  // Array de ordens
	nil									,;
	}   
Return aParam
   