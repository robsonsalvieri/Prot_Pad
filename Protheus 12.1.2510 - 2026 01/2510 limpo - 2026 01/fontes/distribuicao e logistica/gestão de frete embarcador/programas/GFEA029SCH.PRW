#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA029SCH
Função responsável pelo schedule

@author João Leonardo Schmidt
@since 11/03/2019
@version 1.0

/*/
//------------------------------------------------------------------- 
Function GFEA029SCH(aParam)
	RPCSetType(3) // Tipo do licenciamento (necessário dessa forma)
	RpcSetEnv(aParam[1],aParam[2],,,"GFE") // Sobe o ambiente do protheus para a empresa/filial do processo do schedule

	GFEA29VENC()
	GFEA29LEM()
	GFEA29NOV()
	GFEA029COT()
Return