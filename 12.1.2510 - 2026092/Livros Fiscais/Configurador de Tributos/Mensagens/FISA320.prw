#Include 'Protheus.ch'

/*/{Protheus.doc} FISA320
Função chamada na consulta padrão CKA para a visualização do modelo decodedMessage.
@type function
@version 12.1.2410
@author Juliano Fernandes
@since 17/06/2025
/*/
Function FISA320()
Return

/*/{Protheus.doc} viewDef
Função que realiza a chamada da View do cadastro de Mensagens Decodificadas.
@type function
@version 12.1.2410
@author Juliano Fernandes
@since 17/06/2025
@Return object, View do cadastro de Mensagens Decodificadas.
/*/
Static Function viewDef() as object
Return totvs.protheus.backoffice.fiscal.configurador.messages.decodedmessage.viewDef()

/*/{Protheus.doc} A320Filter
Função de filtro das Consultas Padrão CKA e CJ82.
@type function
@version 12.1.2410
@author Juliano Fernandes
@since 17/06/2025
@Return character, Filtro da consulta padrão.
/*/
Function f320Filter() as character

	Local cFilter as character
	Local cField := ReadVar() as character

	If ( 'CJL_CODMSG' $ cField .And. Select('CJL') > 0 )
		cFilter := "CJ8->CJ8_CODREF == '" + CJL->CJL_CODMSG + "'"
	ElseIf ( 'F6_CODMSD' $ cField .And. Select('CKA') > 0 )
		cFilter := "CKA->CKA_IDTRIB == '" + CKA->CKA_IDTRIB + "'"
	EndIf

Return cFilter

/*/{Protheus.doc} f320Return
Função de retorno das Consulta Padrão CKA.
@type function
@version 12.1.2410
@author Juliano Fernandes
@since 17/06/2025
@Return character, Retorno da consulta padrão.
/*/
Function f320Return() as character

	Local cField := ReadVar() as character
	Local cContent as character

	If ( 'F6_CODMSD' $ cField)
		cContent := SF6->F6_CODMSD
	EndIf

Return cContent
