#Include 'Protheus.ch'

Function GFEA116SCH(aParam)

	GFEA116IMP() // começa as importações

Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd := {}
	
	aParam := {;
	"P"                                 	,;  // Tipo: R para relatorio P para processo
	"GFEA116" 	,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GXI"                           	,;  // Alias
	aOrd                                	,;  // Array de ordens
	nil									,;
	}   
Return aParam
