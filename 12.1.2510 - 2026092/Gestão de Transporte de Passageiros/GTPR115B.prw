#INCLUDE "PROTHEUS.CH"
#INCLUDE "gtpr115b.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR115B()
Relatório de Bilhetes Fiscal Cancelados

@sample 	GTPR115()
@return		oReport
@author 	kaique.olivero
@since		09/11/2023

/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTPR115B()
Local cPerg		:= "GTPR115B"
Local oReport	:=  Nil

If TRepInUse() 
	Pergunte(cPerg,.T.)		
	oReport := Rt115RDef(cPerg)
	oReport:SetLandScape()
	oReport:PrintDialog()
EndIf

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt115RDef()
Monta as Sections para impressão do relatório

@sample Rt115RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	kaique.olivero
@since		09/11/2023

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt115RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local cAlias1		:= GetNextAlias()

Pergunte(cPerg,.F.)

oReport := TReport():New("GTPR115B",STR0001,cPerg,{|oReport| Rt115Print(oReport, cAlias1)},STR0001) //"Bilhetes Fiscal Cancelados"

oSection1 := TRSection():New(oReport,FwX2Nome("GIC") ,{"GIC"},,,,,,,.T.,,,,,,.T.)
oSection1:SetLineCondition( {|| SubStr(dTos((cAlias1)->GIC_VENCAN),1,6) <> SubStr(dTos((cAlias1)->GIC_VENORI),1,6) .AND. EMPTY((cAlias1)->GIC_CHVSUB)})

TRCell():New(oSection1,"GIC_STAPRO", "GIC", , /*Picture*/, 25/*Tamanho*/, /*lPixel*/,{|| AllTrim(X3CBoxDesc( "GIC_STAPRO",(cAlias1)->GIC_STAPRO ))})
TRCell():New(oSection1,"GIC_FILNF" , "GIC", , /*Picture*/, TamSX3("GIC_FILNF")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_NOTA"  , "GIC", , /*Picture*/, TamSX3("GIC_NOTA")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_SERINF", "GIC", , /*Picture*/, TamSX3("GIC_SERINF")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_NUMBPE", "GIC", , /*Picture*/, TamSX3("GIC_NUMBPE")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_CHVBPE", "GIC", , /*Picture*/, TamSX3("GIC_CHVBPE")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_AGENCI", "GIC", , /*Picture*/, TamSX3("GIC_AGENCI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VENORI", "GIC", STR0003, /*Picture*/, TamSX3("GIC_DTVEND")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Data Ori."
TRCell():New(oSection1,"GIC_VENCAN", "GIC", STR0004, /*Picture*/, TamSX3("GIC_DTVEND")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Data Can."
TRCell():New(oSection1,"GIC_VLBICM", "GIC", , /*Picture*/, TamSX3("GIC_VLBICM")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_CREDPR", "GIC", STR0005, PesqPict("GIC","GIC_VLICMS") , TamSX3("GIC_VLICMS")[1]/*Tamanho*/, /*lPixel*/, {|| ((cAlias1)->GIC_VLICMS*MV_PAR06)/100 }) //"Créd. Presu."
TRCell():New(oSection1,"GIC_VLICMS", "GIC", , /*Picture*/, TamSX3("GIC_VLICMS")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLPIS" , "GIC", , /*Picture*/, TamSX3("GIC_VLPIS")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLCOF" , "GIC", , /*Picture*/, TamSX3("GIC_VLCOF")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLRDSC", "GIC", , /*Picture*/, TamSX3("GIC_VLRDSC")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLRBPE", "GIC", , /*Picture*/, TamSX3("GIC_VLRBPE")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLRPGT", "GIC", , /*Picture*/, TamSX3("GIC_VLRPGT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VALTOT", "GIC", , /*Picture*/, TamSX3("GIC_VALTOT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

TRFunction():New(oSection1:Cell("GIC_VLBICM"),,"SUM",,,,,,.F.,.F.,)
TRFunction():New(oSection1:Cell("GIC_CREDPR"),,"SUM",,,,,,.F.,.F.,)
TRFunction():New(oSection1:Cell("GIC_VLICMS"),,"SUM",,,,,,.F.,.F.,)
TRFunction():New(oSection1:Cell("GIC_VLPIS") ,,"SUM",,,,,,.F.,.F.,)
TRFunction():New(oSection1:Cell("GIC_VLCOF") ,,"SUM",,,,,,.F.,.F.,)
TRFunction():New(oSection1:Cell("GIC_VALTOT"),,"SUM",,,,,,.F.,.F.,)

Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt115Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt115Print(oReport, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@author 	kaique.olivero
@since		09/11/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt115Print(oReport, cAlias1)
Local oSection1	:= oReport:Section(1)		
Local cWhere   := ""

//MV_PAR05 == 3 Todos 
If MV_PAR05 == 1
    cWhere := "AND GICCANC.GIC_STAPRO = '1' " //Processado
Elseif MV_PAR05 == 2
    cWhere := "AND GICCANC.GIC_STAPRO = '0' " //Não Processado
Endif

cWhere := "%"+cWhere+"%"

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1
    Column GIC_VENCAN as Date
    Column GIC_VENORI as Date
    
    SELECT GICCANC.GIC_STAPRO,
           GICCANC.GIC_CHVBPE,
           GICCANC.GIC_TIPCAN,
           GICCANC.GIC_NUMBPE,
           GICCANC.GIC_AGENCI,
           GICCANC.GIC_DTVEND GIC_VENCAN,
           GICORI.GIC_DTVEND GIC_VENORI,
           GICCANC.GIC_CHVSUB GIC_CHVSUB,
           GICORI.GIC_VLBICM,
           GICORI.GIC_ALICMS,
           GICORI.GIC_VLICMS,
           GICORI.GIC_VLPIS,
           GICORI.GIC_VLCOF,
           GICORI.GIC_VLRDSC,
           GICORI.GIC_VLRBPE,
           GICORI.GIC_VLRPGT, 
           GICCANC.GIC_VALTOT,
           GICORI.GIC_NOTA,
           GICORI.GIC_SERINF,
           GICORI.GIC_FILNF
    FROM %table:GIC% GICCANC
        LEFT JOIN %table:GIC% GICORI ON GICORI.GIC_CHVBPE = GICCANC.GIC_CHVBPE
            AND GICORI.GIC_STATUS IN ('V','T')
            AND GICORI.%notDel%
    WHERE GICCANC.GIC_FILIAL = GICCANC.GIC_FILIAL
        AND GICCANC.GIC_DTVEND BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GICCANC.GIC_AGENCI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND GICCANC.%notDel%
        %exp:cWhere%
        AND GICCANC.GIC_STATUS IN ('C','D') 
        AND GICCANC.GIC_TIPCAN <> ''
        AND GICCANC.GIC_CHVBPE <> ''
    ORDER BY GICCANC.GIC_TIPCAN
EndSql

END REPORT QUERY oSection1

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)
