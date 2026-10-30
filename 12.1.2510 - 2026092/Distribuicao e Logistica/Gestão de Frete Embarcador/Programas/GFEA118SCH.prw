#INCLUDE "PROTHEUS.CH"

//
// aParam: parametro enviado pelo schedule do protheus
// aParam[1]: Empresa 
// aParam[2]: Filial
//
Function GFEA118SCH(aParam)
	RPCSetType(3) // Tipo do licenciamento (necessário dessa forma)
	RpcSetEnv(aParam[1],aParam[2],,,"GFE") // Sobe o ambiente do protheus para a empresa/filial do processo do schedule
	
	GFEA118IMP() // começa as importações
	
	RpcClearEnv()
Return