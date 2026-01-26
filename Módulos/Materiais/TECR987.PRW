#include "protheus.ch"
#include "report.ch"
#include "TECR987.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR987
Relatorio de Pedido de Vendas x Competência

@author Vitor kwon
@since 06/06/2023
@version P12.23.10
/*/
//-------------------------------------------------------------------
Function TECR987()

Local oReport

If !Pergunte("TECR987",.T.)
	Return
EndIf

oReport := ReportDef()
oReport:PrintDialog()	

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Monta as definições do relatorio de Pedido de Vendas x Competência

@author Vitor kwon
@since 06/06/2023
@version P12.23.10

/*/
//-------------------------------------------------------------------------------------

Static Function ReportDef()

Local oTFJ
Local oTFL
Local oSC5
LOCAL oReport

Pergunte("TECR987",.F.)

DEFINE REPORT oReport NAME "TECR987" TITLE STR0001 PARAMETER "TECR987" ACTION {|oReport| PrintReport(oReport),""} //#Pedidos de Vendas x Competência

    DEFINE SECTION oTFJ OF oReport TITLE STR0001 TABLES "TFJ","SA1" //#Pedidos de Vendas x Competência

        DEFINE CELL NAME "TFJ_FILIAL"   OF oTFJ ALIAS "TFJ" TITLE STR0002  //"Filial"   
        DEFINE CELL NAME "TFJ_CONTRT"   OF oTFJ ALIAS "TFJ" TITLE STR0003 //"Contrato"
        DEFINE CELL NAME "TFJ_CODENT"   OF oTFJ ALIAS "TFJ" TITLE STR0004 //"Cod. Cliente"
        DEFINE CELL NAME "TFJ_LOJA"     OF oTFJ ALIAS "TFJ" TITLE STR0005 //"Loja"
        DEFINE CELL NAME "A1_NOME"      OF oTFJ ALIAS "SA1" TITLE STR0006 //"Cliente"


		  	DEFINE SECTION oTFL OF oTFJ TITLE STR0007    TABLE "TFL","ABS" //"Locais"   

            DEFINE CELL NAME "TFL_LOCAL"    OF oTFL ALIAS "TFL" TITLE STR0008 //"Cód. Local"
			DEFINE CELL NAME "ABS_DESCRI"   OF oTFL ALIAS "ABS" TITLE STR0009 //"Local"
			DEFINE CELL NAME "TFL_DTINI"    OF oTFL ALIAS "TFL" TITLE STR0010 //"Data Inicial" 
            DEFINE CELL NAME "TFL_DTFIM"    OF oTFL ALIAS "TFL" TITLE STR0011 //'Data Final' 

			oTFL:SetLeftMargin(05)

			DEFINE SECTION oSC5 OF oTFL TITLE "Competência"    TABLE "SC5","CND","TFV" //"Locais"   

            DEFINE CELL NAME "C5_NUM"       OF oSC5 ALIAS "SC5" TITLE STR0012 //Pedido"
			DEFINE CELL NAME "CND_COMPET"   OF oSC5 ALIAS "CND" TITLE STR0013 //"Competência"
			DEFINE CELL NAME "CND_VLTOT"    OF oSC5 ALIAS "CND" TITLE STR0014 //"Valor da Medição"
			DEFINE CELL NAME "TFV_DTINI"    OF oSC5 ALIAS "TFV" TITLE STR0010 //"Data Inicial" 
            DEFINE CELL NAME "TFV_DTFIM"    OF oSC5 ALIAS "TFV" TITLE STR0011 //'Data Final' 

			oSC5:SetLeftMargin(10)

Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Monta a query para exebir no relatório.
@author Vitor kwon
@since 06/06/2023
@version P12.23.10
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³                                      ³
//³ MV_PAR01 : Contrato ate ?                                              ³                                              ³
//³ MV_PAR02 : Filial ?                                                    ³                                        ³
//³ MV_PAR03 : Data De?                                                    ³
//³ MV_PAR04 : Data Até?     											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

Local cAlias1     := GetNextAlias()
Local cAlias2     := GetNextAlias()
Local cAlias3     := GetNextAlias()
Local nX          := 0
Local nZ          := 0
Local cValMVPAR1  := ""
Local cQryMVPAR1  := ""
Local aConMVPAR1  := {}
Local cValMVPAR2  := ""
Local cQryMVPAR2  := ""
Local aConMVPAR2  := {}
Local cFiSA1TFJ := FWJoinFilial("SA1","TFJ","SA1","TFJ",.T.)
Local cFiTFVTFJ := FWJoinFilial("TFV","TFJ","TFV","TFJ",.T.)
Local cFiABSTFL := FWJoinFilial("ABS","TFL","ABS","TFL",.T.)
Local cFiTFVTFL := FWJoinFilial("TFV","TFL","TFV","TFL",.T.)
Local cFiCNDSC5 := FWJoinFilial("CND","SC5","CND","SC5",.T.)
Local cFiTFVSC5 := FWJoinFilial("TFV","SC5","TFV","SC5",.T.)
Local cFiTFLSC5 := FWJoinFilial("TFL","SC5","TFL","SC5",.T.)

