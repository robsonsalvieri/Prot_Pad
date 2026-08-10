#Include "Protheus.ch"
#Include "FwMvcDef.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CENHISTMON
Descricao: Historico 

@author Hermiro Júnior
@since 02/09/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CENHISTMON(lAutom)
    Default lAutom  := .F.

    //A chamada desta função saiu do PLSMVCCOMPROM. Agora está dentro do menu (Miscelania/Central de Obrigações/Monitoramento/Guia)
    //Chama as Rotinas Corretas Baseadas na Escolha do Histórico.
    CENMVCBRF('','Guias',"1",lAutom)
 
Return