#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFREF
Gera o registro REF da DIEF-CE - Documentos Fiscais Referidos
Informar os bilhetes de passagem em caso de RMD, número do Cupom Fiscal em caso de acobertamento e 
número das notas filhas para Nota Englobadora de venda fora do estabelecimento.

@author David Costa
@since  02/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFREF( nHandle, cAliasQry )

Local aICMSItem	:= {}
Local cNomeReg	:= "REF"
Local cStrReg		:= ""
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro REF, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence

	If( !Empty((cAliasQry)->C20_CHVNF) .And. (cAliasQry)->C20_INDOPE == "1" )
		DbSelectArea("C26")
		C26->( DbSetOrder( 1 ) )
		
		If(C26->(MsSeek(xFilial("C26") + (cAliasQry)->C20_CHVNF)))
		
			While C26->(!Eof()) .And. (cAliasQry)->C20_CHVNF == C26->C26_CHVNF
			
				cStrReg	:= cNomeReg
				cStrReg	+= GetModelo( C26->C26_CODMOD )									//Código do modelo do documento
				cStrReg	+= PadR(C26->C26_SERIE, 5)										//Série do documento  fiscal.
				cStrReg	+= PadR(C26->C26_SUBSER, 5)										//Sub-série  do documento  fiscal
				cStrReg	+= TAFDecimal(Val(C26->C26_NUMDOC), 10, 0, Nil)				//Número inicial do documento  fiscal.
				cStrReg	+= TAFDecimal(Val(C26->C26_NUMDOC), 10, 0, Nil)				//Número final do documento  fiscal.
				cStrReg	+= TAFDecimal(Val(C26->C26_CODMOT), 2, 0, Nil)				//Código do motivo da referência
				cStrReg	+= GetAIDF(cAliasQry)											//Número AIDF
				cStrReg	+= PadR(C26->C26_DESMOT, 100)									//Texto de observação da referencia
				cStrReg	+= GetTpDisp( C26->C26_AIDF, C26->C26_CODMOD )				//Tipo de dispositivo  autorizado
				cStrReg	+= GetNumAIDF( cAliasQry )										//Número inicial e final do dispositivo autorizado
				cStrReg	+= CRLF
				
				C26->(DbSkip())
				
				AddLinDIEF( )
				
				WrtStrTxt( nHandle, cStrReg )
			EndDo
		EndIf
		
		DbCloseArea("C26")

		DbSelectArea("C27")
		C27->( DbSetOrder( 1 ) )
		
		If(C27->(MsSeek(xFilial("C27") + (cAliasQry)->C20_CHVNF)))
		
			While C27->(!Eof()) .And. (cAliasQry)->C20_CHVNF == C27->C27_CHVNF
			
				cStrReg	:= cNomeReg
				cStrReg	+= GetModelo( C27->C27_CODMOD )									//Código do modelo do documento
				cStrReg	+= PadR("", 5)													//Série do documento  fiscal.
				cStrReg	+= PadR("", 5)													//Sub-série  do documento  fiscal
				cStrReg	+= TAFDecimal(Val(C27->C27_NUMDOC), 10, 0, Nil)				//Número inicial do documento  fiscal.
				cStrReg	+= TAFDecimal(Val(C27->C27_NUMDOC), 10, 0, Nil)				//Número final do documento  fiscal.
				cStrReg	+= TAFDecimal(4, 2, 0, Nil)										//Código do motivo da referência
				cStrReg	+= StrZero(0, 11)													//Número AIDF
				cStrReg	+= PadR("", 100)													//Texto de observação da referencia
				cStrReg	+= GetTpDisp( "", C27->C27_CODMOD )							//Tipo de dispositivo  autorizado
				cStrReg	+= StrZero(0, 20)													//Número inicial e final do dispositivo autorizado
				cStrReg	+= CRLF
				
				C27->(DbSkip())
				
				AddLinDIEF( )
				
				WrtStrTxt( nHandle, cStrReg )
			EndDo
		EndIf
		
		DbCloseArea("C26")
	EndIf

Recover
	lError := .T.

End Sequence

ErrorBlock(oLastError)

Return( lError )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetModelo             
Retorna o modelo do documento fiscal

@author David Costa
@since  02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetModelo( IdModelo )

