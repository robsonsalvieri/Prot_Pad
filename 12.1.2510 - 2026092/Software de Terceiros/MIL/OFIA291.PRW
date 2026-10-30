#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} OFIA291
Funcoes DMS - Chamadas pelo FINA440 ( COMISSAO )

@author Andre Luis Almeida
@since 30/06/2023
@version 1.0
@return NIL
/*/
Function OFIA291( cTipo , nRecNo )
Local lRetorno := .f.
If cTipo == "1" // verificar se o titulo deve ser considerado para comissao
	lRetorno := OA2910011_VER_GERACAO_SE1( nRecNo ) // verificação se o titulo deve ser considerado para comissao
EndIf
Return lRetorno

/*/{Protheus.doc} OA2910011_VER_GERACAO_SE1
	Chamada do FINA440 - função Fa440Comis - chamado no momento da verificação se o titulo deve ser considerado para comissao

	@author Andre Luis Almeida
	@since 30/06/2023
/*/
Function OA2910011_VER_GERACAO_SE1( nRecSE1 )
Local lRetorno := .f.
If nRecSE1 > 0
	DbSelectArea("SE1")
	DbGoto( nRecSE1 )
	lRetorno := !( SE1->E1_TIPO $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT ) // Desconsiderar os titulos de Abatimento
EndIf
Return lRetorno