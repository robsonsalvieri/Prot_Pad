#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFDCT
Gera o registro DCT da DIEF-CE 
Registro tipo DCT - Detalhe do conhecimento de transporte
Obrigatório para o emitente quando o modelo citado no registro DOC 
(campo 3) for 8, 9, 10 ou 11, vide tabela 21.

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFDCT( nHandle, cAliasQry )

Local cNomeReg	:= "DCT"
Local cStrReg		:= ""
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro DCT, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence

	If((cAliasQry)->C01_CODIGO $ ("|08|09|10|11|"))
		DbSelectArea("C3A")
		DbSetOrder(1)
		If(C3A->(MsSeek(xFilial("C3A") + (cAliasQry)->C20_CHVNF)))
			While C3A->(!Eof()) .And. C3A->C3A_CHVNF == (cAliasQry)->C20_CHVNF
				
				cStrReg	:= cNomeReg
				cStrReg	+= GetMunPar(C3A->C3A_CPARCO)								//município  de coleta
				cStrReg	+= GetUFPar(C3A->C3A_CPARCO)								//UF de coleta
				cStrReg	+= GetMunPar(C3A->C3A_CPAREN)								//município  de entrega
				cStrReg	+= GetUFPar(C3A->C3A_CPAREN)								//UF de entrega
				cStrReg	+= TAFDecimal(GetQtd(cAliasQry), 13, 2, Nil)				//Quantidade  das mercadorias.
				cStrReg	+= GetUN(cAliasQry)											//e Unidade de transporte
				cStrReg	+= CRLF
				
				AddLinDIEF( )
				
				WrtStrTxt( nHandle, cStrReg )
				
				C3A->(DbSkip())
				
			EndDo
		EndIf
		
		DbCloseArea("C3A")
		
	EndIf

Recover
	lError := .T.

End Sequence

ErrorBlock(oLastError)

Return( lError )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMunPar             
Retorna o codigo do municipio do Participante

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetMunPar( cIDPar )

Local cCodMun	:= ""

DbSelectArea("C1H")
C1H->( DbSetOrder( 5 ) )
			
If(C1H->(MsSeek( xFilial( "C1H" ) + cIDPar )))
	DbSelectArea("C07")
	C07->( DbSetOrder( 3 ) )
	
	If(C07->(MsSeek( xFilial( "C07" ) + C1H->C1H_CODMUN)))
		cCodMun := C07->C07_CODIGO
	EndIf
	
	DbCloseArea("C07")
	
EndIf

DbCloseArea("C1H")

If(Empty(cCodMun))
	cCodMun := StrZero(0,5)
Else
	cCodMun := StrZero(Val(cCodMun),5)	
EndIf

Return( cCodMun )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUFPar
Retorna a UF do Participante

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetUFPar( cIDPar )

Local cUF	:= ""

DbSelectArea("C1H")
C1H->( DbSetOrder( 5 ) )
			
If(C1H->(MsSeek( xFilial( "C1H" ) + cIDPar )))
	cUF := TAFGetUF(C1H->C1H_UF)
EndIf

DbCloseArea("C1H")

cUF := PadR(cUF, 2)

Return( cUF )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQtd             
Quantidade  das mercadorias.

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetQtd( cAliasQry )

Local nQtd		:= 0

If( !Empty((cAliasQry)->C20_CHVNF))
	DbSelectArea("C30")
	C30->( DbSetOrder( 1 ) )
	
	If(C30->(MsSeek(xFilial("C30")+(cAliasQry)->C20_CHVNF)))
	
		While C30->(!Eof()) .And. (cAliasQry)->C20_CHVNF == C30->C30_CHVNF
			nQtd += C30->C30_QUANT
			C30->(DbSkip())
		EndDo
	EndIf
	DbCloseArea("C30")
EndIf

Return( nQtd )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUN             
"Unidade de transporte:
1 - KG (Quilograma)
2 - M3 (metro cúbico) ou L (litro)"

@author David Costa
@since  01/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetUN( cAliasQry )

Local cUN	:= ""

cUN	:= Space(1)

Return( cUN )

