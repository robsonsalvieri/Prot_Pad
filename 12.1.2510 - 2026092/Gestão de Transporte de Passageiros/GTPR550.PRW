#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR550.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR550()
Relatório Medição de Fretamento

@sample GTPR550()

@author jose.darocha
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR550()

	Local oReport
	Local cPerg  	:= 'GTPR550'
	Local aAreaAtu 	:= GetArea()
	Local aRange    := {}
	Local lGTPA903  := FwIsInCallStack('GTPA903')
	Local lContinua := .T.

	Private lQuebraCli := .F.

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

		If lGTPA903

			aRange := GetContr()

			If !Empty(aRange)
				Pergunte(cPerg, .F.)

				MV_PAR01 := GQR->GQR_CLIENT
				MV_PAR02 := GQR->GQR_LOJA
				MV_PAR03 := aRange[1]
				MV_PAR04 := aRange[2]
				MV_PAR05 := GQR->GQR_DTINIA
				MV_PAR06 := GQR->GQR_DTFINA

			EndIF 

		Else 

			lContinua := Pergunte(cPerg, .T.)

		EndIF 

		If lContinua

			lQuebraCli := QuebraRel()

			oReport := ReportDef(cPerg)
			If lGTPA903
				FwMsgRun(,{|| oReport:Print(.F.) },, STR0021 )	//Processando
			Else 
				oReport:PrintDialog()
			EndIf	
		EndIf 

	EndIf

	RestArea( aAreaAtu )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório de Medição de Fretamento

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author jose.darocha 
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

	Local cTitle    := STR0001	//"Medição de Fretamento"
	Local cHelp     := STR0002	//"Relatório de Medição de Fretamento"
	Local cAliasQry := GetNextAlias()
	Local lEndReport:= .F.
	Local oReport
	Local oSecViagem
	Local oCabec 
	Local oSecViagExtra
	Local oSecTotal
	Local oBreak
	Local oFunTot1,oFunTot2,oFunTot3,oFunTot4,oSecSubTot

	oReport := TReport():New('GTPR550',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
	oReport:SetPortrait(.T.)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)

	oCabec := TRSection():New(oReport, 'CABECALHO', NIL)
	oCabec:SetTotalInLine(.F.)

	If lQuebraCli
		TRCell():New(oCabec,"NOMECLI"   , '' ,RetTitle('A1_NOME') , /*Picture*/, TamSX3('A1_NOME')[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
	EndIf 

	TRCell():New(oCabec,"GYD_NUMERO", cAliasQry	,RetTitle('GYD_NUMERO') , /*Picture*/, TamSX3('GYD_NUMERO')[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,"MESREF" 	, ''		,STR0003 /*"Mes de Referencia:"*/ 	, /*Picture*/, 30/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,"PERIODO"	, ''		,STR0004 /*"Periodo:"*/           	, /*Picture*/, 30/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,"GQR_CODIGO", cAliasQry	,RetTitle('GQR_CODIGO')          	, /*Picture*/, TamSX3('GQR_CODIGO')[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 

	oSecViagem := TRSection():New(oReport,cTitle,cAliasQry)
	oSecViagem:SetTotalInLine(.F.)

	TRCell():New(oSecViagem	, "LINHAS"		, cAliasQry	, STR0005 /*'Linhas' */		, "@!"							, 43/*Tamanho*/						, /*lPixel*/ ,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagem	, "DIAS"	    , cAliasQry	, STR0007 /*'Dias'*/        , "@E 999,999"	    			, 08/*Tamanho*/						, /*lPixel*/ ,/*{|| code-block de impressao }*/,'CENTER'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem	, "QTDDCON"	    , cAliasQry	, 'Qtde.Viagens'            , PesqPict("G54","G54_QVCFIN")	, TamSX3('G54_QVCFIN')[1]/*Tamanho*/, /*lPixel*/ ,/*{|| code-block de impressao }*/,'CENTER'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem	, "FRANQUIA"	, cAliasQry	, STR0008 /*'Franquia KM'*/ , "@E 999,999,999"				, 15/*Tamanho*/						, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem	, "REALIZADO"	, cAliasQry	, STR0009 /*'KM Rodado'*/   , "@E 999,999,999"				, 15/*Tamanho*/						, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem , "KMEXTRA"     , ''        , 'Km excedente.'           , "@E 999,999,999"				, 12/*Tamanho*/						, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,.T./*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagem	, "G54_QTDCON"	, cAliasQry	, RetTitle('G54_QTDCON')    , PesqPict("G54","G54_QTDCON")	, TamSX3('G54_QTDCON')[1]/*Tamanho*/, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem	, "G54_VLRCON"	, cAliasQry	, RetTitle('G54_VLRCON')    , PesqPict("G54","G54_VLRCON")	, TamSX3('G54_VLRCON')[1]/*Tamanho*/, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem	, "G54_VLRACO"	, cAliasQry	, RetTitle('G54_VLRACO')    , PesqPict("G54","G54_VLRACO")	, TamSX3('G54_VLRACO')[1]/*Tamanho*/, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	TRCell():New(oSecViagem	, "G54_TOTCON"	, cAliasQry	, RetTitle('G54_TOTCON')    , PesqPict("G54","G54_TOTCON")	, TamSX3('G54_PRECON')[1]/*Tamanho*/, /*lPixel*/ ,/*{|| code-block de impressao }*/,'RIGHT'/*cAlign*/,/*lLineBreak*/	,'CENTER'/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)

	oBreak := TRBreak():New(oSecViagem,{||(cAliasQry)->GYD_NUMERO},STR0010 /*"Total"*/)
	oBreak:SetPageBreak(.F.)
	oFunTot1 := TRFunction():New(oSecViagem:Cell('G54_TOTCON')	, , 'SUM' ,oBreak ,,,,.F.,.T.,.F.,oSecViagem,,,)	
	oFunTot2 := TRFunction():New(oSecViagem:Cell('FRANQUIA')	, , 'SUM' ,oBreak ,,,,.F.,.T.,.F.,oSecViagem,,,)	
	oFunTot3 := TRFunction():New(oSecViagem:Cell('REALIZADO')	, , 'SUM' ,oBreak ,,,,.F.,.T.,.F.,oSecViagem,,,)	
	oFunTot4 := TRFunction():New(oSecViagem:Cell('KMEXTRA')	    , , 'SUM' ,oBreak ,,,,.F.,.T.,.F.,oSecViagem,,,)	
	oFunTot1:SetEndReport(lEndReport)
	oFunTot2:SetEndReport(lEndReport)
	oFunTot3:SetEndReport(lEndReport)
	oFunTot4:SetEndReport(lEndReport)

	oSecViagExtra := TRSection():New(oReport,cTitle,'')
	oSecViagExtra:SetTotalInLine(.F.)
	
	TRCell():New(oSecViagExtra , "VIAGEXTRA"  , '' , STR0016 /*'Viagem Extra'*/	, "@!"				    	, 15/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 	
	TRCell():New(oSecViagExtra , "GYN_DTINI"  , '' , RetTitle('GYN_DTINI')  , PesqPict("GYN","GYN_DTINI")	, TamSX3('GYN_DTINI')[1]+2/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "GYN_HRINI"  , '' , RetTitle('GYN_HRINI')  , PesqPict("GYN","GYN_HRINI")	, TamSX3('GYN_HRINI')[1]+1/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "GYN_DTFIM"  , '' , RetTitle('GYN_DTFIM')  , PesqPict("GYN","GYN_DTFIM")	, TamSX3('GYN_DTFIM')[1]+2/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "GYN_HRFIM"  , '' , RetTitle('GYN_HRFIM')  , PesqPict("GYN","GYN_HRFIM")	, TamSX3('GYN_HRFIM')[1]+1/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "GYN_LOCDES" , '' , RetTitle('GYN_LOCDES') , PesqPict("GYN","GYN_LOCDES")	, 43/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "GYN_KMPROV" , '' , RetTitle('GYN_KMPROV') , PesqPict("GYN","GYN_KMPROV")	, TamSX3('GYN_KMPROV')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "GYN_KMREAL" , '' , RetTitle('GYN_KMREAL') , PesqPict("GYN","GYN_KMREAL")	, TamSX3('GYN_KMREAL')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "G54_QVEFIN" , '' , STR0022 /*'Qtde.Viagens'*/ , PesqPict("G54","G54_QVEFIN")	, TamSX3('G54_QVEFIN')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "G54_PREEXT" , '' , RetTitle('G54_PREEXT') , PesqPict("G54","G54_PREEXT")	, TamSX3('G54_PREEXT')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecViagExtra , "G54_VLREXT" , '' , RetTitle('G54_VLREXT') , PesqPict("G54","G54_VLREXT")	, TamSX3('G54_VLREXT')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 

	oSecSubTot := TRSection():New(oReport,cTitle,'')
	oSecSubTot:SetTotalInLine(.F.)
	TRCell():New(oSecSubTot , "TGYN_KMPROV" , '' , Alltrim('Tot. ' + RetTitle('GYN_KMPROV')) , PesqPict("GYN","GYN_KMPROV")	, TamSX3('GYN_KMPROV')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecSubTot , "TGYN_KMREAL" , '' , Alltrim('Tot. ' + RetTitle('GYN_KMREAL')) , PesqPict("GYN","GYN_KMREAL")	, TamSX3('GYN_KMREAL')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecSubTot , "TG54_QVEFIN" , '' , STR0023 /*'Tot. Qtde.Viagens'*/ , PesqPict("G54","G54_QVEFIN")	, TamSX3('G54_QVEFIN')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecSubTot , "TG54_QTDEXT" , '' , RetTitle('G54_QTDEXT'), PesqPict("G54","G54_QTDEXT")	, TamSX3('G54_QTDEXT')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecSubTot , "TG54_TOTEXT" , '' , RetTitle('G54_TOTEXT'), PesqPict("G54","G54_TOTEXT")	, TamSX3('G54_TOTEXT')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 

	oSecTotal := TRSection():New(oReport,cTitle,'')
	oSecTotal:SetTotalInLine(.F.)
	TRCell():New(oSecTotal , "G9W_TOTAPU" , '' , RetTitle('G9W_TOTAPU') , PesqPict("G9W","G9W_TOTAPU")	, TamSX3('G9W_TOTAPU')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecTotal , "G9W_VLACRE" , '' , RetTitle('G9W_VLACRE') , PesqPict("G9W","G9W_VLACRE")	, TamSX3('G9W_VLACRE')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecTotal , "G9W_VLDESC" , '' , RetTitle('G9W_VLDESC') , PesqPict("G9W","G9W_VLDESC")	, TamSX3('G9W_VLDESC')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecTotal , "G9W_TOTCAL" , '' , RetTitle('G9W_TOTCAL') , PesqPict("G9W","G9W_TOTCAL")	, TamSX3('G9W_TOTCAL')[1]/*Tamanho*/, /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author jose.darocha 
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)

	Local oSecCabec      := oReport:Section(1)
	Local oSecViagem     := oReport:Section(2)
	Local oSecViagExtra  := oReport:Section(3)
	Local oSecSubTot     := oReport:Section(4)
	Local oSecTotal      := oReport:Section(5)
	Local nDias          := 0
	Local nKMFranquia    := 0
	Local nKMRodado      := 0
	Local cMesReferencia := Iif(!Empty(mv_par05), MesExtenso(Month(mv_par05)), '' )
	Local cPeriodo       := DtoC(mv_par05) + ' - ' + DtoC(mv_par06)
	Local cContrato      := ''
	Local aDadosExtra    := {}
	Local aViagExtra     := {}
	Local nLinha         := 0
	Local nVlrLinha      := 0
	Local nValorTot      := 0
	Local nTotKMFranq    := 0
	Local nTotKMRodad    := 0
	Local nKMExtra       := 0
	Local nVlrExtra      := 0
	Local cDescLinha     := ''
	Local nX             := 0
	Local cNomeCliente   := ''
	Local cDtExtenso     := Capital( DiaSemana(dDataBase) ) + ', ' + cValTochar(Day(dDataBase)) + ' de ' + MesExtenso(Month(dDataBase)) + ' de ' + cValTochar( Year(dDataBase)) 
	Local bWhile         := Nil 
	Local cCodCli        := ''
	Local cCodLj         := ''
	Local cCliPagante    := ''
	Local cG54_CODGI2    := ''
	Local nG9W_VLACRE    := 0
	Local nG9W_VLDESC	 := 0	
	Local cExpOrdem      := ''
	Local aSubTotais     := {0,0,0,0,0}
	Local nFatorAcre     := 1
	Local nFatorDesc     := 1
	Local nValAcre       := 0
	Local nValDesc       := 0

	If lQuebraCli
		bWhile := {|| (cAliasQry)->(!Eof()) .And. cCodCli == (cAliasQry)->GQR_CLIENT .And. cCodLj == (cAliasQry)->GQR_LOJA .And. cContrato == (cAliasQry)->GYD_NUMERO}
		cExpOrdem := '%' + 'GQR_CLIENT,GQR_LOJA,GYD_NUMERO' + '%'		
	Else
		bWhile := {|| (cAliasQry)->(!Eof()) .And. cContrato == (cAliasQry)->GYD_NUMERO }
		cExpOrdem := '%' + 'GYD_NUMERO,GQR_CLIENT,GQR_LOJA' + '%'			
	EndIf 

	oSecViagem:BeginQuery()

	BeginSQL Alias cAliasQry

		SELECT 
	   		CASE WHEN GYD_CLIENT = ' ' THEN GQR_CLIENT ELSE GYD_CLIENT END GQR_CLIENT,
	   		CASE WHEN GYD_LOJACL = ' ' THEN GQR_LOJA   ELSE GYD_LOJACL END GQR_LOJA,
			GQR_CLIENT CLICAPA,
			GQR_LOJA LJCAPA, 
			GQR_DTINIA,
			GQR_DTFINA,
			GQR_CODIGO,
			G9W_VLACRE,
			G9W_VLDESC,
			G9W_TOTAPU,
			GYD_NUMERO,
			GYD_LOCINI,
			GYD_LOCFIM,
			G54_VLRACO,
			G54_QTDCON,
			G54_VLRCON,
			G54_TOTCON,
			G54_QTDEXT,
			G54_VLREXT,
			G54_TOTEXT,
			G54_CODGI2,
			G54_KMPROV,
	   		G54_KMREAL,
			G54_PRECON,   
	   		G54_QVCFIN QTDDCON,  
	   		G54_QVEFIN QTDDEXT 
		FROM %Table:GQR% GQR 
			INNER JOIN %Table:G9W% G9W ON G9W_FILIAL = %xFilial:G9W%
				AND G9W_CODGQR = GQR_CODIGO
				AND G9W_NUMGY0 BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% 
				AND G9W.%notDel%
			INNER JOIN %Table:GYD% GYD ON GYD.GYD_FILIAL = %xFilial:GYD%
				AND GYD.GYD_NUMERO = G9W.G9W_NUMGY0
				AND GYD.GYD_REVISA = G9W.G9W_REVISA
				AND GYD.%notDel%
			LEFT JOIN %Table:G54% G54 ON G54.G54_FILIAL = %xFilial:G54%
				AND G54.G54_NUMGY0 = GYD.GYD_NUMERO
				AND G54.G54_REVISA = GYD.GYD_REVISA
				AND G54.G54_CODGI2 = GYD.GYD_CODGI2 
				AND G54.%notDel%
		WHERE GQR_FILIAL = %xFilial:GQR% 
			AND GQR.GQR_CLIENT = %Exp:Mv_Par01%
			AND GQR.GQR_LOJA = %Exp:Mv_Par02%
			AND GQR.GQR_DTINIA >= %Exp:DtoS(mv_par05)% 
			AND GQR.GQR_DTFINA <= %Exp:DtoS(mv_par06)% 
			AND GQR.%notDel%  
		ORDER BY %Exp:cExpOrdem%

	ENDSQL
	
	oSecViagem:EndQuery()
	
	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())

		oReport:StartPage()

		oSecCabec:Init()

		aViagExtra  := {}
		aDadosExtra := {}
		cContrato   := (cAliasQry)->GYD_NUMERO
		cCodCli 	:= (cAliasQry)->GQR_CLIENT 
		cCodLj  	:= (cAliasQry)->GQR_LOJA
		cCliPagante := GetAdvFval("SA1","A1_NREDUZ",xFilial("SA1")+cCodCli+cCodLj,1)
		nValorTot   := 0
		nTotKMFranq := 0
		nTotKMRodad := 0
		aSubTotais  := {0,0,0,0,0}

		If lQuebraCli			
			oSecCabec:Cell("NOMECLI"):SetValue( cCliPagante )
			cNomeCliente := cCliPagante
			If (cAliasQry)->G9W_VLACRE > 0
				nFatorAcre := (cAliasQry)->G9W_VLACRE / (cAliasQry)->G9W_TOTAPU 			
			EndIf 
			If (cAliasQry)->G9W_VLDESC > 0
				nFatorDesc := (cAliasQry)->G9W_VLDESC / (cAliasQry)->G9W_TOTAPU
			EndIf 
		Else 
			cNomeCliente:= GetAdvFval("SA1","A1_NREDUZ",xFilial("SA1")+(cAliasQry)->CLICAPA+(cAliasQry)->LJCAPA,1)
		EndIf 

		oSecCabec:Cell("MESREF"):SetValue( cMesReferencia ) 
		oSecCabec:Cell("PERIODO"):SetValue( cPeriodo ) 
		oSecCabec:PrintLine()	

		WHILE !oReport:Cancel() .AND. eVal( bWhile )

			cG54_CODGI2 := (cAliasQry)->G54_CODGI2
			cDescLinha  := cG54_CODGI2 + '-' + TPNOMELINH(cG54_CODGI2) 
			nVlrExtra   := (cAliasQry)->G54_VLREXT
			nKMFranquia := (cAliasQry)->G54_KMPROV
			nKMRodado   := Iif( (cAliasQry)->G54_KMREAL==0,(cAliasQry)->G54_KMPROV,(cAliasQry)->G54_KMREAL)
			nDias       := (cAliasQry)->QTDDCON
			nVlrLinha   := (cAliasQry)->G54_TOTCON
			nG9W_VLACRE := (cAliasQry)->G9W_VLACRE
			nG9W_VLDESC	:= (cAliasQry)->G9W_VLDESC	
			nKMExtra    := (nKMRodado-nKMFranquia)
			
			If (cAliasQry)->G54_TOTEXT > 0

				aViaTmp := GetViaExtra((cAliasQry)->GYD_NUMERO,(cAliasQry)->GQR_DTINIA,(cAliasQry)->GQR_DTFINA,(cAliasQry)->QTDDEXT,cG54_CODGI2) 

				Aadd( aViagExtra , aClone( aViaTmp ))

			EndIf 

			oSecViagem:Init()
			oSecViagem:Cell("LINHAS")    :SetValue(cDescLinha) 
			oSecViagem:Cell("DIAS")		 :SetValue(nDias) 
			oSecViagem:Cell("FRANQUIA")	 :SetValue(nKMFranquia) 
			oSecViagem:Cell("REALIZADO") :SetValue(nKMRodado) 
			oSecViagem:Cell("KMEXTRA")   :SetValue(nKMExtra) 
			oSecViagem:PrintLine()

			(cAliasQry)->(DbSkip())  
			
		EndDo 

		nValorTot   += oSecViagem:ABREAK[1]:AFUNCTION[1]:UVALUE
		nTotKMFranq += oSecViagem:ABREAK[1]:AFUNCTION[2]:UVALUE
		nTotKMRodad += oSecViagem:ABREAK[1]:AFUNCTION[3]:UVALUE

		oSecViagem:Finish()

		If !Empty(aViagExtra)

			For nLinha:= 1 To Len(aViagExtra)
				If nLinha == 1
					oReport:SkipLine(2)
					oSecViagExtra:Init()
				EndIf 

				For nX:=1 To Len(aViagExtra[nLinha])

					oSecViagExtra:Cell("GYN_DTINI") :SetValue(aViagExtra[nLinha][nX][1]) 
					oSecViagExtra:Cell("GYN_HRINI")	:SetValue(aViagExtra[nLinha][nX][2]) 
					oSecViagExtra:Cell("GYN_DTFIM")	:SetValue(aViagExtra[nLinha][nX][3]) 
					oSecViagExtra:Cell("GYN_HRFIM") :SetValue(aViagExtra[nLinha][nX][4]) 
					oSecViagExtra:Cell("GYN_LOCDES"):SetValue(aViagExtra[nLinha][nX][5]) 
					oSecViagExtra:Cell("GYN_KMPROV"):SetValue(aViagExtra[nLinha][nX][6]) 
					oSecViagExtra:Cell("GYN_KMREAL"):SetValue(aViagExtra[nLinha][nX][7]) 
					oSecViagExtra:Cell("G54_QVEFIN"):SetValue(aViagExtra[nLinha][nX][9]) 
					oSecViagExtra:Cell("G54_PREEXT"):SetValue(aViagExtra[nLinha][nX][10]) 
					oSecViagExtra:Cell("G54_VLREXT"):SetValue(aViagExtra[nLinha][nX][11]) 
					oSecViagExtra:PrintLine()	

					aSubTotais[1] += aViagExtra[nLinha][nX][6]
					aSubTotais[2] += aViagExtra[nLinha][nX][7]
					aSubTotais[3] += aViagExtra[nLinha][nX][9]
					aSubTotais[4] := aViagExtra[nLinha][nX][8]
					aSubTotais[5] := aViagExtra[nLinha][nX][12]

				Next nX 					
			Next nLinha 

			nValorTot += aSubTotais[4]
			oSecViagExtra:Finish()

			oSecSubTot:Init()
			oSecSubTot:Cell("TGYN_KMPROV"):SetValue( aSubTotais[1] ) 
			oSecSubTot:Cell("TGYN_KMREAL"):SetValue( aSubTotais[2] ) 
			oSecSubTot:Cell("TG54_QVEFIN"):SetValue( aSubTotais[3] ) 
			oSecSubTot:Cell("TG54_TOTEXT"):SetValue( aSubTotais[4] ) 
			oSecSubTot:Cell("TG54_QTDEXT"):SetValue( aSubTotais[5] ) 
			oSecSubTot:PrintLine()		
			oSecSubTot:Finish()			

		EndIf 

		nValAcre := nG9W_VLACRE
		nValDesc := nG9W_VLDESC

		If nG9W_VLDESC > 0 .And. lQuebraCli
			nValDesc := Round(nValorTot*nFatorDesc,2)
		EndIf 
		
		If nG9W_VLACRE > 0 .And. lQuebraCli
			nValAcre := Round(nValorTot*nFatorAcre,2)
		EndIf 

		oSecTotal:Init()
		oSecTotal:Cell("G9W_TOTAPU"):SetValue(nValorTot) 
		oSecTotal:Cell("G9W_VLACRE"):SetValue(nValAcre) 
		oSecTotal:Cell("G9W_VLDESC"):SetValue(nValDesc) 
		oSecTotal:Cell("G9W_TOTCAL"):SetValue(nValorTot+nValAcre-nValDesc) 
		oSecTotal:PrintLine()	
		oSecTotal:Finish()

		oSecCabec:Finish()

		oReport:SkipLine(5)
		oReport:PrtLeft(cDtExtenso)						

		oReport:SkipLine(10)
		oReport:PrtLeft( Space(15) + Replicate('_',85) + Space(20)  + Replicate('_',85) )						
		oReport:SkipLine(1)
		oReport:PrtLeft( Space(15) + Padc(Alltrim(cNomeCliente),85) + Space(20)  + Padc(Alltrim(SM0->M0_NOMECOM),85) )						
		oReport:SkipLine(5)

		oReport:EndPage()	  

   EndDo 
   
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetViaExtra()
Função de busca de dados referente apontamentos Extras

@sample GetViaExtra(cContrato,dDataIni,dDataFim,nDias)

@author jose.darocha 
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetViaExtra(cContrato,dDataIni,dDataFim,nDias,cG54_CODGI2) 
	Local aAreaAtu   := GetArea()
	Local cNewAlias  := GetNextAlias()
	Local aRetorno   := {}
	Local cDescVia   := ''
	Local aOpcoes    := RetSx3Box(Posicione("SX3", 2, 'G54_PREEXT', "X3CBox()"),,, 1)
	Local nPos       := 0
	Local cTpPrecif  := ''

	BEGINSQL ALIAS cNewAlias
		Column GYN_DTINI as Date 
		Column GYN_DTFIM as Date 
		SELECT 
			G54_NUMGY0,
			G54_REVISA,
			G54_QTDEXT,
			G54_VLREXT,
			G54_TOTEXT,
			GYN_LOCORI,
			GYN_LOCDES,
			GYN_DTINI,
			GYN_DTFIM,
			GYN_HRINI,
			GYN_HRFIM,
			GYN_KMPROV,
			GYN_KMREAL,
			G54_KMPREX,
			G54_KMREEX,
			G54_PREEXT
		FROM %Table:G54% G54   
		INNER JOIN %Table:GYN% GYN 
				 ON GYN_FILIAL = %xFilial:GYN%
				AND GYN_CODGY0 = G54_NUMGY0    
				AND GYN_LINCOD = G54_CODGI2   
				AND GYN_EXTRA = 'T'    
				AND GYN.%notDel%
		WHERE   
			    G54_FILIAL = %xFilial:G54%
			AND G54_NUMGY0 = %exp:cContrato%
			AND G54_CODGI2 = %exp:cG54_CODGI2%
			AND GYN_DTINI >= %Exp:DtoS(dDataIni)% 
			AND GYN_DTFIM <= %Exp:DtoS(dDataFim)% 
			AND G54.%notDel%   
	ENDSQL	

	While (cNewAlias)->(!Eof())	
		cTpPrecif := ''

		If (nPos := Ascan( aOpcoes, {|e| e[2] == (cNewAlias)->G54_PREEXT} )) > 0
			cTpPrecif := Alltrim(aOpcoes[nPos][3])
		EndIf 

		cDescVia := cG54_CODGI2+'-'+TPNOMELINH(cG54_CODGI2)		

		aadd( aRetorno,{;
			Dtoc((cNewAlias)->GYN_DTINI),;	//1
			   	  (cNewAlias)->GYN_HRINI,;	//2	
			Dtoc((cNewAlias)->GYN_DTFIM),;	//3
				  (cNewAlias)->GYN_HRFIM,;	//4
								cDescVia,;	//5
				 (cNewAlias)->GYN_KMPROV,;	//6
				 (cNewAlias)->GYN_KMREAL,;	//7
				 (cNewAlias)->G54_TOTEXT,;	//8
				                       1,;	//9
				               cTpPrecif,;	//10
				 (cNewAlias)->G54_VLREXT,;	//11
				  (cNewAlias)->G54_QTDEXT;	//12
						} )

		(cNewAlias)->(DbSkip())

	EndDo 

	(cNewAlias)->(DbCloseArea())	

	RestArea( aAreaAtu )

Return aRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetContr()
Função de busca os contratos referentes a apuração.
Retorna o primeiro e ultimo contrato utilizado no range do parametro
do relatório

@sample GetContr()

@author jose.darocha 
@since 31/01/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetContr()
	Local aAreaAtu := GetArea()
	Local aTemp    := {}
	Local aContr   := {}

	G9W->(DbSetOrder(1))
	If G9W->(DbSeek(xFilial("G9W")+GQR->GQR_CODIGO))
		While G9W->(!Eof()) .And. xFilial('G9W') == G9W->G9W_FILIAL .And. G9W->G9W_CODGQR == GQR->GQR_CODIGO
			If AsCan(aTemp,{|x| x == G9W->G9W_NUMGY0}) == 0
				aadd(aTemp,G9W->G9W_NUMGY0)
			EndIf				
			G9W->(DbSkip())
		EndDo 
	EndIf 

	If !Empty(aTemp)
		aContr := {aTemp[1],aTail(aTemp)}
	EndIf 

	RestArea( aAreaAtu )

Return aContr

//-------------------------------------------------------------------
/*/{Protheus.doc} QuebraRel()
Função de pergunta de quebra de relatório por cliente

@sample QuebraRel()

@author jose.darocha 
@since 21/03/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function QuebraRel()
	Local lRetorno  := .F.
	Local aParamBox := {}
	Local aPergRet  := {}
	Local aCombo    := {"Sim", "Não"}
	Local aMvPar    := {}
	Local nX        := 0

	For nX := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
	Next nX

	aAdd(aParamBox,{2,"Quebra página por cliente?",2,aCombo,50,"",.F.})

	If ParamBox(aParamBox, 'Informe e quebra de página', aPergRet) 
		If ValType(aPergRet[1]) == 'N'
			lRetorno := aPergRet[1] == 1
		Else 
			lRetorno := ascan( aCombo , {|x| Upper(x) == Upper(aPergRet[1])}) == 1
		EndIF 
	EndIf 

	For nX := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
	Next nX	

Return lRetorno 
