#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFDAE            
Gera o registro DAE da DIEF-CE 
Registro tipo DAE - Documentos de Arrecadação Estadual  de débitos a serem restituídos

@author David Costa
@since  03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFDAE( nHandle, cAliasQry )

Local cNomeReg	:= "DAE"
Local cStrReg		:= ""
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro DAE, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence
	
	DbSelectArea("C2U")
	C2U->( DbSetOrder( 1 ) )

	If(C2U->(MsSeek(xFilial("C2U") + (cAliasQry)->(C2T_ID + C2T_CODAJU))))
		While C2U->(!Eof()) .And. C2U->(C2U_ID + C2U_CODAJU) == (cAliasQry)->(C2T_ID + C2T_CODAJU)
			
			DbSelectArea("C0R")
			C0R->( DbSetOrder( 6 ) )
			
			If(C0R->(MsSeek(xFilial("C0R") + C2U->C2U_DOCARR)))
				cStrReg	:= cNomeReg
				cStrReg	+= TAFDecimal(Val(C0R->C0R_NUMDA), 15, 0, Nil)			//Número do Documento  de Arrecadação
				cStrReg	+= TAFDecimal(C0R->C0R_VLDA, 13, 2, Nil)			//Valor recolhido
				cStrReg	+= CRLF
				
				AddLinDIEF( )
			
				WrtStrTxt( nHandle, cStrReg )
			EndIf
			
			DbCloseArea("C0R")
			
			C2U->(DbSkip())
		EndDo
	EndIf
	
	DbCloseArea("C2U")

Recover
	lError := .T.

End Sequence

ErrorBlock(oLastError)

Return( lError )