Local cModelo	:= ""

If( !Empty(IdModelo))
	DbSelectArea("C01")
	C01->( DbSetOrder( 3 ) )
	
	If(C01->(MsSeek(xFilial("C01") + IdModelo)))
		cModelo := C01->C01_CODIGO
	EndIf
	
	DbCloseArea("C01")
EndIf
cModelo := PadR(Val(cModelo),2 )

Return(cModelo)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAIDF             
Retorna o numero AIDF

@author David Costa
@since  02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAIDF( ) 

Local cAIDF	:= ""

If( !Empty(C26->C26_AIDF))
	DbSelectArea("C0T")
	C0T->( DbSetOrder( 1 ) )
	
	If(C0T->(MsSeek(xFilial("C0T") + C26->C26_AIDF)))
		cAIDF := AllTrim(C0T->C0T_NUNAUT)
	EndIf
	
	DbCloseArea("C0T")
EndIf

cAIDF := StrZero(Val(cAIDF), 11)	

Return(cAIDF)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpDisp             
Espécie de dispositivo  autorizado,  vide tabela 05.
Preencher com ZERO, quando o Regime de Pagamento for ME, MS, Especial e Outros

01	Blocos
02	Formulário contínuo
03	Formulário de segurança
04	Jogos soltos
05	ECF
06	Nota Fiscal Eletrônica
07	Conhecimento de Transporte Eletrônico 

@author David Costa
@since  02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetTpDisp( IdAIDF, IdModelo ) 		

Local cTpDisp		:= "00"

If(GetModelo( IdModelo ) == "55")
	cTpDisp := "06"
ElseIf( !Empty(IdAIDF))
	DbSelectArea("C0T")
	C0T->( DbSetOrder( 1 ) )
	
	If(C0T->(MsSeek(xFilial("C0T") + IdAIDF)))
		If(!Empty(C0T->C0T_CODISP))
			DbSelectArea("C6C")
			C6C->( DbSetOrder( 3 ) )
			
			If(C6C->(MsSeek(xFilial("C6C") + C0T->C0T_CODISP)))
				If(AllTrim(C6C->C6C_CODIGO) == "04")
					cTpDisp := "01"
				ElseIf(AllTrim(C6C->C6C_CODIGO) == "03")
					cTpDisp := "02"
				ElseIf(AllTrim(C6C->C6C_CODIGO) == "00")
					cTpDisp := "03"
				ElseIf(AllTrim(C6C->C6C_CODIGO) == "05")
					cTpDisp := "04"
				ElseIf(AllTrim(C6C->C6C_CODIGO) == "06")
					cTpDisp := "05"
				ElseIf(AllTrim(C6C->C6C_CODIGO) == "02")
					cTpDisp := "06"
				ElseIf(AllTrim(C6C->C6C_CODIGO) == "07")
					cTpDisp := "07"
				EndIf
			EndIf
			
			DbCloseArea("C6C")
		EndIf
	EndIf
	
	DbCloseArea("C0T")
ElseIf(GetModelo( IdModelo ) == "37")
	cTpDisp := "05"
EndIf

Return( cTpDisp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumAIDF             
Retorna o numero inicial e final autorizado pela AIDF

@author David Costa
@since  02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNumAIDF( cAliasQry ) 

Local cNumIni		:= ""
Local cNumFim		:= ""
Local cNumAIDF	:= ""

If( !Empty(C26->C26_AIDF))
	DbSelectArea("C6V")
	C6V->( DbSetOrder( 1 ) )
	
	If(C6V->(MsSeek(xFilial("C6V") + C26->C26_AIDF)))
		While C6V->(!Eof()) .And. (cAliasQry)->C6V_ID == C26->C26_AIDF
			If(C6V->C6V_CODMOD == C26->C26_CODMOD)
				cNumIni := AllTrim(C6V->C6V_NDIINI)
				cNumFim := AllTrim(C6V->C6V_NDIFIN)
				exit
			EndIf
			C6V->(DbSkip)
		EndDo
	EndIf
	
	DbCloseArea("C6V")
EndIf

cNumAIDF := StrZero(Val(cNumIni), 10)
cNumAIDF += StrZero(Val(cNumFim), 10)
	

Return(cNumAIDF)
