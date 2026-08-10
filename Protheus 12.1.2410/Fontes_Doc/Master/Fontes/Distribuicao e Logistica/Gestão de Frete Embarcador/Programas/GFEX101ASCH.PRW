#INCLUDE "PROTHEUS.CH"

Function GFEX101ASCH()
    Local nI          := 0
    Local cAuxFil     := cFilAnt
    Local aAuxFil     := FWLoadSM0()

	GFEconout("INFO", "[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [START]")

    For nI := 1 To Len(aAuxFil)
        If aAuxFil[nI][2] >= MV_PAR01 .And. aAuxFil[nI][2] <= MV_PAR02
            // Setando filial do processamento
            cFilAnt := aAuxFil[nI][2]

            GFEconout("INFO", "[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [AUTO START]")

            FwDateUpd(.T.)
            GFEX101ALL()

            Sleep(40000)
        EndIf
    Next

    cFilAnt := cAuxFil
	GFEconout("INFO", "[" + Time() + "] [GFEX101SCH] Empresa/Filial: " + cEmpAnt + "/" + cFilAnt + " [STOP]")
	
Return

Static Function SchedDef()
	Local aParam
	//Local aOrd   := {}
	
	aParam := {	"P"      ,;  // Tipo: R para relatorio P para processo
				"GFEX101",;   // Pergunte do relatorio, caso nao use passar "PARAMDEF"
				"1"      ,;  // Alias
				""       ,;  // Array de ordens
			  }   

Return aParam