cFiSA1TFJ := "%"+cFiSA1TFJ+"%"
cFiTFVTFJ := "%"+cFiTFVTFJ+"%"
cFiABSTFL := "%"+cFiABSTFL+"%"
cFiTFVTFL := "%"+cFiTFVTFL+"%"
cFiCNDSC5 := "%"+cFiCNDSC5+"%"
cFiTFVSC5 := "%"+cFiTFVSC5+"%"
cFiTFLSC5 := "%"+cFiTFLSC5+"%"

MakeSqlExp("TECR982")

If !Empty(MV_PAR01)
    cValMVPAR1    := Alltrim(MV_PAR01)
	aConMVPAR1 := StrTokArr(cValMVPAR1,";")
	For nX := 1 To LEN(aConMVPAR1)
		If nX == 1
			cQryMVPAR1 += " IN ("
		EndIf
		cQryMVPAR1 += "'" +  aConMVPAR1[nX] 
		If nX == LEN(aConMVPAR1)
			cQryMVPAR1 += " ') "
		else
			cQryMVPAR1 +=  "',"	
		Endif
	Next nX   
	cQryMVPAR1 := 	"%"+cQryMVPAR1+"%"
EndIf

If !Empty(MV_PAR02)
    cValMVPAR2    := Alltrim(MV_PAR02)
	aConMVPAR2 := StrTokArr(cValMVPAR2,";")
	For nZ := 1 To LEN(aConMVPAR2)
		If nZ == 1
			cQryMVPAR2 += " IN ("
		EndIf
		cQryMVPAR2 += "'" +  aConMVPAR2[nZ] 
		If nZ == LEN(aConMVPAR2)
			cQryMVPAR2 += " ') "
		else
			cQryMVPAR2 +=  "',"	
		Endif
	Next nZ   
	cQryMVPAR2 := 	"%"+cQryMVPAR2+"%"
EndIf

BEGIN REPORT QUERY oReport:Section(1)
    
BeginSql alias cAlias1
    SELECT DISTINCT TFJ_FILIAL,TFJ_CONTRT,TFJ_CODENT,TFJ_LOJA,A1_NOME
    FROM %table:TFJ% TFJ
	JOIN %table:SA1% SA1 
		ON A1_COD = TFJ_CODENT AND 
		A1_LOJA = TFJ_LOJA AND
		SA1.%NotDEL% AND
		%Exp:cFiSA1TFJ%
    JOIN %table:TFV% TFV 
		ON TFV_CONTRT = TFJ_CONTRT AND  
		%Exp:cFiTFVTFJ% AND
		TFV.%NotDEL%
	WHERE TFJ.%notDel%  AND
		TFJ_CONTRT %Exp:cQryMVPAR1% AND
		TFJ.%Notdel% AND
		TFJ_FILIAL %Exp:cQryMVPAR2% 
		ORDER BY TFJ_FILIAL,TFJ_CONTRT

EndSql
    
END REPORT QUERY oReport:Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1)
    
BeginSql alias cAlias2
    SELECT DISTINCT TFL_FILIAL,TFL_CODIGO,TFL_LOCAL,TFL_DTINI,TFL_DTFIM
    FROM %table:TFL% TFL
	    JOIN %Table:ABS% ABS
            ON ABS.ABS_LOCAL = TFL.TFL_LOCAL AND
			%Exp:cFiABSTFL% AND
            ABS.%NotDEL% 
		JOIN %table:TFV% TFV 
			ON TFV_CONTRT = TFL_CONTRT AND 
			%Exp:cFiTFVTFL%
			AND TFV.%NotDEL%
		WHERE TFL.%Notdel%	AND
			TFL_CONTRT  = %report_param: (cAlias1)->TFJ_CONTRT% AND
			TFL_FILIAL  %exp:cQryMVPAR2% 
    	ORDER BY TFL_FILIAL,TFL_CODIGO

EndSql

END REPORT QUERY oReport:Section(1):Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1)

BeginSql alias cAlias3
    SELECT  DISTINCT C5_NUM,CND_COMPET ,CND_VLTOT,TFV_DTINI,TFV_DTFIM
    FROM %table:SC5% SC5
		JOIN %Table:CND% CND
            ON CND_CONTRA = C5_MDCONTR AND 
			CND_NUMMED = C5_MDNUMED AND 
            CND.%NotDEL% AND
			%Exp:cFiCNDSC5%	
		JOIN %Table:TFV% TFV
            ON TFV_CONTRT  = C5_MDCONTR AND 
			C5_EMISSAO = TFV_DTAPUR AND
            TFV.%NotDEL% AND
			%Exp:cFiTFVSC5%	
		JOIN %Table:TFL% TFL
            ON TFL_CONTRT  = C5_MDCONTR AND 
			TFL_PLAN = C5_MDPLANI  AND
            TFL.%NotDEL% AND
			%Exp:cFiTFLSC5%	
		WHERE SC5.%Notdel%	AND
			C5_MDCONTR = %report_param: (cAlias1)->TFJ_CONTRT% AND
			C5_FILIAL  %exp:cQryMVPAR2%  AND
			TFL_LOCAL =  %report_param: (cAlias2)->TFL_LOCAL% AND
			TFV_DTINI >= %Exp:MV_PAR03% AND 
			TFV_DTFIM <= %Exp:MV_PAR04%
			ORDER BY C5_NUM,CND_COMPET

EndSql

END REPORT QUERY oReport:Section(1):Section(1):Section(1)

oReport:Section(1):Print()

Return

