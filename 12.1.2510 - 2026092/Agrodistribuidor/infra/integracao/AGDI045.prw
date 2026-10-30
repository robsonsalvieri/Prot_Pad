#INCLUDE "TOTVS.CH"
#INCLUDE "AGDI045.ch"

/*/{Protheus.doc} AGDI045
Recebe uma SC9 que foi realizada liberação de estoque pelo MATA455 na funcionalidade Nova Liberaçao
@type method
@version P12
@author carlos.augusto
@since 17/03/2026
/*/
Function AGDI045(nRecnoSC9)
	Local lSIGAAGD   := SuperGetMV("MV_SIGAAGD", .F., .F.)
	Local aAreaSC9   := SC9->(GetArea())
	
	If !lSIGAAGD .Or. !TableInDic('NEU') .Or. !TableInDic('NET') .Or. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_EMREC"))) <= 0
		Return .T.
	EndIf

	SC9->(dbGoTo(nRecnoSC9))
	/* Produto deve emitir receita */
	DbSelectArea('NCR')
	NCR->(dbSetOrder(1)) // NCR_FILIAL+NCR_PROD
	If NCR->(dbSeek(FwxFilial("NCR") + SC9->C9_PRODUTO))
		If NCR->NCR_EMREC = '1'
			AGDHELP(STR0001, STR0002)//Atenção - "Liberação manual não permitida, pois o produto é controlado por Receituário Agronômico."
			Return .F.
		EndIf
	EndIf
	RestArea(aAreaSC9)
	
Return .T.

