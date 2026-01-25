#INCLUDE 'PROTHEUS.CH'

Function GFEA115SCP(aParam)

	GFEA115PRO() //Inicia o processamento

Return

//-------------------------------------------------------
//Função SchedDef
//-------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}
	Local aOrd   := {}

	aParam := {;
	"P"         ,;  // Tipo R para relatorio P para processo
	"PARAMDEF"  ,;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
	"GXG"       ,;  // Alias
	aOrd        ,;  // Array de ordens
	Nil         ,;
	}

Return aParam