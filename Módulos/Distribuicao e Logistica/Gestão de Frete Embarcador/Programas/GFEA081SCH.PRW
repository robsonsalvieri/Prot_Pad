#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GFEA081SCH
Função responsável por executar o calculo de frete via schedule conforme parametros informados

@author Jefferson Hita
@since 02/08/2024
@version 1.0

/*/
//------------------------------------------------------------------- 
Function GFEA081SCH(aParam)
	GFEA081()
Return

Static Function SchedDef()
	Local aParam := {"P"      ,;  // Tipo: R para relatorio P para processo
				     "GFEA081",;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
					 "1"      ,;  // Alias
					 ""       ,;  // Array de ordens
			  		}   

Return aParam
