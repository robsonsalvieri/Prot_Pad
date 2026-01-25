#Include "Protheus.ch"
#Include "TAFCSS.CH"
#Include "TopConn.ch"
#Include "TafMontes.ch"
#Include "TAFMONDEF.CH"

Static lLaySimplif 		:= taflayEsoc("S_01_00_00")
Static aChecks    		:= TafMvParam()
Static lFindClass 		:= FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools
Static __lOrdC9VRecNo 	:= Nil 
Static __lOrdT1VRecNo 	:= Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} TafMonMV
Interface para transmissão dos eventos s-1200 e s-1210 de trabalhadores
que não possuem vínculo na Matriz.
@author  Victor A. Barbosa
@since   03/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TafMonMV( cStatus, dDataIni, dDataFim, aFiliais, oTabFilSel ) 

Local aArea			:= GetArea()
Local oSize			:= Nil
Local oLayer		:= Nil
Local oDlgMV		:= Nil
Local oMarkDet		:= Nil 
Local oMarkCount	:= Nil
Local oSliceEvt		:= Nil
Local oSliceTrab	:= Nil
Local oSliceBt		:= Nil
Local oPanelBT		:= Nil
Local oPanelEvt		:= Nil
Local oPanelTrab	:= Nil
Local oTempTable	:= Nil
Local oBtnExp 		:= Nil
Local oBtnDet		:= Nil
Local oBtnTrans		:= Nil
Local aColsDet		:= {}
Local aFilterDet	:= {}
Local aSeekDet		:= {}
Local aIndex		:= {}
Local cAliasMV		:= "ALIASMV"
Local cQueryMV		:= ""
Local cQueryCount	:= ""
Local cArqCount		:= ""
Local nX			:= 0
Local nLargPanel	:= 0
Local nAltPanel		:= 0

Default cStatus		:= ""
Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default aFiliais	:= {}

If Select( cAliasMV ) > 0
	(cAliasMV)->( dbCloseArea() )
EndIf

// Estrutura de dados e query para montagem do painel
cQueryMV	:= MonQryMV( cStatus, dDataIni, dDataFim, aFiliais, "S-1200", @oTabFilSel )
cQueryCount	:= MonMVCount( cStatus, dDataIni, dDataFim, aFiliais, @oTabFilSel )
aColsDet    := MonMVFields( 1, , @aFilterDet, @aSeekDet, @aIndex, cAliasMV )
cArqCount	:= MonDefTemp( @oTempTable )

oSize := FwDefSize():New( .F. )

oDlgMV := MSDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], "Múltiplos Vínculos", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

// Definição do layer com as "fatias" da tela
MonMVLayer( @oLayer, oDlgMV )

oSliceEvt	:= oLayer:GetLinePanel( "LINE01" )
oSliceTrab	:= oLayer:GetLinePanel( "LINE02" )
oSliceBt	:= oLayer:GetLinePanel( "LINE03" )

// Definição do panel onde ficará os botões
nLargPanel	:= oSliceBt:nClientWidth
nAltPanel	:= oSliceBt:nClientHeight * 0.50

// Joga um Panel em cada slice da tela
oPanelEvt	:= TPanel():New(00,00,"",oSliceEvt,,.F.,.F.,,,nLargPanel,nAltPanel,.F.,.F.)
oPanelTrab	:= TPanel():New(00,00,"",oSliceTrab,,.F.,.F.,,,nLargPanel,nAltPanel,.F.,.F.)
oPanelBT 	:= TPanel():New(00,00,"",oSliceBt,,.F.,.F.,,,nLargPanel,nAltPanel,.F.,.F.)

If lFindClass .And. !(GetRemoteType() == REMOTE_HTML) .And. !(FWCSSTools():GetInterfaceCSSType() == 5)
	oPanelBT:setCSS( QLABEL_AZUL_C )
	oPanelTrab:setCSS( QLABEL_AZUL_A )
	oPanelEvt:setCSS( QLABEL_AZUL_A )
EndIf

oPanelTrab:Align := CONTROL_ALIGN_ALLCLIENT
oPanelEvt:Align := CONTROL_ALIGN_ALLCLIENT

// Definição do objeto de browser para que seja mostrado os totais por evento
oMarkCount := MonDefTot( cQueryCount, cArqCount, cAliasMV )

// Definição do objeto de browser para que seja mostrado os trabalhadores
oMarkDet := MonDefDet( cQueryMV, "MARK", aColsDet, cAliasMV, aFilterDet, aSeekDet, aIndex )
oMarkDet:SetValid( { || MonMarkDet( oTempTable, cAliasMV, oMarkDet,oMarkCount ) } )

oMarkCount:SetChange( &('{|| FWMsgRun(, {|| ChangeLine( oMarkCount, oMarkDet, cStatus, dDataIni, dDataFim, aFiliais, cArqCount, @oTabFilSel )},"Aguarde...","Filtrando") }') )
oMarkCount:SetValid( {||  MonMarkTot( oMarkDet, cArqCount, oTempTable, cAliasMV ) } )

//Ativa os painéis
oMarkDet:Activate( oPanelTrab )
oMarkCount:Activate( oPanelEvt )

