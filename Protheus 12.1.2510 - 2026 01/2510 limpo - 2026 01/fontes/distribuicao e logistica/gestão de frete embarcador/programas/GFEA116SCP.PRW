#INCLUDE 'PROTHEUS.CH'

Function GFEA116SCP(aParam)

	GFEA116PRO() //Inicia o processamento

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
	"GXI"       ,;  // Alias
	aOrd        ,;  // Array de ordens
	Nil         ,;
	}

Return aParam