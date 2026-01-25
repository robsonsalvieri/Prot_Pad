#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFLEX           
Gera o registro LEX da DIEF-CE 
Registro tipo LEX - Lançamento extemporâneo (valores não lançados em exercícios anteriores)

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFLEX( aWizard, cRegime )
Local cNomeReg	:= "LEX"
Local cStrReg		:= ""
Local cAliasQry	:= GetNextAlias()
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro LEX, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence
	
	QryLEX( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
		cStrReg	:= cNomeReg
		cStrReg	+= (cAliasQry)->DATA										//Periodo de referência
		cStrReg	+= TAFDecimal((cAliasQry)->C20_VLDOC, 13, 2, Nil)	//Valor da operação
		cStrReg	+= CRLF
	
		AddLinDIEF( )
	
		WrtStrTxt( nHandle, cStrReg )
		
		( cAliasQry )->( dbSkip() )
		
	EndDo
	
	( cAliasQry )->( dbCloseArea())
	
	//Informar valores extemporâneos manualmente
	If( aWizard[1][15] )
		GetLexManu( nHandle )
	EndIf
	
	GerTxtReg( nHandle, cTXTSys, cNomeReg )

End Sequence

ErrorBlock(oLastError)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryLEX             
Seleciona os dados para geração do registro LEX 

@author David Costa
@since  02/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryLEX( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " SUBSTRING(C20_DTES, 1, 6) DATA, C20_VLDOC "
cFrom   	:= RetSqlName("C20") + " C20 "
cFrom   	+= " JOIN " + RetSqlName("C02") + " C02 "
cFrom   	+= " 	ON C02.D_E_L_E_T_ = '' "
cFrom   	+= " 		AND C02_ID = C20_CODSIT "
cWhere  	:= " C20.D_E_L_E_T_ = '' "
cWhere  	+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere  	+= " AND C20_DTEXT BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere  	+= " AND C20_INDOPE = 0 "			//Lançamentos de Entrada
cWhere  	+= " AND C02_CODIGO IN ('01','07') "

cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLexManu             
Preenche manualmente o registro LEX através de dados informados pelo usuario 

@author David Costa
@since  05/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function GetLexManu( nHandle )

Local nOpc := GD_INSERT+GD_UPDATE+GD_DELETE

Private cCadastro := "Lançamentos extemporâneos"
Private oDlg
Private oGetDB
Private noBrw := 0
Private aHeader := {}
Private aCols := {}

GetHeadCols()

oDlg := MSDialog():New( 091,232,502,820,"Registro LEX",,,.F.,,,,,,.T.,,,.T. )

oGetDB := MsNewGetDados():New(024,016,216,368,nOpc,"RegLexOK","AllwaysTrue", "",{"DFCE_VAL", "DFCE_PER"} ,;
0 , 99, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeader, aCols)

oGetDB:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg:bInit := EnchoiceBar(oDlg,{|| VldGridLEX( nHandle, .T. ),VldGridLEX( nHandle, .F. )},{|| oDlg:End()})
oDlg:lCentered := .T.
oDlg:Activate()

Return oGetDB

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGridLEX             
Valida se os dados da Grid estão integros para geração do registro LEX 

@author David Costa
@since  06/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function VldGridLEX( nHandle, lConfirm )

Local lOk	:= .T.
Local nI	:= 0

//Verifica se o Botão Confirmar Foi clicado
If ( lConfirm )
	For nI := 1 to Len(oGetDB:aCols)
		If( !LinhaVazia( oGetDB:aCols[nI]) )
			If( !oGetDB:aCols[nI][3] .And. !ValidPer( oGetDB:aCols[nI][1] ) )
				lOk := .F.
			EndIf
			
			If( !oGetDB:aCols[nI][3] .And. oGetDB:aCols[nI][2] <= 0 )
				lOk := .F.
			EndIf
		EndIf
	Next nI
	
	If (lOk)
		GerarLEX( nHandle )
		oDlg:End()
	Else
		ApMsgStop("Favor corrigir os dados da grid antes de prosseguir com o processo.")
	EndIf
EndIf

Return (lOk)


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarLEX             
Gera o registro LEX baseado nos dados inseridos manualmente 

@author David Costa
@since  05/01/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GerarLEX( nHandle )

Local cNomeReg	:= "LEX"
Local cStrReg		:= ""
Local nX := 0

For nX:=1 to len(oGetDB:aCols)
	
	If( !oGetDB:aCols[nX][3] .And. !LinhaVazia( oGetDB:aCols[nX] ) )
	
		cStrReg	:= cNomeReg
		cStrReg	+= GetPeriodo( oGetDB:aCols[nX][1] )						//Periodo de referência
		cStrReg	+= TAFDecimal(oGetDB:aCols[nX][2], 13, 2, Nil)			//Valor da operação
		cStrReg	+= CRLF
		
		AddLinDIEF( )
		
		WrtStrTxt( nHandle, cStrReg )
	EndIf
	
Next nX

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} RegLexOK             
Valida se os dados da linha estão integros para geração do registro LEX 

@author David Costa
@since  06/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function RegLexOK()

Local lOk	:= .T.
If( !aCols[Len(aCols)][3] .And. !ValidPer( aCols[Len(aCols)][1] ) )
	ApMsgStop("O período informado não é válido.")
	lOk := .F.
EndIf

If( !aCols[Len(aCols)][3] .And. aCols[Len(aCols)][2] <= 0 )
	ApMsgStop("O valor é obrigatório.")
	lOk := .F.
EndIf

Return( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetHeadCols             
Cria os Arrays da Grid 

@author David Costa
@since  05/01/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetHeadCols()

AADD(aHeader,{"Período",;
"DFCE_PER",;
"99/9999",;
7,;
0,;
"",;
"",;
"C",;
"",;
"V", "", ""})
noBrw++

AADD(aHeader,{"Valor",;
"DFCE_VAL",;
"@E 999,999,999,999.99",;
10,;
2,;
"",;
"",;
"N",;
"",;
"","", ""})

AADD(aCols,Array(3))
aCols[1,3] := .F.

aCols[1,1] := space(7)
aCols[1,2] := 0

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPeriodo             
Retorna o perido no formado correto para a DIEF

@author David Costa
@since  05/01/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetPeriodo( cPeriodo )

Local cAno := ""
Local cMes := ""

cAno := SubStr(cPeriodo,4,4)
cMes := SubStr(cPeriodo,1,2)
cPeriodo := cAno + cMes

Return( cPeriodo )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPer             
Valida se o periodo  informado é valido

@author David Costa
@since  06/01/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function ValidPer( cPeriodo )

Local nAno	:= 0
Local nMes	:= 0
Local lOk	:= .F.

Begin Sequence

	nAno := Val(SubStr(cPeriodo,4,4))
	nMes := Val(SubStr(cPeriodo,1,2))
	
	If( nAno >= 2000 .And. nAno <= 2200 .And. nMes >= 1 .And. nMes <= 12)
		lOk := .T.
	EndIf
	
End Sequence

Return( lOk )


//-------------------------------------------------------------------
/*/{Protheus.doc} LinhaVazia             
Verifica se a linha da grid esta vazia 

@author David Costa
@since  06/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function LinhaVazia( linhaGrid )

Local lVazia	:= .F.

If( Empty( linhaGrid[1] ) .And. linhaGrid[2] == 0)
	lVazia	:= .T.
EndIf

Return( lVazia )