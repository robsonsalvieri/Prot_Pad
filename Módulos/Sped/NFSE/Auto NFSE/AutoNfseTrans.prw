#Include "Protheus.ch"  
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} AutoNFSeTrans
Execucao do processo de Transmissao do Auto NFS-e via schedule.
@param cProcesso 1 - Transmissao, 2 - Monitoramento, 3 - Cancelamento
@param cSerie  MV_PAR01, serie utilizada na transmissão automatica 

@author  Felipe Duarte Luna
@since   29/10/2021
@version 12.1.33
/*/
//-----------------------------------------------------------------
function AutoNfseTrans()

	Local cProcesso := "1" 	// Transmissao
	Local cSerie	:= MV_PAR01
    Local nThreads  := Iif( Type("MV_PAR02") == "N" .And. !Empty(MV_PAR02), MV_PAR02, 1)
    Local nLote     := Iif( Type("MV_PAR03") == "N" .And. !Empty(MV_PAR03), MV_PAR02, 1)
  
   

    AutoNfseValida( cEmpAnt, cFilAnt, cProcesso, cSerie, nThreads, nLote)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule, recebendo parâmetros do SX1.

@return aReturn			Array com os parametros

@author  Felipe Duarte Luna
@since   29/10/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "JOBAUTNFSE",;	//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam

