#Include "Protheus.ch"  

//-----------------------------------------------------------------
/*/{Protheus.doc} autoNfeTrans
Execucao do processo de transmissao do autoNFe via schedule.
@param cProcesso 1 - Transmissao, 2 - Monitoramento, 3 - Cancelamento
@param cSerie  MV_PAR01, serie utilizada na transmissão automatica 

@author  Sergio S. Fuzinaka
@since   11/02/2014
@version 12
/*/
//-----------------------------------------------------------------
function autoNfeTrans()

	local cProcesso := "1" 	// Transmissao
	local cSerie	:= MV_PAR01
    local nThreads  := iif(type("MV_PAR02") == "N" ,MV_PAR02, nil)

	validaAutoNfe( cProcesso, cEmpAnt, cFilAnt, cSerie, nil, nThreads )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aReturn			Array com os parametros

@author  Sergio S. Fuzinaka
@since   30/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "AUTONFE   ",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam