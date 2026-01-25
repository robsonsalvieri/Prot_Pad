#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR756.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR756()
Relatório Registro de danos materiais na bagagem

@sample GTPR756()

@author jose.darocha
@since 16/10/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR756()

	Local oReport
	Local cPerg  	:= 'GTPR756'
	Local aAreaAtu 	:= GetArea()

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        Pergunte(cPerg, .F.)
		oReport := ReportDef(cPerg)
		oReport:PrintDialog()

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
@since 16/10/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

	Local cTitle    := STR0001	//"Registro de danos materiais na bagagem"
	Local cHelp     := STR0002	//"Relatório de Danos Materiais"
	Local cAliasQry := GetNextAlias()
    Local cCampo    := ''
    Local lLandscape:= .T.
	Local oReport
	Local oCabec 
	Local oItens

	oReport := TReport():New('GTPR756',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry)},cHelp,lLandscape/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
	oReport:SetPortrait(.T.)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)

	oCabec := TRSection():New(oReport, STR0003, NIL)	//'CABECALHO'
	oCabec:SetTotalInLine(.F.)

    cCampo := 'H6K_CODIGO'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_CONDAN'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_CULPAB'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_COLABO'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'GYG_NOME'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, {|| GetAdvFval("GYG","GYG_NOME",xFilial("GYG")+(cAliasQry)->H6K_COLABO,1)}/*{|| code-block de impressao }*/) 
    cCampo := 'H6K_CODGI2'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,'TMP_LINHA', cAliasQry	,'Descr.Linha' , /*Picture*/, 40 /*Tamanho*/, /*lPixel*/,{|| Left(TPNomeLinh((cAliasQry)->H6K_CODGI2),40)} /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_DTVIAG'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_DTOCOR'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_DTSLA'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_ORICON'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_AGENCI'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'GI6_DESCRI'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_VLRDOC'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6K_NOMEPS'
	TRCell():New(oCabec,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 

	oItens := TRSection():New(oReport,cTitle,cAliasQry)
	oItens:SetTotalInLine(.F.)

    cCampo := 'H6L_ITEM'
	TRCell():New(oItens,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6L_DESCIT'
	TRCell():New(oItens,cCampo, cAliasQry	,RetTitle(cCampo) , /*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
    cCampo := 'H6L_VALOR'
	TRCell():New(oItens,cCampo, cAliasQry	,RetTitle(cCampo) , PesqPict("H6L",cCampo)/*Picture*/, FwGetSx3Cache(cCampo, "X3_TAMANHO" )/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 

	oBreak := TRBreak():New(oItens,{||(cAliasQry)->H6K_CODIGO},'' /*"Total"*/)
	oBreak:SetPageBreak(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author jose.darocha 
@since 16/10/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)

	Local oCabec := oReport:Section(1)
	Local oItens := oReport:Section(2)
    Local cCodigo:= ''

	oItens:BeginQuery()

	BeginSQL Alias cAliasQry

        SELECT 
            H6K_CODIGO,
            H6K_CONDAN,
            H6K_CULPAB,
            H6K_COLABO,
            H6K_CODGI2,
            H6K_DTVIAG,
            H6K_CODGIC,
            H6K_DTOCOR,
            H6K_DTSLA,
            H6K_ORICON,
            H6K_AGENCI,
            GI6_DESCRI,
            H6K_VLRDOC,
            H6K_NOMEPS,
            H6L_ITEM,
            H6L_DESCIT,
            H6L_VALOR
        FROM %Table:H6K% H6K 
        INNER JOIN %Table:H6L% H6L ON H6L_FILIAL = %xFilial:H6L% AND H6L_CODH6K = H6K_CODIGO AND H6L.%notDel%
        INNER JOIN %Table:GI6% GI6 ON GI6_FILIAL = %xFilial:GI6% AND GI6_CODIGO = H6K_AGENCI AND GI6.%notDel%
        WHERE
                H6K_FILIAL = %xFilial:H6K%
            AND H6K_DTOCOR BETWEEN %Exp:Dtos(MV_PAR01)% AND %Exp:Dtos(MV_PAR02)% 
            AND H6K_CONDAN = %Exp:cValToChar(MV_PAR03)%
            AND H6K.%notDel%
		ORDER BY H6K_CODIGO,H6L_ITEM

	ENDSQL
	
	oItens:EndQuery()
	
	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())

		oReport:StartPage()

		oCabec:Init()
		oCabec:PrintLine()	

		cCodigo := (cAliasQry)->H6K_CODIGO

		WHILE !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	.And. cCodigo == (cAliasQry)->H6K_CODIGO

			oItens:Init()
			oItens:PrintLine()

			(cAliasQry)->(DbSkip())  
			
		EndDo 

		oItens:Finish()

		oCabec:Finish()

		oReport:EndPage()	  

   EndDo 
   
Return
