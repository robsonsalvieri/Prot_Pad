#INCLUDE "PROTHEUS.CH"

Function GFEX101SCH()
	Private cGFETrace := GetPvProfString("General" , "GFETrace" , "ERROR" , GetAdv97() )
	
	GFEconout("INFO", "[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [START]")
 	While !KillApp()
		FwDateUpd(.T.)
		GFEX101ALL()
		
		If cGFETrace == "1"
			GFEconout("INFO", "[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [Nenhum documento pendente]")
		EndIf
		  	
	  	Sleep(40000)
	EndDo
	GFEconout("INFO", "[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [STOP]")
	
Return

Static Function SchedDef()
	
	Local aParam
	Local aOrd   := {}
	
	aParam := {;
				"P"       ,;  // Tipo: R para relatorio P para processo
				"PARAMDEF",;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
				"1"       ,;  // Alias
				""        ,;  // Array de ordens
			  }   

Return aParam
