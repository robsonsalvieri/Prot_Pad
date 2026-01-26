#Include "protheus.ch"
#Include "fwmvcdef.ch"
#Include "agdi080.ch"

/*/{Protheus.doc} AGDI080
Ponto de chamada no MenuDef do MATA103
@type function
@version 12
@author carlos.augusto
@since 08/09/2025
/*/
Function AGDI080()
	Local aRotina := {}
	If "AGRO" $ SUPERGETMV("MV_CADPROD", .F., "")
		AAdd(aRotina, {STR0001, "AGDI080TSS", 0, 4, 0, .F.}) //"Dados Guia/Receituário"
	EndIf
Return aRotina


/*/{Protheus.doc} AGDI080
Realizar a chamada da rotina agda080 para adicionar dados da guia de transito e receituario
@type function
@version 12
@author carlos.augusto
@since 08/09/2025
/*/
Function AGDI080TSS()
	If TableInDic("NER") .And. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_EMREC"))) > 0 .And. NCR->(FieldPos("NCR_EMGUIA")) > 0
		If AGDA080OPN()
			FWExecView( STR0001, "VIEWDEF.AGDA080", MODEL_OPERATION_UPDATE,,{|| .T.})
		Else
			Help( , , STR0005, ,STR0003, 1, 0, .F., , ,,,{STR0004})//Atenção Não há produtos configurados para preencher dados de Guia de Trânsito/Receituário. Verifique os campos no cadastro de produtos NCR_EMGUIA e NCR_EMREC.
		EndIf
	Else
		FWAlertInfo( STR0002 ) //"Ambiente desatualizado. Contate o suporte para aplicar o pacote de atualização com as tabelas NER e NCR."
	EndIf
Return

