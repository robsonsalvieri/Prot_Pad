#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFIDA            
Gera o registro IDA da DIEF-CE 
Registro tipo IDA - Inscrições  na Dívida Ativa a serem compensadas

@author David Costa
@since  03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFIDA( nHandle, cAliasQry )

Local cNomeReg	:= "IDA"
Local cStrReg		:= ""
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro IDA, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence
	
	DbSelectArea("C2U")
	C2U->( DbSetOrder( 1 ) )

	If(C2U->(MsSeek(xFilial("C2U") + (cAliasQry)->(C2T_ID + C2T_CODAJU))))
		While C2U->(!Eof()) .And. C2U->(C2U_ID + C2U_CODAJU) == (cAliasQry)->(C2T_ID + C2T_CODAJU)
			
			DbSelectArea("T33")
			T33->( DbSetOrder( 2 ) )
			
			If(T33->(MsSeek(xFilial("T33") + C2U->C2U_CODDIV)))
				cStrReg	:= cNomeReg
				cStrReg	+= TAFDecimal(T33->T33_NDIV, 15, 0, Nil)			//Número da inscrição na dívida ativa
				cStrReg	+= TAFDecimal(T33->T33_VLRDIV, 13, 2, Nil)		//Valor a ser compensado para a inscrição
				cStrReg	+= CRLF
				
				AddLinDIEF( )
			
				WrtStrTxt( nHandle, cStrReg )
			EndIf
			
			DbCloseArea("T33")
			
			C2U->(DbSkip())
		EndDo
	EndIf
	
	DbCloseArea("C2U")

Recover
	lError := .T.
	
End Sequence

ErrorBlock(oLastError)

Return( lError )