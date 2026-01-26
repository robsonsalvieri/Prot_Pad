#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDFCTD             
Gera o registro CTD da DIEF-CE 
Registro tipo CTD - Contador

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  17/07/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDFCTD( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "CTD"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local lC2J			:= .F.
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro CTD, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence
	
	If(!Empty(aWizard[1][10]))
		DbSelectArea("C2J")
		C2J->( DbSetOrder( 5 ) )
		
		If( C2J->(MsSeek( xFilial( "C2J" ) + aWizard[1][10] )))
		
			cStrReg	:= cNomeReg
			cStrReg	+= PadR(GetIdCTD(), 14)								//Identificador do contabilista
			cStrReg	+= GetTpId()											//Tipo de Identificador do Contabilista
			cStrReg	+= PadR(C2J->C2J_NOME, 40)							//Nome
			cStrReg	+= PadR(C2J->C2J_CRC, 15) 							//CRC do Contabilista
			cStrReg	+= PadR(C2J->C2J_END, 40) 							//Logradouro do Contabilista
			cStrReg	+= PadR(C2J->C2J_NUM, 5) 							//Numero do endereço
			cStrReg	+= PadR(C2J->C2J_COMPL, 20)							//Complemento do endereço
			cStrReg	+= PadR(C2J->C2J_BAIRRO, 15)						//Bairro do Contabilista
			cStrReg	+= StrZero(Val(C2J->C2J_CEP), 8) 					//CEP do Contabilista
			cStrReg	+= GetCodMun()			 							//Municipio do Contabilista
			cStrReg	+= PadR(TAFGetUF(C2J->C2J_UF), 2) 					//UF do Contabilista
			cStrReg	+= PadR(C2J->C2J_EMAIL, 50) 						//Email do Contabilista
			cStrReg	+= PadR(C2J->C2J_DDD + C2J->C2J_FONE, 12) 		//Telefone  do Contabilista
			cStrReg	+= PadR(C2J->C2J_DDDFAX + C2J->C2J_FAX, 12) 		//Fax do Contabilista
			cStrReg	+= CRLF
			
			AddLinDIEF( )
			
			WrtStrTxt( nHandle, cStrReg )
			
			GerTxtReg( nHandle, cTXTSys, cNomeReg )
		Else
			AddLogDIEF("Registro CTD: O contador informado não foi encontrado.")
		EndIf
		
		DbCloseArea("C2J")
	EndIf
	
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()
	
Recover
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

End Sequence

ErrorBlock(oLastError)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIdCTD             
Retorna o Identificador do Contabilista Conforme definições da DIEFE-CE

@author David Costa
@since  21/07/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GetIdCTD()
Local cIdCTD	:= ""

If (C2J->C2J_TPESTA == "2")
	cIdCTD := C2J->C2J_CNPJ
ElseIf (C2J->C2J_TPESTA == "1")
	cIdCTD := C2J->C2J_CPF
Else
	cIdCTD := Space(1)
EndIf

Return (cIdCTD) 

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTpId             
Retorna o Tipo do Identificador do Contabilista Conforme definições da DIEFE-CE

@author David Costa
@since  21/07/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GetTpId()
Local cTpId	:= ""

If (C2J->C2J_TPESTA == "2")
	cTpId := "2"
ElseIf (C2J->C2J_TPESTA == "1")
	cTpId := "3"
Else
	cTpId := "0"
EndIf

Return (cTpId) 

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodMun             
Retorna o Código do municipio do Contabilista Conforme definições da DIEFE-CE

@author David Costa
@since  21/07/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GetCodMun()
Local nCodMun		:= 0
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cAliasQry	:=	GetNextAlias()
Local cTabela		:= ""

cTabela := RetSqlName("C07")

cSelect := cTabela + ".C07_CODIGO "
cFrom   := cTabela
cWhere  := cTabela + ".D_E_L_E_T_='' AND " + cTabela + ".C07_ID = '" + C2J->C2J_CODMUN + "' "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

DbSelectArea(cAliasQry) 
nCodMun := Val((cAliasQry)->C07_CODIGO)

(cAliasQry)->(dbclosearea())

nCodMun := StrZero(nCodMun, 5)

Return (nCodMun) 

