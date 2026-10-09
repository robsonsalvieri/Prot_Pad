#Include 'TOTVS.ch'

/*{Protheus.doc} TMSAC40()
Geração de CIOT em Contingencia para Scheduler ou Menu.
@author Carlos Alberto Gomes Junior
@since 28/05/2026
*/
Function TMSAC40
    Local aErrCiot := {}
    If IsBlind()
        aErrCiot := totvs.protheus.supply.tms.integration.antt.JobContingencia()
    Else
        FWMsgrun(,{|| aErrCiot := totvs.protheus.supply.tms.integration.antt.JobContingencia()},;
                "Executando Job de contingência da ANTT. Geração de CIOT.", "Aguarde" )
        If !Empty(aErrCiot)
			TmsMsgErr(aErrCiot)
		EndIf
    EndIf
Return

/*{Protheus.doc} SchedDef()
Definições para Funcionalidade de Scheduler
@author Carlos Alberto Gomes Junior
@since 28/05/2026
*/
Static Function SchedDef()
    Local aParam := { "P","","DTQ",,"Job contingência CIOT - ANTT.",,.T.,.T.}
Return aParam

//MenuDef para não dar erro no menu
Static Function MenuDef()
    Local aRotina := {}
Return aRotina