// Definição das "ações"
oBtnExp := TButton():New(002, 001,"Exportar XMLs",oPanelBT,;
				{|| MonMVChks( "EX", oMarkCount, oMarkDet, oTempTable, cStatus, dDataIni, dDataFim, aFiliais, cArqCount, cAliasMV, @oTabFilSel ) }, 75,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Exportar XMLs"
oBtnExp:SetCSS(BTNLINK)

oBtnTrans := TButton():New(002, 101,"Transmitir ao Governo",oPanelBT,;
				{|| MonMVChks( "TG", oMarkCount, oMarkDet, oTempTable, cStatus, dDataIni, dDataFim, aFiliais, cArqCount, cAliasMV, @oTabFilSel ) }, 75,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Transmitir ao Governo"
oBtnTrans:SetCSS(BTNLINK)

oBtnDet	:= TButton():New(002, 201,"Detalhamento",oPanelBT,;
				{|| MonMVChks( "EM", oMarkCount, oMarkDet, oTempTable, cStatus, dDataIni, dDataFim, aFiliais, cArqCount, cAliasMV, @oTabFilSel ) }, 75,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Transmitir ao Governo"
oBtnDet:SetCSS(BTNLINK)

oBtnTrans := TButton():New(002, oDlgMV:NCLIENTWIDTH * 0.47, "Sair",oPanelBT,;
				{||oDlgMV:End()}, 35,12,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Sair"
oBtnTrans:SetCSS(CSSBOTAO)

oDlgMV:Activate()

oTempTable:Delete()
oTempTable := Nil

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MonQryMV
Retorna a string com a query a ser utilizada no setQuery.
@author  Victor A. Barbosa
@since   03/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonQryMV( cStatus, dDataIni, dDataFim, aFiliais, cEvento, oTabFilSel )

Local cQuery 		:= ""
Local cBancoDB		:= TCGetDb()
Local cIndApu		:= ""

Default oTabFilSel	:= Nil

If cBancoDB == "ORACLE" .Or. cBancoDB == "POSTGRES"
	cQuery += " SELECT DISTINCT CAST('  ' AS CHAR(2)) MARK"
Else
	cQuery += " SELECT DISTINCT '  ' MARK"
EndIf

If cEvento == "S-1200"

	If TafColumnPos( "C91_OWNER" ).AND.TafColumnPos( "T3P_OWNER" ).AND. (cEvento == "S-1200" .OR. cEvento == "S-1210")
		cQuery += " , C91_FILIAL AS FILIAL ,C91_CPF AS CPF, C91_NIS AS NIS, C91_PERAPU AS PERAPU,' ' AS NOME, C91_NOMEVE AS NOMEVE, C91_ID AS ID, C91.R_E_C_N_O_ AS RECNO,  C91.C91_OWNER AS OWNER "
	Else
		cQuery += " , C91_FILIAL AS FILIAL ,C91_CPF AS CPF, C91_NIS AS NIS, C91_PERAPU AS PERAPU,' ' AS NOME,  C91_NOMEVE AS NOMEVE, C91_ID AS ID, C91.R_E_C_N_O_ AS RECNO "
	EndIf

	cQuery += " FROM " + RetSQLName( "C91" ) + " C91 "
	cQuery += " WHERE C91_MV = '1' "
	cQuery += " AND   C91_CPF <> '' "

	If TafColumnPos( "C91_STASEC" )
		cQuery += " AND ( C91_ATIVO = '1' OR C91_STASEC = 'E' )" 
	Else
		cQuery += " AND C91_ATIVO = '1' "
	EndIf

	cQuery += " AND C91_EVENTO <> 'E' "
	cQuery += " AND C91_STATUS IN (" + cStatus + ") "
	cQuery += " AND ( "
	cQuery += " ( C91_INDAPU = '1' " 
	cQuery += " AND C91_PERAPU >= '" + AnoMes(dDataIni) + "'" 
	cQuery += " AND C91_PERAPU <= '" + AnoMes(dDataFim) + "')"
	cQuery += " OR ( C91_INDAPU = '2' " 
	cQuery += " AND C91_PERAPU BETWEEN '" + AllTrim(Str(Year(dDataIni))) + "' AND '" + AllTrim(Str(Year(dDataFim))) + "')" 
	cQuery += " ) "
	cQuery += " AND C91_FILIAL IN (" + TafMonPFil("C91",@oTabFilSel,aFiliais) + ") "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	If TafColumnPos( "C91_OWNER" )
		cQuery += GetOwner("C91",aParamES[16])
	EndIf

ElseIf cEvento == "S-1210"

	If lLaySimplif

		cIndApu := Space(GetSx3Cache("T3P_INDAPU", "X3_TAMANHO"))
		
	EndIf

	If TafColumnPos( "T3P_OWNER" ).AND.TafColumnPos( "C91_OWNER" ).AND. (cEvento == "S-1200" .OR. cEvento == "S-1210")
		cQuery += " , T3P_FILIAL AS FILIAL, T3P_CPF AS CPF, '' AS NIS, T3P_PERAPU AS PERAPU,' ' AS NOME, 'S1210' AS NOMEVE, T3P_ID AS ID, T3P.R_E_C_N_O_ AS RECNO, T3P_OWNER AS OWNER "
	Else
		cQuery += " , T3P_FILIAL AS FILIAL, T3P_CPF AS CPF, '' AS NIS, T3P_PERAPU AS PERAPU,' ' AS NOME, 'S1210' AS NOMEVE, T3P_ID AS ID, T3P.R_E_C_N_O_ AS RECNO "
	EndIf

	cQuery += " FROM " + RetSQLName( "T3P" ) + " T3P "
	cQuery += " WHERE   T3P_CPF <> '' "

	If TafColumnPos( "T3P_STASEC" )
		cQuery += " AND ( T3P_ATIVO = '1' OR T3P_STASEC = 'E' )" 
	Else
		cQuery += " AND T3P_ATIVO = '1' "
	EndIf

	cQuery += " AND T3P_EVENTO <> 'E' "
	cQuery += " AND T3P_STATUS IN (" + cStatus + ") "
	cQuery += " AND ( "

	If !lLaySimplif

		cQuery += " ( T3P_INDAPU = '1' " 

	Else

		cQuery += " (( T3P_INDAPU = '1' " 
		cQuery += " OR T3P_INDAPU = '" + cIndApu + "') "

	EndIf

	cQuery += " AND T3P_PERAPU >= '" + AnoMes(dDataIni) + "'" 
	cQuery += " AND T3P_PERAPU <= '" + AnoMes(dDataFim) + "')"

	If !lLaySimplif

		cQuery += " OR ( T3P_INDAPU = '2' " 

	Else

		cQuery += " OR (( T3P_INDAPU = '2' " 
		cQuery += " OR T3P_INDAPU = '" + cIndApu + "') "

	EndIf

	cQuery += " AND T3P_PERAPU BETWEEN '" + AllTrim(Str(Year(dDataIni))) + "' AND '" + AllTrim(Str(Year(dDataFim))) + "')" 
	cQuery += " ) "
	cQuery += " AND T3P_FILIAL IN (" + TafMonPFil("T3P",@oTabFilSel,aFiliais) + ") "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	If TafColumnPos( "T3P_OWNER" )
		cQuery += GetOwner("T3P",aParamES[16])
	EndIf

EndIf

cQuery := " SELECT * FROM ( " + cQuery + " ) TAF "

Return( cQuery )

//-------------------------------------------------------------------
/*/{Protheus.doc} MonDefDet
Definição do objeto FWMarkBrowse para o detalhamento
@author  Victor A. Barbosa
@since   16/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonDefDet( cQuery, cColumnMark, aColums, cAlias, aFilter, aSeek, aIndex )

Local oMarkDet := Nil

oMarkDet := FWMarkBrowse():New()

oMarkDet:SetDataQuery( .T. )
oMarkDet:SetQuery( cQuery )
oMarkDet:SetFieldMark( cColumnMark )
oMarkDet:oBrowse:SetQueryIndex( aIndex )
oMarkDet:SetAlias( cAlias )
oMarkDet:SetColumns( aColums )
oMarkDet:SetDescription( "Eventos por Trabalhador" )
oMarkDet:DisableDetails() 
oMarkDet:oBrowse:SetUseFilter( .T. )
oMarkDet:oBrowse:SetDBFFilter()
oMarkDet:oBrowse:SetFieldFilter( aFilter )
oMarkDet:oBrowse:SetSeek( .T., aSeek )

oMarkDet:AddButton( "Marcar Todos"		, { || MonMarkAll( .T., oMarkDet ) } )	
oMarkDet:AddButton( "Desmarcar Todos"	, { || MonMarkAll( .F., oMarkDet ) } )

Return( oMarkDet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MonDefTot
** Baseado em FCountStatus (TAFMontES)  Por: Evandro Oliveira **

@param cAliasMV - Alias principal do Monitor

@author  Victor A. Barbosa
@since   16/07/2018
@version 17/07/2018
/*/
//-------------------------------------------------------------------
Static Function MonDefTot( cQueryCount, cArqCount, cAliasMV )

Local oMarkTot		:= Nil
Local cAliasCount	:= "ALIASMVCOUNT"
Local aFilterCount	:= {}
Local aSeekCount	:= {}
Local aColums		:= MonMVFields( 2, cArqCount, @aFilterCount, @aSeekCount,, cAliasMV )

If Select( cAliasCount ) > 0
	(cAliasCount)->( dbCloseArea() )
EndIf


// Define a ordem do dbTemporary
(cArqCount)->( dbSetOrder( 1 ) )

cQueryCount := ChangeQuery(cQueryCount)

TCQuery cQueryCount New Alias (cAliasCount)

(cAliasCount)->( dbGoTop() )

While (cAliasCount)->( !Eof() )

	If (cArqCount)->( MsSeek( (cAliasCount)->EVENTO ) )
		RecLock( cArqCount, .F. )
	Else
		RecLock( cArqCount, .T. )
		(cArqCount)->EVENTO	:= (cAliasCount)->EVENTO
	EndIf

	// Macro-Executa o conteúdo do campo XSTATUS, pois é o mesmo nome da coluna no dbTemporary
	&( (cAliasCount)->XSTATUS ) := (cAliasCount)->QTD
	
	(cArqCount)->( MsUnlock() )

	(cAliasCount)->( dbSkip() )

EndDo


oMarkTot := FWMarkBrowse():New()

oMarkTot:DisableFilter()
oMarkTot:DisableReport()
oMarkTot:DisableDetails()
oMarkTot:SetDescription( "Eventos Periódicos" )
oMarkTot:SetTemporary()
oMarkTot:SetAlias( cArqCount )
oMarkTot:SetFieldMark("MARK")
oMarkTot:SetColumns( aColums )
oMarkTot:oBrowse:SetUseFilter( .T. )
oMarkTot:oBrowse:SetDBFFilter()
oMarkTot:oBrowse:SetFieldFilter( aFilterCount )
oMarkTot:oBrowse:SetSeek( .T., aSeekCount )

Return( oMarkTot )

//-------------------------------------------------------------------
/*/{Protheus.doc} MonDefTemp
Definição do arquivo temporário
@author  Victor A. Barbosa
@since   17/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonDefTemp( oArqCount )

Local aStru			:= {}
Local cAliasCount	:= GetNextAlias()

If Select( cAliasCount ) > 0
	(cAliasCount)->( dbCloseArea() )
EndIf

aAdd( aStru,{ "MARK"  , "C",  002, 0 } )
aAdd( aStru,{ "EVENTO"  , "C",  006, 0 } )
aAdd( aStru,{ "BRANCO"  , "N",  009, 0 } )
aAdd( aStru,{ "ZERO"	, "N",  009, 0 } )
aAdd( aStru,{ "UM"  	, "N",  009, 0 } )
aAdd( aStru,{ "DOIS"  	, "N",  009, 0 } )
aAdd( aStru,{ "TRES" 	, "N",  009, 0 } )
aAdd( aStru,{ "QUATRO" 	, "N",  009, 0 } )

oArqCount := FWTemporaryTable():New( cAliasCount )
oArqCount:SetFields( aStru )
oArqCount:AddIndex("I1",{ "EVENTO" } )
oArqCount:Create()

Return( cAliasCount )

//-------------------------------------------------------------------
/*/{Protheus.doc} MonMVLayer
"Fatia" a tela
@author  Victor A. Barbosa
@since   16/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonMVLayer( oLayer, oDlg )

oLayer := FWLayer():New()
oLayer:Init( oDlg, .F. )
oLayer:AddLine( "LINE01", 30 )
oLayer:AddLine( "LINE02", 65 )
oLayer:AddLine( "LINE03", 05 )

Return( oLayer )

 //-------------------------------------------------------------------
 /*/{Protheus.doc} MonMVCount
 Efetua a contagem dos status e deixa o arquivo de trabalho disponível
 @author  Victor A. Barbosa
 @since   16/07/2018
 @version 1
 /*/
 //-------------------------------------------------------------------
Static Function MonMVCount( cStatus, dDataIni, dDataFim, aFiliais, oTabFilSel )

Local cIndApu		:= ""

Default oTabFilSel	:= Nil

// S-1200
cQuery := " SELECT CASE "
cQuery += " WHEN C91_STATUS = ' ' THEN 'BRANCO' "
cQuery += " WHEN C91_STATUS = '0' THEN 'ZERO' "
cQuery += " WHEN C91_STATUS = '1' THEN 'UM' "
cQuery += " WHEN C91_STATUS = '2' THEN 'DOIS' "
cQuery += " WHEN C91_STATUS = '3' THEN 'TRES' "
cQuery += " WHEN C91_STATUS = '4' THEN 'QUATRO' "
cQuery += "   END XSTATUS "
cQuery += " , COUNT(*) QTD, "
cQuery += " 'S-1200' AS EVENTO "
cQuery += " FROM " + RetSQLName( "C91" ) + " C91 "
cQuery += " WHERE C91_MV = '1' "
cQuery += " AND   C91_CPF <> '' "

If TafColumnPos( "C91_STASEC" )
	cQuery += " AND ( C91_ATIVO = '1' OR C91_STASEC = 'E' )" 
Else
	cQuery += " AND C91_ATIVO = '1' "
EndIf

cQuery += " AND C91_EVENTO <> 'E' "
cQuery += " AND C91_STATUS IN (" + cStatus + ") "
cQuery += " AND ( "
cQuery += " ( C91_INDAPU = '1' " 
cQuery += " AND C91_PERAPU >= '" + AnoMes(dDataIni) + "'" 
cQuery += " AND C91_PERAPU <= '" + AnoMes(dDataFim) + "')"
cQuery += " OR ( C91_INDAPU = '2' " 
cQuery += " AND C91_PERAPU BETWEEN '" + AllTrim(Str(Year(dDataIni))) + "' AND '" + AllTrim(Str(Year(dDataFim))) + "')" 
cQuery += " ) "
cQuery += " AND C91_FILIAL IN (" + TafMonPFil("C91",@oTabFilSel,aFiliais) + ") "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY C91_STATUS "

cQuery += " UNION ALL "

// S-1210
cQuery += " SELECT CASE "
cQuery += " WHEN T3P_STATUS = ' ' THEN 'BRANCO' "
cQuery += " WHEN T3P_STATUS = '0' THEN 'ZERO' "
cQuery += " WHEN T3P_STATUS = '1' THEN 'UM' "
cQuery += " WHEN T3P_STATUS = '2' THEN 'DOIS' "
cQuery += " WHEN T3P_STATUS = '3' THEN 'TRES' "
cQuery += " WHEN T3P_STATUS = '4' THEN 'QUATRO' "
cQuery += "   END XSTATUS "
cQuery += " , COUNT(*) QTD, "
cQuery += " 'S-1210' AS EVENTO "
cQuery += " FROM " + RetSQLName( "T3P" ) + " T3P "
cQuery += " WHERE   T3P_CPF <> '' "
cQuery += " AND T3P_EVENTO <> 'E' "
cQuery += " AND T3P_STATUS IN (" + cStatus + ") "
cQuery += " AND ( "

If lLaySimplif

	cIndApu := Space(GetSx3Cache("T3P_INDAPU", "X3_TAMANHO"))
	
EndIf

If !lLaySimplif

	cQuery += " ( T3P_INDAPU = '1' " 

Else

	cQuery += " (( T3P_INDAPU = '1' " 
	cQuery += " OR T3P_INDAPU = '" + cIndApu + "') "

EndIf

cQuery += " AND T3P_PERAPU >= '" + AnoMes(dDataIni) + "'" 
cQuery += " AND T3P_PERAPU <= '" + AnoMes(dDataFim) + "')"

If !lLaySimplif

	cQuery += " OR ( T3P_INDAPU = '2' " 

Else

	cQuery += " OR (( T3P_INDAPU = '2' "  
	cQuery += " OR T3P_INDAPU = '" + cIndApu + "') "

EndIf

cQuery += " AND T3P_PERAPU BETWEEN '" + AllTrim(Str(Year(dDataIni))) + "' AND '" + AllTrim(Str(Year(dDataFim))) + "')" 
cQuery += " ) "
cQuery += " AND T3P_FILIAL IN (" + TafMonPFil("T3P",@oTabFilSel,aFiliais) + ") "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY T3P_STATUS "

Return( cQuery )

//-------------------------------------------------------------------
/*/{Protheus.doc} MonMVFields
Retorna a estrutura de campos do monitor

@param cAliasMV - Alias Principal do Browse

@author  Victor A. Barbosa
@since   05/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonMVFields( nBrowser, cArqCount, aFilter, aSeek, aIndex, cAliasMV )

Local aFields	:= {}
Local aColsMV	:= {}
Local nX		:= 0
Local bData		:= {||}
Local cBanco	:= ""

cBanco	:= AllTrim(TCGetDB())

If nBrowser == 1
	aAdd( aFields, { "FILIAL"	,	"C",	TamSX3( "C91_FILIAL" )[1]	,	0,	"Filial"	, PesqPict("C91", "C91_FILIAL")	}	)
	//aAdd( aFields, { "ID"		,	"C",	TamSX3( "C91_ID" )[1]		,	0,	"Filial"	, PesqPict("C91", "C91_ID")	}	)
	aAdd( aFields, { "CPF"   	,	"C",	TamSX3( "C91_CPF" )[1]		,	0,	"CPF"		, PesqPict("C91", "C91_CPF") 	}	)
	aAdd( aFields, { "NIS" 	 	,	"C",	TamSX3( "C91_NIS" )[1]		,	0,	"NIS"		, PesqPict("C91", "C91_NIS") 	}	)
	aAdd( aFields, { "PERAPU" 	,	"C",	TamSX3( "C91_PERAPU" )[1]	,	0,	"Período"	, PesqPict("C91", "C91_PERAPU")	}	)
	aAdd( aFields, { "NOME" 	,	"C",	TamSX3( "C9V_NOME" )[1]		,	0,	"Nome"		, PesqPict("C9V", "C9V_NOME")	}	)

	If TafColumnPos("C91_OWNER").AND.TafColumnPos("T3P_OWNER")
		aAdd( aFields, { "OWNER" 	,	"C",	TamSX3( "C91_OWNER" )[1]	,	0,	"ERP Origem"	 	, PesqPict("C91", "C91_OWNER")	}	)
	Endif

	aAdd( aIndex, "FILIAL" )
	//aAdd( aIndex, "ID" )
	aAdd( aIndex, "CPF" )
	aAdd( aIndex, "NIS" )

	aAdd( aSeek,   { "FILIAL"	, { { "", "C", TamSX3( "C91_FILIAL" )[1]	, 0, "Filial"	, PesqPict("C91", "C91_ID") } } } )
	//aAdd( aSeek,   { "ID"		, { { "", "C", TamSX3( "C91_ID" )[1]		, 0, "Id"		, PesqPict("C91", "C91_ID") } } } )
	aAdd( aSeek,   { "CPF"		, { { "", "C", TamSX3( "C91_CPF" )[1]		, 0, "CPF"		, PesqPict("C91", "C91_CPF") } } } )
	aAdd( aSeek,   { "NIS"		, { { "", "C", TamSX3( "C91_NIS" )[1]		, 0, "NIS"		, PesqPict("C91", "C91_NIS") } } } )

ElseIf nBrowser == 2
	aAdd( aFields, { "EVENTO"  	,	"C",	011,	0,	"Evento"			, PesqPict("C91", "C91_NOMEVE") 	}	)
	aAdd( aFields, { "BRANCO" 	,	"N",	009,	0,	"Não Processados"	, "@E 999999999" 	}	)
	aAdd( aFields, { "ZERO" 	,	"N",	009,	0,	"Válidos"			, "@E 999999999" 	}	)
	aAdd( aFields, { "UM" 		,	"N",	009,	0,	"Invalidos"			, "@E 999999999" 	}	)
	aAdd( aFields, { "DOIS" 	,	"N",	009,	0,	"Sem Retorno"		, "@E 999999999" 	}	)
	aAdd( aFields, { "TRES" 	,	"N",	009,	0,	"Inconsistente"		, "@E 999999999" 	}	)
	aAdd( aFields, { "QUATRO" 	,	"N",	009,	0,	"Consistente"		, "@E 999999999" 	}	)
	
	aAdd( aSeek,   { "Evento", { { "", "C", 6, 0, "EVENTO","@!" } } } )
EndIf

For nX := 1 To Len( aFields ) 
	
	aAdd( aColsMV, FWBrwColumn():New() )

	If nBrowser == 1
		If aFields[nX][1] == "NOME"
			bData := &( "{||TafMVNomeFun((cAliasMV)->CPF,cBanco)}")
		Else 
			bData := &( "{||(cAliasMV)->" + aFields[nX][1] + "}")
		EndIf 
	ElseIf nBrowser == 2
		bData := &( "{||" + (cArqCount) + "->" + aFields[nX][1] + "}")
	EndIf

	aColsMV[nX]:SetData( bData )
	aColsMV[nX]:SetTitle( aFields[nX][5] )
	aColsMV[nX]:SetPicture( aFields[nX][6] )
	aColsMV[nX]:SetSize( aFields[nX][3] )
	aColsMV[nX]:SetDecimal( aFields[nX][4] )

	aAdd( aFilter,{ aFields[nX][1], aFields[nX][5], aFields[nX][2], aFields[nX][3], 0, "" } )
	
Next nX

Return( aColsMV )

//-------------------------------------------------------------------
/*/{Protheus.doc} MonMarkAll
** Baseado em FMarkAll (TAFMontES)  Por: Evandro Oliveira **
@author  Victor A. Barbosa
@since   17/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonMarkAll( lMarca, oMark )

Local cAlias	:= oMark:Alias()
Local nRecno	:= (cAlias)->( Recno() )
Local oDataMark := oMark:Data()
Local aArea		:= GetArea()
Local cMark		:= oMark:Mark()
Local cQuery	:= ""

oMark:SetInvert( lMarca )
oMark:Refresh()

If lMarca
	cMark := oMark:Mark()
Else
	cMark := '  '
EndIf

cQuery := " UPDATE "
cQuery += oDataMark:oTempDB:GetRealName() 
cQuery += " SET MARK = '" + cMark + "'"
	
If TCSQLExec( cQuery ) < 0
	MsgInfo ( TCSQLError(), "Update Mark Eventos." )
EndIf

(cAlias)->( dbGoTo(nRecno) )

RestArea( aArea )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeLine
Alteração da linha
@author  Victor A. Barbosa
@since   18/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Function ChangeLine( oMarkCount, oMarkDet, cStatus, dDataIni, dDataFim, aFiliais, cArqCount, oTabFilSel )

Local cQuery	:= ""
Local aArea		:= GetArea()
Local cEvento	:= ""

Default oTabFilSel	:= Nil

(cArqCount)->( dbGoTo( oMarkCount:At() ) )

cEvento := (cArqCount)->EVENTO

// Tratamento para browser vazio
If Empty( cEvento )
	cEvento := "S-1200"
EndIf

cQuery := MonQryMV( cStatus, dDataIni, dDataFim, aFiliais, cEvento, @oTabFilSel )

oMarkDet:setQuery( cQuery )

oMarkDet:Refresh()

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MonMarkTot
Verifica se pode marcar o evento no browser totalizador
@author  Victor A. Barbosa
@since   18/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonMarkTot( oMarkDet, cArqCount, oTempTable, cAliasMV )

Local cQuery 	:= ""
Local oDataMark := Nil
Local aArea		:= GetArea()
Local lAtualiza	:= .T.

	oDataMark := oMarkDet:Data()
	
	//Verifica se tem seleção no browse do Trabalhador
	cQuery := " SELECT COUNT(*) NREGS "
	cQuery += " FROM  " + oDataMark:oTempDB:GetRealName()
	cQuery += " WHERE MARK  != '  ' "
	
	If Select( "rsEvMark" ) > 0
		rsEvMark->( dbCloseArea() )
	EndIf
	
	TCQuery cQuery New Alias "rsEvMark"
	
	If rsEvMark->NREGS > 0	
		Alert( "Retirar a Seleção do Browse Trabalhador para realizar a marcação do Browse Eventos" )
		lAtualiza := .F.
	EndIf
	
	rsEvMark->( dbCloseArea() )
	
	// --> Verifica se Já possui algum item marcado anteriormente
	cQuery := " SELECT COUNT(*) NREGS "
	cQuery += " FROM  " + oTempTable:GetRealName()
	cQuery += " WHERE MARK  != '  ' "
	
	TCQuery cQuery New Alias "rsEvMark"
	
	If rsEvMark->NREGS > 1
		Alert( "Por questão de performance, só é permitida a seleção de 1 lote de evento por vez." )
		lAtualiza := .F.
	EndIf
	
	If !lAtualiza
		If RecLock( cArqCount,.F. )
			(cArqCount)->MARK := "  "
			(cArqCount)->( MsUnlock() )
		EndIf
	EndIf
	
	rsEvMark->( dbCloseArea() )

RestArea( aArea )

Return lAtualiza

//-------------------------------------------------------------------
/*/{Protheus.doc} MonMarkDet
Verifica se pode marcar o evento no browser do trabalhador (Detalhamento)
@author  Victor A. Barbosa
@since   18/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonMarkDet( oTempTable, cAliasMV,oMarkDet,oMarkCount )

Local cQuery 	:= ""
Local oDataMark := Nil
Local aArea		:= GetArea()
Local lAtualiza := .T.


	//Conta Itens Selecionados no browse de eventos
	cQuery := " SELECT COUNT(*) NREGS "
	cQuery += " FROM  " + oTempTable:GetRealName()
	cQuery += " WHERE MARK  != '  ' "
	
	If Select( "rsEvtCount" ) > 0
		rsEvtCount->( dbCloseArea() )
	EndIf
	
	TCQuery cQuery New Alias "rsEvtCount"
	
	If rsEvtCount->NREGS > 0
	
		Alert( "Retirar a Seleção do Browse de Eventos para realizar a marcação do Browse Eventos" )
		
		If RecLock( cAliasMV,.F. )
			(cAliasMV)->MARK := "  "
			(cAliasMV)->( MsUnlock() )
		EndIf
	
	EndIf
	
	rsEvtCount->( dbCloseArea() )

	RestArea( aArea )

Return lAtualiza

//------------------------------------------------------------------
/*/{Protheus.doc} MonMVChks
Verifica a Seleção dos Itens dos Browses
** Baseado em FVerChks (TAFMontES)  Por: Evandro Oliveira **
@author  Victor A. Barbosa
@since   18/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function MonMVChks(cIdBotao, oMarkCount, oMarkDet, oTempTable, cStatus, dDataIni, dDataFim, aFiliais, cArqCount, cAliasMV, oTabFilSel, lMV )

Local aEvtSel	:= {}
Local aRetEvts	:= {}
Local nX		:= 0
Local cTableDet	:= ""
Local cTableTot	:= ""
Local cQryDet	:= ""
Local cQryTot	:= ""
Local cMsgRet	:= ""
Local cPathXml	:= ""
Local cRecNos	:= ""
Local cQueryRec	:= ""
Local lBrwDet	:= .F.
Local lBrwTot	:= .F.
Local lCancel	:= .F.
Local lAtualiza	:= .T.
Local oProcess	:= Nil

Default lMV := .F.


	cTableDet := oMarkDet:oBrowse:oData:oTempDB:GetRealName()
	cTableTot := oTempTable:GetRealName()
	
	If Select('rsBrwTot') > 0; rsBrwTot->( dbCloseArea() ); EndIf
	If Select('rsBrtDet') > 0; rsBrtDet->( dbCloseArea() ); EndIf
				
	cQryDet := " SELECT RECNO "
	cQryDet += " FROM  " + cTableDet 
	cQryDet += " WHERE MARK != ' ' "
	
	TCQuery cQryDet New Alias "rsBrtDet"
	
	rsBrtDet->( dbGoTop() )
	If rsBrtDet->( !Eof() )
		
		lBrwDet := .T.
	
		rsBrtDet->( dbGoTop() )
	
		While rsBrtDet->( !Eof() )
	
			cRecNos += cValToChar( rsBrtDet->RECNO ) + ", "
			
			rsBrtDet->( dbSkip() )
	
		EndDo
	
		// --> No browser superior está posicionado no evento
		aAdd( aEvtSel, TAFRotinas( (cArqCount)->EVENTO , 4, .F., 2 ) )
		
		If !Empty( cRecNos )
			// --> Remove os dois últimos carácteres (", ")
			cRecNos := SubStr( cRecNos, 1, Len( cRecNos ) - 2 )
		EndIf
	
	EndIf

//Se não foi selecionado no browse de detalhamento, verifica se foi selecionado no browser de totais
If !lBrwDet

	
		cQryTot := " SELECT EVENTO "
		cQryTot += " FROM  " + cTableTot 
		cQryTot += " WHERE MARK != ' ' "
	
		TCQuery cQryTot New Alias "rsBrwTot"
	
		rsBrwTot->( dbGoTop() )
		
		If rsBrwTot->( !Eof() )
			
			lBrwTot := .T.
			
			While rsBrwTot->( !Eof() )
				aAdd( aEvtSel, TAFRotinas( AllTrim( rsBrwTot->EVENTO ), 4, .F., 2 ) )			
				rsBrwTot->( dbSkip() )
			EndDo
	
			// --> Após verificar quais eventos foram selecionados, busca os recnos somente dos registros MV
			// --> Saída para não realizar alterações no TAFProc4 (legado)
			For nX := 1 To Len( aEvtSel )
				
				cQueryRec := MonQryMV( cStatus, dDataIni, dDataFim, aFiliais, aEvtSel[nX][4], @oTabFilSel )
	
				If Select( "rsRecno" ) > 0
					rsRecno->( dbCloseArea() )
				EndIf
				
				TCQuery cQueryRec New Alias "rsRecno"
	
				While rsRecno->( !Eof() )
					cRecNos += cValToChar( rsRecno->RECNO ) + ", "
					rsRecno->( dbSkip() )
				EndDo
	
				// --> Remove os dois últimos carácteres (", ")
				cRecNos := SubStr( cRecNos, 1, Len( cRecNos ) - 2 )
	
			Next nX
	
		EndIf
		
	
EndIf

If !lBrwDet .And. !lBrwTot
	Aviso( "Atenção", "Selecione algum Registro/Evento para executar essa ação.", { "Ok" } )
	MonMarkAll(.F., oMarkDet)
Else
	
	If cIdBotao == "EX"
		
		cPathXml := cGetFile(STR0087 + "|*.*", STR0088, 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )
		Processa({|lCancel|TAFProc4Tss(.F.,aEvtSel,cStatus,cPathXml,{},cRecNos,,@cMsgRet,.T.,aFiliais,dDataIni,dDataFim,@lCancel, .T.,@oTabFilSel)},"Geração de XMLs","Gerando os Xmls Selecionados",.T.)

		MsgInfo(STR0091) //"Processamento Finalizado"

	ElseIf cIdBotao == "TG"
			
		If FindFunction("TafDicInDb")
			lTempTable := TafDicInDb()
		Else
			lTempTable := .F.
		EndIf

		FSelItens( ,"TG", aChecks,0,0,Nil,lTempTable,oTabFilSel,.F., .T., oMarkDet, oTempTable)
	
		TAFMErrT0X(aRetEvts) //Verificar o uso cFilAnt

		//Aviso(STR0094,cMsgRet,{STR0077},2) //"Transmissão e-Social"
		
		
		If lAtualiza 
			If MsgYesNo( STR0163 , STR0164 ) //"Deseja abrir os detalhes da transmissão?" ## "Monitor do eSocial - Detalhes"

				If !TAFAlsInDic("V2H")
					FTableTSSErr()
				EndIf 

				oProcess := Nil
				lCancel := .F.   
				FWMsgRun(,{||TafMonDet(Nil,"'1','2','3','6','7'",'',aEvtSel,.T.,.F./*lMultEvt*/,cRecNos,{},.F.,"Eventos",.F.,@oProcess,@lCancel,@oTabFilSel)} , "Detalhamento/Consulta TSS" , "Aguarde ... Consultando registros.",.T.) 
			
			EndIf 
		EndIf 
		

	ElseIf cIdBotao == "EM"

		If !TAFAlsInDic("V2H")
			FTableTSSErr()
		EndIf 

		lCancel := .F.
		FWMsgRun(,{||ConsultaRegs(aEvtSel,cRecnos,"'2','3'",lCancel,@oProcess, aFiliais, dDataIni, dDataFim,@oTabFilSel),;
					 TafMonDet(Nil,cStatus,'',aEvtSel,.T.,.F.,cRecnos,{},.F.,"Eventos",.F.,,@lCancel,@oTabFilSel)},;
	    "Detalhamento/Consulta TSS" , "Aguarde ... Consultando registros.",.T. )

	EndIf

EndIf  

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ConsultaRegs
Consulta o retorno dos registros do TSS
@author  Victor A. Barbosa
@since   20/07/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function ConsultaRegs( aEvtsSel, cRecnos, cStatus, lEnd, oProcess, aFiliais,dDataIni,dDataFim,oTabFilSel )

Default oProcess	:= Nil
Default oTabFilSel	:= Nil

TAFProc5Tss(.F.,aEvtsSel,cStatus,{},cRecnos,lEnd,,aFiliais,dDataIni,dDataFim,,,,oProcess,,@oTabFilSel,.T.)

Return Nil


/*/{Protheus.doc} PossuiMark
//TODO Descrição auto-gerada.
@author osmar.junior
@since 30/08/2018
@version 1.0
@return ${return}, ${return_description}
@param oMarkAux, object, descricao
@type function
/*/
Static Function PossuiMark(oMarkAux)
Local lRet := .F.
Local cAliasAux := oMarkAux:oBrowse:cAlias
Local cCpoMark  := oMarkAux:cFieldMark
Local nItem		:= oMarkAux:At()

 	(cAliasAux)->( DbSetOrder(1) )
    (cAliasAux)->( DbGoTop() )   
    While !(cAliasAux)->(Eof())
        If !Empty((cAliasAux)->&(cCpoMark)) //Se diferente de vazio, é porque foi marcado
            lRet := .T.            
        Endif
        (cAliasAux)->( dbSkip() )
    EndDo
    oMarkAux:GoTo(nItem,.T.)
    oMarkAux:Refresh()
    
Return lRet



/*/{Protheus.doc} MonMvDet
//TODO Descrição auto-gerada.
@author osmar.junior
@since 31/08/2018
@version 1.0
@return ${return}, ${return_description}
@param lBrwDet, logical, descricao
@param oMarkAux, object, descricao
@param cRecNos, characters, descricao
@param aEvtSel, array, descricao
@param cEvento, characters, descricao
@type function
/*/
Static Function MonMvDet(lBrwDet,oMarkAux,cRecNos,aEvtSel, cEvento )
Local aArea			:= GetArea()
Local cAliasAux := oMarkAux:oBrowse:cAlias

	(cAliasAux)->( dbGoTop() )
	If (cAliasAux)->( !Eof() )		
	
		While (cAliasAux)->( !Eof() )
			If !Empty( (cAliasAux)->MARK )
				lBrwDet := .T.
				cRecNos += cValToChar( (cAliasAux)->RECNO ) + ", "	
			EndIf		
			(cAliasAux)->( dbSkip() )	
		EndDo
		
		If !Empty( cRecNos )
			// --> Remove os dois últimos carácteres (", ")
			cRecNos := SubStr( cRecNos, 1, Len( cRecNos ) - 2 )
		EndIf
		
		If lBrwDet
			// --> No browser superior está posicionado no evento
			aAdd( aEvtSel, TAFRotinas( cEvento , 4, .F., 2 ) )
		EndIf

	EndIf
	
RestArea( aArea )
	
Return


/*/{Protheus.doc} MonMvTot
//TODO Descrição auto-gerada.
@author osmar.junior
@since 31/08/2018
@version 1.0
@return ${return}, ${return_description}
@param lBrwTot, logical, descricao
@param cArqCount, characters, descricao
@param cRecNos, characters, descricao
@param aEvtSel, array, descricao
@param cStatus, characters, descricao
@param dDataIni, date, descricao
@param dDataFim, date, descricao
@param aFiliais, array, descricao
@type function
/*/
Static Function MonMvTot( lBrwTot, cArqCount, cRecNos, aEvtSel,cStatus, dDataIni, dDataFim, aFiliais )
Local aArea		:= GetArea()
Local nX		:= 0

	(cArqCount)->( dbGoTop() )
	If (cArqCount)->( !Eof() )	

		While (cArqCount)->( !Eof() )
			If !Empty( (cArqCount)->MARK )
				lBrwTot := .T.
				aAdd( aEvtSel, TAFRotinas( AllTrim( (cArqCount)->EVENTO ), 4, .F., 2 ) )	
			EndIf		
			(cArqCount)->( dbSkip() )	
		EndDo

	EndIf
	
	// --> Após verificar quais eventos foram selecionados, busca os recnos somente dos registros MV
	// --> Saída para não realizar alterações no TAFProc4 (legado)
	For nX := 1 To Len( aEvtSel )
		
		cQueryRec := MonQryMV( cStatus, dDataIni, dDataFim, aFiliais, aEvtSel[nX][4] )

		If Select( "rsRecno" ) > 0
			rsRecno->( dbCloseArea() )
		EndIf
		
		TCQuery cQueryRec New Alias "rsRecno"

		While rsRecno->( !Eof() )
			cRecNos += cValToChar( rsRecno->RECNO ) + ", "
			rsRecno->( dbSkip() )
		EndDo
		// --> Remove os dois últimos carácteres (", ")
		cRecNos := SubStr( cRecNos, 1, Len( cRecNos ) - 2 )

	Next nX
	
RestArea( aArea )
	
Return

/*/{Protheus.doc} TafMvParam
//Função utilizada para retorno dos arrays utilizados como DEFINE "TAFMONDEF.CH"
//Na versão 11 não estava conseguindo enxergar mesmo estando como escopo de Private
@author osmar.junior
@since 31/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function TafMvParam()
Local aChecks := {}
Local aParAux := {}

	aChecks :=   		{{	paramStsNaoProcessados	,	"REGNPROC",	STR0052	,   STATUS_NAO_PROCESSADO[1]}; 	//"Não Processados"
						, {	paramStsValidos			,	"REGVALID",	STR0054	,	STATUS_VALIDO[1]}; 			//"Válidos"
						, {	paramStsInvalidos	 	,	"REGINVLD",	STR0056	,	STATUS_INVALIDO[1]}; 		//"Invalidos"
						, {	paramStsSemRetorno		,	"REGSRET" ,	STR0061	,	STATUS_SEM_RETORNO_GOV[1]};	//"Sem Retorno"
						, {	paramStsInconsistente	,	"REGINCOS",	STR0065	,	STATUS_INCONSISTENTE[1]}; 	//"Inconsistente"	
						, {	paramStsConsistente		,	"REGCONST",	STR0063	,	STATUS_TRANSMITIDO_OK[1]}}	//"Consistente"

Return aChecks

/*/{Protheus.doc} TafMVNomeFun
Retorna o Ultimo nome válido(no Governo) idependente da empresa/filial
que o trabalhador esteja.

@type function
@author Evandro dos Santos O. Teixeira
@since 20/08/2020
@version 1.0

@param cCpf - CPF do Trabalhador
@param cBanco - Banco de Dados em Uso

@return cNomeFunc - Nome do Trabalhador
/*/
Function TafMVNomeFun(cCpf,cBanco)

	Local cQryC9V := ""
	Local cQryT1U := ""
	Local cNomeFunc := ""

	Default cCpf := ""

	If __lOrdC9VRecNo  == Nil

		If TafColumnPos("C9V_DINSIS") 
			__lOrdC9VRecNo := .F.
		Else 
			__lOrdC9VRecNo := .T.
		EndIf 
	EndIf 

	If __lOrdT1VRecNo == Nil 

		If TafColumnPos("T1U_DINSIS")
			__lOrdT1VRecNo := .F.
		else
			__lOrdT1VRecNo := .T. 
		EndIf
	EndIf 

	cQryT1U := " SELECT " 
	If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
		cQryT1U += " TOP 1  "
	ElseIf cBanco == "INFORMIX"
		cQryT1U += " FIRST 1  "
	EndIf	

	cQryT1U += " T1U_NOME NOME "
	cQryT1U += " FROM " + RetSqlName("T1U") 
	cQryT1U += " WHERE T1U_CPF = '" + AllTrim(cCpf) + "'"
	cQryT1U += " AND T1U_ATIVO = '1'"
	cQryT1U += " AND T1U_STATUS = '4'"
	cQryT1U += " AND D_E_L_E_T_ = ' '"

	If cBanco == "ORACLE"
		cQryT1U += " AND ROWNUM <= 1 "
	EndIf 

	If cBanco == "DB2"

		If __lOrdT1VRecNo
			cQryT1U += " ORDER BY R_E_C_N_O_ DESC "
		Else 
			cQryT1U += " ORDER BY T1U_DINSIS, R_E_C_N_O_ DESC "
		EndIf 
		cQryT1U += " FETCH FIRST 1 ROWS ONLY "
	Else 

		If __lOrdT1VRecNo
			cQryT1U += " ORDER BY R_E_C_N_O_ DESC "
		Else 
			cQryT1U += " ORDER BY T1U_DINSIS, R_E_C_N_O_ DESC "
		EndIf 

		If cBanco $ "POSTGRES|MYSQL"
			cQryT1U += " LIMIT 1 "
		EndIf 
	Endif


	TCQuery cQryT1U New Alias 'rsT1U'
	cNomeFunc := rsT1U->NOME
	rsT1U->(dbCloseArea())

	If Empty(cNomeFunc)

		cQryC9V := " SELECT " 
		If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
			cQryC9V += " TOP 1  "
		ElseIf cBanco == "INFORMIX"
			cQryC9V += " FIRST 1  "
		EndIf	

		cQryC9V += " C9V_NOME NOME "  
		cQryC9V += " FROM " + RetSqlName("C9V")
		cQryC9V += " WHERE C9V_CPF = '" + AllTrim(cCpf) + "'"
		cQryC9V += " AND C9V_ATIVO = '1' "
		cQryC9V += " AND D_E_L_E_T_ = ' ' "

		If cBanco == "ORACLE"
			cQryC9V += " AND ROWNUM <= 1 "
		EndIf 


		If cBanco == "DB2"

			If __lOrdC9VRecNo
				cQryC9V += " ORDER BY R_E_C_N_O_ DESC "
			Else 
				cQryC9V += " ORDER BY C9V_DINSIS, R_E_C_N_O_ DESC "
			EndIf 
			cQryC9V += " FETCH FIRST 1 ROWS ONLY "
		Else 

			If __lOrdC9VRecNo
				cQryC9V += " ORDER BY R_E_C_N_O_ DESC "
			Else 
				cQryC9V += " ORDER BY C9V_DINSIS, R_E_C_N_O_ DESC "
			EndIf 

			If cBanco $ "POSTGRES|MYSQL"
				cQryC9V += " LIMIT 1 "
			EndIf 
		Endif

		TCQuery cQryC9V New Alias 'rsC9V'
		cNomeFunc := rsC9V->NOME
		rsC9V->(dbCloseArea())
	EndIf 

Return AllTrim(cNomeFunc)
