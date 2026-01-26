#include 'protheus.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsAtuArte
Carrega Informações do arquivo de configuração
@author PLS Projetos
@since 07/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PrjTussAtu(oArtefato)

Local lRet	:= .F.
Default cDirTerm	:= ""
Default cVerAtual	:= ""


PLSIMPTERM(oArtefato:cDestino,oArtefato:cVersion)
lRet := .T.

Return lRet


