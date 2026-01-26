#Include 'Protheus.ch'

Function GFEA115SCH(aParam)

	GFEA115IMP() // começa as importações

Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd := {}
	
	aParam := {	 ;
	"P"         ,;  // Tipo: R para relatorio P para processo
	"GFEA115" 	,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GXG"       ,;  // Alias
	aOrd        ,;  // Array de ordens
	nil			,;
	}   
Return aParam