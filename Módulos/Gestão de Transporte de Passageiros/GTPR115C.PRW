#INCLUDE "PROTHEUS.CH"
#INCLUDE "gtpr115c.CH"
#INCLUDE "REPORT.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR115C()
Relatório de Bilhetes Fiscal Substituidos

@sample 	GTPR115()
@return		oReport
@author 	kaique.olivero
@since		09/11/2023

/*/
//--------------------------------------------------------------------------------------------------------------------
Function GTPR115C()
Local cPerg		:= "GTPR115C"
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

oReport := TReport():New("GTPR115C",STR0001,cPerg,{|oReport| Rt115Print(oReport, cAlias1)},STR0001) //"Bilhetes Fiscal Substituidos"

oSection1 := TRSection():New(oReport,FwX2Nome("GIC") ,{"GIC"},,,,,,,.T.,,,,,,.T.)
oSection1:SetLineCondition( {|| Rt115Cond(cAlias1) })

TRCell():New(oSection1,"GIC_STAPRO", "GIC", , /*Picture*/, 25/*Tamanho*/, /*lPixel*/,{|| AllTrim(X3CBoxDesc( "GIC_STAPRO",(cAlias1)->GIC_STAPRO ))})
TRCell():New(oSection1,"GIC_FILNF" , "GIC", , /*Picture*/, TamSX3("GIC_FILNF")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_NOTA"  , "GIC", , /*Picture*/, TamSX3("GIC_NOTA")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_SERINF", "GIC", , /*Picture*/, TamSX3("GIC_SERINF")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_NUMBPE", "GIC", , /*Picture*/, TamSX3("GIC_NUMBPE")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_CHVBPE", "GIC", , /*Picture*/, TamSX3("GIC_CHVBPE")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_CHVSUB", "GIC", , /*Picture*/, TamSX3("GIC_CHVSUB")[1], /*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_AGENCI", "GIC", , /*Picture*/, TamSX3("GIC_AGENCI")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VENORI", "GIC", STR0002, /*Picture*/, TamSX3("GIC_DTVEND")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Data Ori."
TRCell():New(oSection1,"GIC_VENCAN", "GIC", STR0003, /*Picture*/, TamSX3("GIC_DTVEND")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) //"Data Can."
TRCell():New(oSection1,"GIC_VLBICM", "GIC", , /*Picture*/, TamSX3("GIC_VLBICM")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_CREDPR", "GIC", STR0004, PesqPict("GIC","GIC_VLICMS") , TamSX3("GIC_VLICMS")[1]/*Tamanho*/, /*lPixel*/, {|| ((cAlias1)->GIC_VLICMS*MV_PAR07)/100}) //"Créd. Presu."
TRCell():New(oSection1,"GIC_VLICMS", "GIC", , /*Picture*/, TamSX3("GIC_VLICMS")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLPIS" , "GIC", , /*Picture*/, TamSX3("GIC_VLPIS")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLCOF" , "GIC", , /*Picture*/, TamSX3("GIC_VLCOF")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLRDSC" , "GIC", , /*Picture*/, TamSX3("GIC_VLRDSC")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLRBPE" , "GIC", , /*Picture*/, TamSX3("GIC_VLRBPE")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VLRPGT" , "GIC", , /*Picture*/, TamSX3("GIC_VLRPGT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GIC_VALTOT" , "GIC", , /*Picture*/, TamSX3("GIC_VALTOT")[1]/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
 
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
    cWhere := "AND GICSUBT.GIC_STAPRO = '1' " //Processado
Elseif MV_PAR05 == 2
    cWhere := "AND GICSUBT.GIC_STAPRO = '0' " //Não Processado
Endif

cWhere := "%"+cWhere+"%"

BEGIN REPORT QUERY oSection1

BeginSQL Alias cAlias1
    Column GIC_VENCAN as Date
    Column GIC_VENORI as Date
    
    SELECT  GICSUBT.GIC_STAPRO,
            GICSUBT.GIC_CHVBPE,
            GICSUBT.GIC_NUMBPE,
            GICSUBT.GIC_TIPCAN, 
            GICSUBT.GIC_DTVEND,
            GICSUBT.GIC_CHVSUB,
            GICSUBT.GIC_DTVEND AS GIC_VENCAN,
            GICORI.GIC_DTVEND AS GIC_VENORI,      
            GICORI.GIC_VLBICM,
            GICORI.GIC_ALICMS,
            GICORI.GIC_VLICMS,
            GICORI.GIC_VLPIS,
            GICORI.GIC_VLCOF,
            GICORI.GIC_VLRDSC,
            GICORI.GIC_VLRBPE,
            GICORI.GIC_VLRPGT, 
            GICORI.GIC_VALTOT,
            GICORI.GIC_NOTA,
            GICORI.GIC_SERINF,
            GICORI.GIC_FILNF,
            CASE 
                WHEN GICCAN.GIC_STATUS IS NULL THEN ' ' 
            ELSE 'C' 
            END AS GIC_STATUS
    FROM %table:GIC% GICSUBT
        LEFT JOIN %table:GIC% GICORI ON GICORI.GIC_CHVBPE = GICSUBT.GIC_CHVSUB
            AND GICORI.GIC_STATUS IN ('V','T')
            AND GICORI.%notDel%
        LEFT JOIN %table:GIC% GICCAN ON GICSUBT.GIC_CHVBPE = GICCAN.GIC_CHVSUB
            AND GICCAN.GIC_STATUS = 'C'
            AND GICCAN.%notDel%
    WHERE GICSUBT.GIC_FILIAL = GICSUBT.GIC_FILIAL
        AND GICSUBT.GIC_DTVEND BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GICSUBT.GIC_AGENCI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND GICSUBT.%notDel%
        %exp:cWhere%
        AND GICSUBT.GIC_STATUS = 'T' 
        AND GICSUBT.GIC_CHVBPE <> ''
    ORDER BY GICSUBT.GIC_TIPCAN
EndSql

END REPORT QUERY oSection1

oSection1:Print()

(cAlias1)->(DbCloseArea())
          
Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt115Cond()
Condição do parâmetro de datas

@sample 	Rt115Cond(cAlias1)
			
@author 	kaique.olivero
@since		09/11/2023
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt115Cond(cAlias1)
Local lRet := .T.

If MV_PAR06 == 1
    lRet := SubStr(dTos((cAlias1)->GIC_VENCAN),1,6) <> SubStr(dTos((cAlias1)->GIC_VENORI),1,6)
Elseif MV_PAR06 == 2
    lRet := SubStr(dTos((cAlias1)->GIC_VENCAN),1,6) == SubStr(dTos((cAlias1)->GIC_VENORI),1,6)    
Endif

IF (cAlias1)->GIC_STATUS = 'C'
    lRet := .F.
ENDIF

Return lRet
