#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "GTPR950.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR950()
Relatório Geracão de dados financeiros (ANTT, DER e SIE (SC))

@sample GTPR950()

@author jose.darocha
@since 06/12/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR950()

	Local oReport
	Local cPerg  	:= 'GTPR950'
	Local aAreaAtu 	:= GetArea()

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        If Pergunte(cPerg, .T.)
            oReport := ReportDef(cPerg)
            oReport:PrintDialog()
        EndIf 

	EndIf

	RestArea( aAreaAtu )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author jose.darocha 
@since 06/12/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

	Local cTitle     := STR0001	//"Geracão de dados financeiros (ANTT, DER e SIE (SC))"
	Local cHelp      := STR0002	//"Relatório de dados Financeiros"
	Local cAliasQry  := GetNextAlias()
	Local aCpos      := {}
	Local nVezes     := 0
	Local nTam       := 0
	Local nColSpace  := 1
	Local lLandscape := .T. 
	Local lPageBreak := .T.	// Falso - Não pula página na quebra do totalizador
	Local lHeaderSection := .T.
	Local cExpressao := ''
	Local oReport
	Local oSecao
    Local oBreak
	Local cTotBilhetes := ''

	aCpos := {	'GIC_CODIGO','GIC_LINHA','GIC_AGENCI','GIC_DTVIAG','GIC_DTVEND','GIC_BILHET','GIC_CHVBPE','GIC_NUMBPE','GIC_VLRBPE','GIC_VLRPGT';
                ,'GI2_ORGAO','GI0_DESCRI' }

	cExpressao := ArrTokStr(aCpos, ",")				

	oReport := TReport():New('GTPR950',cTitle,cPerg,{|oReport|ReportPrint(oReport,oSecao,cAliasQry,cExpressao)},cHelp,lLandscape/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,nColSpace/*nColSpace*/)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)

	oSecao := TRSection():New(oReport, 'CABECALHO', NIL)
	oSecao:SetTotalInLine(.F.)
	oSecao:SetHeaderBreak(.T.)
	
	oSecao:SetHeaderSection(lHeaderSection)

	For nVezes:=1 To Len(aCpos)
   		nTam := TamSX3(aCpos[nVezes])[1] + Iif(TamSX3(aCpos[nVezes])[3]=='D',4,0)
				TRCell():New(oSecao,aCpos[nVezes], cAliasQry, RetTitle(aCpos[nVezes]) , /*Picture*/, nTam /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) 
	Next nVezes

    oBreak:= TRBreak():New(oReport,{ || (cAliasQry)->GI2_ORGAO + '-' + Alltrim( (cAliasQry)->GI0_DESCRI )  },{|| STR0004 } ,.F.,,lPageBreak)		//'Total Orgão:'
	oBreak:OnBreak({|x|  oReport:SkipLine(), cTotBilhetes := OemToAnsi(STR0004) + ' ['+x+']' })
	oBreak:SetTotalText({|| cTotBilhetes + Space(50) + STR0005 })		//'Total bilhetes'
   
	TRFunction():New(oSecao:Cell('GIC_BILHET') , , 'COUNT' ,oBreak,,,,.F.,.T.,.F.,oSecao,,,)
	TRFunction():New(oSecao:Cell('GIC_VLRBPE') , , 'SUM'   ,oBreak,,,,.F.,.T.,.F.,oSecao,,,)
	TRFunction():New(oSecao:Cell('GIC_VLRPGT') , , 'SUM'   ,oBreak,,,,.F.,.T.,.F.,oSecao,,,)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author jose.darocha 
@since 06/12/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSecao,cAliasQry,cExpressao)

	cExpressao := '%' + cExpressao + '%'

	oSecao:BeginQuery()

	BeginSQL Alias cAliasQry

        SELECT 
            %Exp:cExpressao%
        FROM %Table:GIC% GIC
        INNER JOIN %Table:GI2% GI2 ON GIC_FILIAL = %xFilial:GIC% AND GI2_COD = GIC_LINHA AND GI2.%notDel%
        INNER JOIN %Table:GI0% GI0 ON GI0_FILIAL = %xFilial:GI0% AND GI0_COD = GI2_ORGAO AND GI0.%notDel%
        WHERE 
                GIC_FILIAL = %xFilial:GIC%
            AND GIC_DTVEND BETWEEN %Exp:Dtos(MV_PAR01)%  AND %Exp:Dtos(MV_PAR02)%    
            AND GIC_AGENCI BETWEEN %Exp:MV_PAR03%  AND %Exp:MV_PAR04%    
            AND GI2_ORGAO BETWEEN %Exp:MV_PAR05%  AND %Exp:MV_PAR06%    
            AND GIC_LINHA <> ' ' 
            AND GIC.%notDel%
        ORDER BY GI2_ORGAO,GIC_DTVIAG,GIC_LINHA

	EndSql 
	
	oSecao:EndQuery()

	oSecao:Print()	
   
Return
