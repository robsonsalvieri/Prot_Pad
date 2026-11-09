#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFPAR           
Gera o registro PAR da DIEF-CE 
Registro tipo PAR - Participante do Documento Fiscal

@author David Costa
@since  04/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFPAR( nHandle, cAliasQry )

Local cNomeReg	:= "PAR"
Local cStrReg		:= ""
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro PAR, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence

	If( !Empty((cAliasQry)->C20_CODPAR))
		DbSelectArea("C1H")
		C1H->( DbSetOrder( 5 ) )
		
		If( C1H->(MsSeek( xFilial( "C1H" ) + (cAliasQry)->C20_CODPAR )))
			
			cStrReg	:= cNomeReg
			cStrReg	+= GetCondPar( cAliasQry )						//Condição do participante informado no documento
			cStrReg	+= GetDocPar()									//CNPJ ou CPF do participante
			cStrReg	+= PadR(AllTrim(C1H->C1H_IE), 20)				//Inscrição Estadual do participante
			cStrReg	+= PadR(AllTrim(C1H->C1H_NOME), 60)			//Nome ou Razão Social.
			cStrReg	+= PadR(TAFGetUF( C1H->C1H_UF ), 2)			//Sigla da unidades da federação.
			cStrReg	+= StrZero(Val(C1H->C1H_SUFRAM), 14)			//Inscrição na SUFRAMA
			cStrReg	+= CRLF

			AddLinDIEF( )
			
			WrtStrTxt( nHandle, cStrReg )
		
		EndIf
		
		DbCloseArea("C1H")
	EndIf

Recover
	lError := .T.
		
End Sequence

ErrorBlock(oLastError)

Return( lError )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCondPar             
Condição  do participante  informado  no documento,  vide tabela 12.

01	Emitente do documento fiscal
02	Remetente das mercadorias ou prestador de serviços – não emitente
03	Destinatário das mercadorias ou tomador de serviços
04	Consignatário das mercadorias
06	Consignante das mercadorias

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCondPar( cAliasQry )

Local cCondPar	:= "00"

If((cAliasQry)->C20_INDOPE == "0" .And. TAFCFOPCon( (cAliasQry)->C0Y_CODIGO ))
	cCondPar	:= "06"
ElseIf((cAliasQry)->C20_INDOPE == "1" .And. TAFCFOPCon( (cAliasQry)->C0Y_CODIGO ))
	cCondPar	:= "04"
ElseIf((cAliasQry)->C20_INDEMI == "1" .And. (cAliasQry)->C20_INDOPE == "0")
	cCondPar	:= "01"
ElseIf((cAliasQry)->C20_INDEMI == "0" .And. (cAliasQry)->C20_INDOPE == "0")
	cCondPar	:= "02"
ElseIf((cAliasQry)->C20_INDEMI == "0" .And. (cAliasQry)->C20_INDOPE == "1")
	cCondPar	:= "03"
EndIf

Return( cCondPar )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDocPar             
CNPJ ou CPF do participante. Tratando-se  de operações  com o exterior ou com pessoa física não inscrita no CPF,
informar o campo em branco.

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetDocPar( )

Local cDocPar	:= ""

If(C1H->C1H_PPES == "1") // PF
	cDocPar := AllTrim(C1H->C1H_CPF)
ElseIf(C1H->C1H_PPES == "2") // PJ
	cDocPar := AllTrim(C1H->C1H_CNPJ)
EndIf

cDocPar := PadR(cDocPar, 14)

Return( cDocPar )
