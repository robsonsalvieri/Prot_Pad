#INCLUDE 'PROTHEUS.CH'

Function GFEA055SCH(aParam)

	BatchProcess("GFEA055","GFEA055",,{||GFEA055PRE()}) //Processamento

Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd := {}

	aParam := {;
	"P"         ,;  // Tipo: R para relatorio P para processo
	"GFEA055"   ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GWJ"       ,;  // Alias
	aOrd        ,;  // Array de ordens
	Nil         ,;
	}

Return aParam
