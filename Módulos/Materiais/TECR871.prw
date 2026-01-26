#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TECR871.CH"

Static cChaveTFF	:= ""
Static aTFFVal		:= {}

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECR871()
Relatório de Reajuste Retroativo

@sample 	TECR871()
@return		oReport
@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECR871()
Local cPerg		:= "TECR871"
Local oReport	:= Nil

If TecHasPerg("MV_PAR01", cPerg)
	//Limpa a variavel statica
	cChaveTFF := ""
	aTFFVal		:= {}

	If TRepInUse()
		Pergunte(cPerg,.T.)
		oReport := Rt871RDef(cPerg)
		oReport:SetLandScape()
		oReport:PrintDialog()
	EndIf
Else
	Help(,, "TECR871",, STR0034, 1, 0) //"Não é possível utilizar o relatório, realize a inclusão do pergunte TECR871."
Endif

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt871RDef()
Monta as Sections para impressão do relatório

@sample Rt871RDef(cPerg)
@param 	cPerg 
@return oReport

@author 	Kaique Schiller
@since		25/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt871RDef(cPerg)
Local oReport		:= Nil				
Local oSection1 	:= Nil				
Local oSection2  	:= Nil				
Local oSection3 	:= Nil
Local oSection4 	:= Nil
Local oSection5 	:= Nil
Local oSection6 	:= Nil
Local oSection7 	:= Nil
Local oSection8 	:= Nil
Local cAliasTFJ		:= GetNextAlias()
Local cAliasTFF		:= GetNextAlias()
Local cAliasTFG		:= GetNextAlias()
Local cAliasTFH		:= GetNextAlias()
Local nJan			:= 0
Local nFev			:= 0
Local nMar			:= 0
Local nAbr			:= 0
Local nMai			:= 0
Local nJun			:= 0
Local nJul			:= 0
Local nAgo			:= 0
Local nSet			:= 0
Local nOut			:= 0
Local nNov			:= 0
Local nDez			:= 0

MV_PAR11 := SubStr(MV_PAR11, 1, 2)+"/"+SubStr(MV_PAR11, 3, 4)

oReport   := TReport():New("TECR871",STR0001,cPerg,{|oReport| Rt871Print(oReport, cPerg,cAliasTFJ,cAliasTFF,cAliasTFG,cAliasTFH)},STR0001) //"Reajuste Retroativo"

oSection1 := TRSection():New(oReport	,STR0002 ,{"TFJ"},,,,,,,,,,3,,,.T.) //"Orçamento"
DEFINE CELL NAME "TFJ_CONTRT"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CONREV"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CODIGO"	OF oSection1 ALIAS "TFJ"
DEFINE CELL NAME "TFJ_CODENT"	OF oSection1 ALIAS "TFJ" TITLE STR0003 //"Cod. Cliente"
DEFINE CELL NAME "TFJ_LOJA"		OF oSection1 ALIAS "TFJ" TITLE STR0004 //"Loja"
DEFINE CELL NAME "A1_NOME"      OF oSection1 ALIAS "SA1" TITLE STR0004 //"Cliente"

oSection2 := TRSection():New(oSection1	,STR0006,{"TFL","ABS"},,,,,,,,,,6,,,.T.) //"Locais"
DEFINE CELL NAME "TFL_LOCAL"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "ABS_DESCRI"   OF oSection2 ALIAS "ABS" TITLE STR0007 //"Local"
DEFINE CELL NAME "TFL_DTINI"	OF oSection2 ALIAS "TFL"
DEFINE CELL NAME "TFL_DTFIM"	OF oSection2 ALIAS "TFL"

oSection3 := TRSection():New(oSection2	,STR0035 ,{"TFF","TDW","SRJ","TGT"},,,,,,,,,,9,,,.T.) //"Postos"
DEFINE CELL NAME "TFF_COD"		OF oSection3 TITLE STR0008  ALIAS "TFF" //"Cod. Posto" 
DEFINE CELL NAME "TFF_PRODUT"	OF oSection3 ALIAS "TFF" SIZE (TamSX3("B1_COD")[1]) + 5
DEFINE CELL NAME "TFF_DESCPRD"	OF oSection3 TITLE STR0009 SIZE (TamSX3("B1_DESC")[1]) BLOCK {|| Posicione("SB1",1, xFilial("SB1")+(cAliasTFF)->(TFF_PRODUT),"SB1->B1_DESC") } //"Desc. Produto"		
DEFINE CELL NAME "TFF_ESCALA"	OF oSection3 ALIAS "TFF" SIZE (TamSX3("TFF_ESCALA")[1]) + 5
DEFINE CELL NAME "TFF_DESESC" 	OF oSection3 TITLE STR0010 SIZE (TamSX3("TDW_DESC")[1]) BLOCK {|| Posicione("TDW",1, xFilial("TDW")+PadR(Trim((cAliasTFF)->(TFF_ESCALA)), TamSx3("TDW_DESC")[1]),"TDW->TDW_DESC") } //"Desc. Escala"
DEFINE CELL NAME "TFF_FUNCAO"	OF oSection3 ALIAS "TFF"
DEFINE CELL NAME "TFF_DESFUN" 	OF oSection3 TITLE STR0011 SIZE (TamSX3("RJ_DESC")[1]) BLOCK {|| Posicione("SRJ",1, xFilial("SRJ")+PadR(Trim((cAliasTFF)->(TFF_FUNCAO)), TamSx3("RJ_DESC")[1]),"SRJ->RJ_DESC") } //"Desc. Função"
DEFINE CELL NAME "TFF_PERINI"	OF oSection3 ALIAS "TFF" TITLE STR0012 //"Inicio Posto"
DEFINE CELL NAME "TFF_PERFIM"	OF oSection3 ALIAS "TFF" TITLE STR0013 //"Final Posto"
DEFINE CELL NAME "TGT_COMPET"	OF oSection3 TITLE STR0014  BLOCK {|| MV_PAR11 } //"Competência" 
DEFINE CELL NAME "TGT_INDICE"	OF oSection3 TITLE STR0015 	BLOCK {|| TGTReajust((cAliasTFF)->(TFF_COD),MV_PAR11,"TGT_INDICE","TFF") } //"Indice"
DEFINE CELL NAME "TGT_VALOR"	OF oSection3 TITLE STR0016 	BLOCK {|| TGTReajust((cAliasTFF)->(TFF_COD),MV_PAR11,"TGT_VALOR","TFF") } //"Valor" 
DEFINE CELL NAME "TGT_DTINI"	OF oSection3 TITLE STR0017 	BLOCK {|| TGTReajust((cAliasTFF)->(TFF_COD),MV_PAR11,"TGT_DTINI","TFF") } //"Dia Inicio Reaj"
DEFINE CELL NAME "TGT_DTFIM"	OF oSection3 TITLE STR0018  BLOCK {|| TGTReajust((cAliasTFF)->(TFF_COD),MV_PAR11,"TGT_DTFIM","TFF") } //"Dia Final Reaj"

oSection4 := TRSection():New(oSection3	,STR0019 ,{"TFF","TGT"},,,,,,,,,,12,,,.T.) //"Meses do Reajuste Retroativo"
DEFINE CELL NAME "TGT_JAN"	OF oSection4 SIZE 15 TITLE STR0020 	BLOCK {|| Transform( nJan := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,1) , "@R 999,999,999.99" ) } //"Janeiro"
DEFINE CELL NAME "TGT_FEV"	OF oSection4 SIZE 15 TITLE STR0021 	BLOCK {|| Transform( nFev := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,2) , "@R 999,999,999.99" ) } //"Fevereiro"
DEFINE CELL NAME "TGT_MAR"	OF oSection4 SIZE 15 TITLE STR0022 	BLOCK {|| Transform( nMar := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,3) , "@R 999,999,999.99" ) } //"Março"
DEFINE CELL NAME "TGT_ABR"	OF oSection4 SIZE 15 TITLE STR0023 	BLOCK {|| Transform( nAbr := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,4) , "@R 999,999,999.99" ) } //"Abril"
DEFINE CELL NAME "TGT_MAI"	OF oSection4 SIZE 15 TITLE STR0024	BLOCK {|| Transform( nMai := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,5) , "@R 999,999,999.99" ) } //"Maio"
DEFINE CELL NAME "TGT_JUN"	OF oSection4 SIZE 15 TITLE STR0025 	BLOCK {|| Transform( nJun := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,6) , "@R 999,999,999.99" ) } //"Junho"
DEFINE CELL NAME "TGT_JUL"	OF oSection4 SIZE 15 TITLE STR0026 	BLOCK {|| Transform( nJul := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,7) , "@R 999,999,999.99" ) } //"Julho"
DEFINE CELL NAME "TGT_AGO"	OF oSection4 SIZE 15 TITLE STR0027 	BLOCK {|| Transform( nAgo := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,8) , "@R 999,999,999.99" ) } //"Agosto"
DEFINE CELL NAME "TGT_SET"	OF oSection4 SIZE 15 TITLE STR0028 	BLOCK {|| Transform( nSet := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,9) , "@R 999,999,999.99" ) } //"Setembro"
DEFINE CELL NAME "TGT_OUT"	OF oSection4 SIZE 15 TITLE STR0029 	BLOCK {|| Transform( nOut := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,10) , "@R 999,999,999.99" ) } //"Outubro"
DEFINE CELL NAME "TGT_NOV"	OF oSection4 SIZE 15 TITLE STR0030 	BLOCK {|| Transform( nNov := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,11) , "@R 999,999,999.99" ) } //"Novembro"
DEFINE CELL NAME "TGT_DEZ"	OF oSection4 SIZE 15 TITLE STR0031 	BLOCK {|| Transform( nDez := VlrReajust("TFF",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFF)->TFF_COD,MV_PAR11,(cAliasTFF)->TFF_PERINI,(cAliasTFF)->TFF_PERFIM,(cAliasTFF)->TFF_QTDVEN,(cAliasTFF)->TFF_PRCVEN,12) , "@R 999,999,999.99" ) } //"Dezembro"
DEFINE CELL NAME "TGT_TOT"	OF oSection4 SIZE 15 TITLE STR0032 	BLOCK {|| Transform( nJan+nFev+nMar+nAbr+nMai+nJun+nJul+nAgo+nSet+nOut+nNov+nDez, "@R 999,999,999.99" ) } //"Total"

oSection5 := TRSection():New(oSection3	,STR0036 ,{"TFF","TDW","SRJ","TGT","TFG"},,,,,,,,,,9,,,.T.) //"Material de Implantação"
DEFINE CELL NAME "TFG_COD"		OF oSection5 TITLE STR0008  ALIAS "TFG" //"Cod. Posto" 
DEFINE CELL NAME "TFG_PRODUT"	OF oSection5 ALIAS "TFG"
DEFINE CELL NAME "TFG_DESCPRD"	OF oSection5 TITLE STR0009 SIZE (TamSX3("B1_DESC")[1]) BLOCK {|| Posicione("SB1",1, xFilial("SB1")+(cAliasTFG)->(TFG_PRODUT),"SB1->B1_DESC") } //"Desc. Produto"		
DEFINE CELL NAME "TGT_COMPET"	OF oSection5 TITLE STR0014  BLOCK {|| MV_PAR11 } //"Competência" 
DEFINE CELL NAME "TGT_INDICE"	OF oSection5 TITLE STR0015 	BLOCK {|| TGTReajust((cAliasTFG)->(TFG_COD),MV_PAR11,"TGT_INDICE","TFG") } //"Indice"
DEFINE CELL NAME "TGT_VALOR"	OF oSection5 TITLE STR0016 	BLOCK {|| TGTReajust((cAliasTFG)->(TFG_COD),MV_PAR11,"TGT_VALOR","TFG") } //"Valor" 
DEFINE CELL NAME "TGT_DTINI"	OF oSection5 TITLE STR0017 	BLOCK {|| TGTReajust((cAliasTFG)->(TFG_COD),MV_PAR11,"TGT_DTINI","TFG") } //"Dia Inicio Reaj"
DEFINE CELL NAME "TGT_DTFIM"	OF oSection5 TITLE STR0018  BLOCK {|| TGTReajust((cAliasTFG)->(TFG_COD),MV_PAR11,"TGT_DTFIM","TFG") } //"Dia Final Reaj"

oSection6 := TRSection():New(oSection5	,STR0019 ,{"TGT","TFG"},,,,,,,,,,12,,,.T.) //"Meses do Reajuste Retroativo"
DEFINE CELL NAME "TGT_JAN"	OF oSection6 SIZE 15 TITLE STR0020 	BLOCK {|| Transform( nJan := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,1) , "@R 999,999,999.99" ) } //"Janeiro"
DEFINE CELL NAME "TGT_FEV"	OF oSection6 SIZE 15 TITLE STR0021 	BLOCK {|| Transform( nFev := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,2) , "@R 999,999,999.99" ) } //"Fevereiro"
DEFINE CELL NAME "TGT_MAR"	OF oSection6 SIZE 15 TITLE STR0022 	BLOCK {|| Transform( nMar := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,3) , "@R 999,999,999.99" ) } //"Março"
DEFINE CELL NAME "TGT_ABR"	OF oSection6 SIZE 15 TITLE STR0023 	BLOCK {|| Transform( nAbr := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,4) , "@R 999,999,999.99" ) } //"Abril"
DEFINE CELL NAME "TGT_MAI"	OF oSection6 SIZE 15 TITLE STR0024	BLOCK {|| Transform( nMai := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,5) , "@R 999,999,999.99" ) } //"Maio"
DEFINE CELL NAME "TGT_JUN"	OF oSection6 SIZE 15 TITLE STR0025 	BLOCK {|| Transform( nJun := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,6) , "@R 999,999,999.99" ) } //"Junho"
DEFINE CELL NAME "TGT_JUL"	OF oSection6 SIZE 15 TITLE STR0026 	BLOCK {|| Transform( nJul := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,7) , "@R 999,999,999.99" ) } //"Julho"
DEFINE CELL NAME "TGT_AGO"	OF oSection6 SIZE 15 TITLE STR0027 	BLOCK {|| Transform( nAgo := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,8) , "@R 999,999,999.99" ) } //"Agosto"
DEFINE CELL NAME "TGT_SET"	OF oSection6 SIZE 15 TITLE STR0028 	BLOCK {|| Transform( nSet := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,9) , "@R 999,999,999.99" ) } //"Setembro"
DEFINE CELL NAME "TGT_OUT"	OF oSection6 SIZE 15 TITLE STR0029 	BLOCK {|| Transform( nOut := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,10) , "@R 999,999,999.99" ) } //"Outubro"
DEFINE CELL NAME "TGT_NOV"	OF oSection6 SIZE 15 TITLE STR0030 	BLOCK {|| Transform( nNov := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,11) , "@R 999,999,999.99" ) } //"Novembro"
DEFINE CELL NAME "TGT_DEZ"	OF oSection6 SIZE 15 TITLE STR0031 	BLOCK {|| Transform( nDez := VlrReajust("TFG",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFG)->TFG_COD,MV_PAR11,(cAliasTFG)->TFG_PERINI,(cAliasTFG)->TFG_PERFIM,(cAliasTFG)->TFG_QTDVEN,(cAliasTFG)->TFG_PRCVEN,12) , "@R 999,999,999.99" ) } //"Dezembro"
DEFINE CELL NAME "TGT_TOT"	OF oSection6 SIZE 15 TITLE STR0032 	BLOCK {|| Transform( nJan+nFev+nMar+nAbr+nMai+nJun+nJul+nAgo+nSet+nOut+nNov+nDez, "@R 999,999,999.99" ) } //"Total"


oSection7 := TRSection():New(oSection3	,STR0037 ,{"TFF","TDW","SRJ","TGT","TFH"},,,,,,,,,,9,,,.T.) //"Material de Implantação"
DEFINE CELL NAME "TFH_COD"		OF oSection7 TITLE STR0008  ALIAS "TFH" //"Cod. Posto" 
DEFINE CELL NAME "TFH_PRODUT"	OF oSection7 ALIAS "TFH"
DEFINE CELL NAME "TFH_DESCPRD"	OF oSection7 TITLE STR0009 SIZE (TamSX3("B1_DESC")[1]) BLOCK {|| Posicione("SB1",1, xFilial("SB1")+(cAliasTFH)->(TFH_PRODUT),"SB1->B1_DESC") } //"Desc. Produto"		
DEFINE CELL NAME "TGT_COMPET"	OF oSection7 TITLE STR0014  BLOCK {|| MV_PAR11 } //"Competência" 
DEFINE CELL NAME "TGT_INDICE"	OF oSection7 TITLE STR0015 	BLOCK {|| TGTReajust((cAliasTFH)->(TFH_COD),MV_PAR11,"TGT_INDICE","TFH") } //"Indice"
DEFINE CELL NAME "TGT_VALOR"	OF oSection7 TITLE STR0016 	BLOCK {|| TGTReajust((cAliasTFH)->(TFH_COD),MV_PAR11,"TGT_VALOR","TFH") } //"Valor" 
DEFINE CELL NAME "TGT_DTINI"	OF oSection7 TITLE STR0017 	BLOCK {|| TGTReajust((cAliasTFH)->(TFH_COD),MV_PAR11,"TGT_DTINI","TFH") } //"Dia Inicio Reaj"
DEFINE CELL NAME "TGT_DTFIM"	OF oSection7 TITLE STR0018  BLOCK {|| TGTReajust((cAliasTFH)->(TFH_COD),MV_PAR11,"TGT_DTFIM","TFH") } //"Dia Final Reaj"

oSection8 := TRSection():New(oSection7	,STR0019 ,{"TGT","TFH"},,,,,,,,,,12,,,.T.) //"Meses do Reajuste Retroativo"
DEFINE CELL NAME "TGT_JAN"	OF oSection8 SIZE 15 TITLE STR0020 	BLOCK {|| Transform( nJan := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,1) , "@R 999,999,999.99" ) } //"Janeiro"
DEFINE CELL NAME "TGT_FEV"	OF oSection8 SIZE 15 TITLE STR0021 	BLOCK {|| Transform( nFev := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,2) , "@R 999,999,999.99" ) } //"Fevereiro"
DEFINE CELL NAME "TGT_MAR"	OF oSection8 SIZE 15 TITLE STR0022 	BLOCK {|| Transform( nMar := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,3) , "@R 999,999,999.99" ) } //"Março"
DEFINE CELL NAME "TGT_ABR"	OF oSection8 SIZE 15 TITLE STR0023 	BLOCK {|| Transform( nAbr := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,4) , "@R 999,999,999.99" ) } //"Abril"
DEFINE CELL NAME "TGT_MAI"	OF oSection8 SIZE 15 TITLE STR0024	BLOCK {|| Transform( nMai := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,5) , "@R 999,999,999.99" ) } //"Maio"
DEFINE CELL NAME "TGT_JUN"	OF oSection8 SIZE 15 TITLE STR0025 	BLOCK {|| Transform( nJun := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,6) , "@R 999,999,999.99" ) } //"Junho"
DEFINE CELL NAME "TGT_JUL"	OF oSection8 SIZE 15 TITLE STR0026 	BLOCK {|| Transform( nJul := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,7) , "@R 999,999,999.99" ) } //"Julho"
DEFINE CELL NAME "TGT_AGO"	OF oSection8 SIZE 15 TITLE STR0027 	BLOCK {|| Transform( nAgo := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,8) , "@R 999,999,999.99" ) } //"Agosto"
DEFINE CELL NAME "TGT_SET"	OF oSection8 SIZE 15 TITLE STR0028 	BLOCK {|| Transform( nSet := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,9) , "@R 999,999,999.99" ) } //"Setembro"
DEFINE CELL NAME "TGT_OUT"	OF oSection8 SIZE 15 TITLE STR0029 	BLOCK {|| Transform( nOut := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,10) , "@R 999,999,999.99" ) } //"Outubro"
DEFINE CELL NAME "TGT_NOV"	OF oSection8 SIZE 15 TITLE STR0030 	BLOCK {|| Transform( nNov := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,11) , "@R 999,999,999.99" ) } //"Novembro"
DEFINE CELL NAME "TGT_DEZ"	OF oSection8 SIZE 15 TITLE STR0031 	BLOCK {|| Transform( nDez := VlrReajust("TFH",(cAliasTFJ)->TFJ_CODIGO,(cAliasTFJ)->TFJ_CONTRT,(cAliasTFJ)->TFJ_CONREV,(cAliasTFF)->TFF_ENCE,(cAliasTFF)->TFF_DTENCE,(cAliasTFH)->TFH_COD,MV_PAR11,(cAliasTFH)->TFH_PERINI,(cAliasTFH)->TFH_PERFIM,(cAliasTFH)->TFH_QTDVEN,(cAliasTFH)->TFH_PRCVEN,12) , "@R 999,999,999.99" ) } //"Dezembro"
DEFINE CELL NAME "TGT_TOT"	OF oSection8 SIZE 15 TITLE STR0032 	BLOCK {|| Transform( nJan+nFev+nMar+nAbr+nMai+nJun+nJul+nAgo+nSet+nOut+nNov+nDez, "@R 999,999,999.99" ) } //"Total"


Return oReport

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Rt871Print()
Monta a Query e imprime o relatorio de acordo com os parametros

@sample 	Rt871Print(oReport, cPerg, cAlias1)
@param		oReport, 	Object,	Objeto do relatório de postos vagos
			cPerg, 		String,	Nome do grupo de perguntas
			cAlias1,	String,	Nome do alias da Query do relatório 
			
@return 	Nenhum
@author 	Kaique Schiller
@since		27/04/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function Rt871Print(oReport, cPerg,cAliasTFJ,cAliasTFF,cAliasTFG,cAliasTFH)
Local oSection1	:= oReport:Section(1)		
Local oSection2	:= oSection1:Section(1) 	
Local oSection3	:= oSection2:Section(1) 	
Local oSection4	:= oSection3:Section(1)
Local oSection5	:= oSection3:Section(2)
Local oSection6	:= oSection5:Section(1)
Local oSection7	:= oSection3:Section(3)
Local oSection8	:= oSection7:Section(1)
Local cAlias2 := GetNextAlias()
Local cAlias3 := GetNextAlias()
Local cAlias4 := GetNextAlias()

BEGIN REPORT QUERY oSection1
    
BeginSql alias cAliasTFJ
    SELECT TFJ_CONTRT, TFJ_CONREV, TFJ_CODENT, TFJ_LOJA, TFJ_CODIGO, TFJ_FILIAL,A1_NOME
    FROM %table:TFJ% TFJ
	LEFT JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND 
		SA1.%NotDel% AND SA1.A1_COD = TFJ.TFJ_CODENT AND SA1.A1_LOJA = TFJ.TFJ_LOJA
	WHERE TFJ.TFJ_FILIAL=%xFilial:TFJ%
		AND TFJ.TFJ_CONTRT <> ''
		AND TFJ.TFJ_STATUS = '1'
		AND TFJ.%NotDel%
        AND TFJ.TFJ_CONTRT 	BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
    ORDER BY TFJ_FILIAL,TFJ_CODIGO
EndSql
    
END REPORT QUERY oSection1

BEGIN REPORT QUERY oSection2
    
BeginSql alias cAlias2
    SELECT TFL_FILIAL,TFL_CODIGO,TFL_LOCAL,TFL_DTINI,TFL_DTFIM,TFL_TOTRH,TFL_TOTMI,TFL_TOTMC,TFL_CODPAI,
	ABS_DESCRI
    FROM %table:TFL% TFL
	INNER JOIN %table:ABS% ABS ON (ABS.ABS_FILIAL = %xFilial:ABS% AND ABS.ABS_LOCAL  = TFL.TFL_LOCAL AND ABS.%NotDel%)
    WHERE TFL_FILIAL   = %report_param: (cAliasTFJ)->TFJ_FILIAL% 
        AND TFL_CODPAI = %report_param: (cAliasTFJ)->TFJ_CODIGO%                         
        AND TFL.%notDel% 
        AND TFL.TFL_LOCAL 	BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND ABS.ABS_CODIGO 	BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%
        AND ABS.ABS_LOJA 	BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%
    ORDER BY TFL_FILIAL,TFL_CODIGO
EndSql
    
END REPORT QUERY oSection2

BEGIN REPORT QUERY oSection3

BeginSql alias cAliasTFF
    SELECT TFF_FILIAL,TFF_COD,TFF_ITEM,TFF_PRODUT,TFF_QTDVEN,TFF_PRCVEN,TFF_PERINI,TFF_PERFIM,
	TFF_ESCALA,TFF_FUNCAO,TFF_CODPAI,TFF_CONTRT, TFF_CONREV, TFF_ENCE, TFF_DTENCE
    FROM %table:TFF% TFF
    WHERE TFF_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL% 
        AND TFF_CODPAI = %report_param: (cAlias2)->TFL_CODIGO%
		AND TFF.TFF_COD  BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
        AND TFF.%notDel% 
		AND EXISTS (SELECT 1 
					FROM %table:TGT% TGT 
					WHERE TGT.TGT_FILIAL = %xFilial:TGT% 
						AND TGT.TGT_TPITEM = "TFF" 
						AND TGT.TGT_CDITEM = TFF.TFF_COD 
						AND TGT.TGT_EXCEDT = '1'
						AND TGT.TGT_COMPET = %Exp:MV_PAR11%
						AND TGT.%NotDel%)

	ORDER BY TFF_COD
EndSql
    
END REPORT QUERY oSection3

BEGIN REPORT QUERY oSection4

BeginSql alias cAlias3
	COLUMN TGT_DTINI AS DATE 
	COLUMN TGT_DTFIM AS DATE 

	SELECT TGT_INDICE,
		   TGT_VALOR,
		   TGT_DTINI,
		   TGT_DTFIM
		FROM %Table:TGT% TGT
		WHERE TGT.TGT_FILIAL = %xFilial:TGT%
			AND TGT.TGT_TPITEM = "TFF"
			AND TGT.TGT_CDITEM = %report_param: (cAliasTFF)->TFF_COD%
			AND TGT.TGT_EXCEDT = '1'
			AND TGT.TGT_COMPET = %Exp:MV_PAR11%
			AND TGT.%NotDel%
	EndSql
    
END REPORT QUERY oSection4

BEGIN REPORT QUERY oSection5

BeginSql alias cAliasTFG
    SELECT TFG_FILIAL,TFG_COD,TFG_ITEM,TFG_PRODUT,TFG_QTDVEN,TFG_PRCVEN,TFG_PERINI,TFG_PERFIM,
	TFG_CODPAI,TFG_CONTRT, TFG_CONREV
    FROM %table:TFG% TFG
    WHERE TFG_FILIAL   = %xFilial:TFG% 
        AND TFG_CODPAI = %report_param: (cAliasTFF)->TFF_COD%
        AND TFG.%notDel% 
		AND EXISTS (SELECT 1 
					FROM %table:TGT% TGT 
					WHERE TGT.TGT_FILIAL = %xFilial:TGT% 
						AND TGT.TGT_TPITEM = "TFG" 
						AND TGT.TGT_CDITEM = TFG.TFG_COD 
						AND TGT.TGT_EXCEDT = '1'
						AND TGT.TGT_COMPET = %Exp:MV_PAR11%
						AND TGT.%NotDel%)

	ORDER BY TFG_COD
EndSql
    
END REPORT QUERY oSection5

BEGIN REPORT QUERY oSection6

BeginSql alias cAlias3
	COLUMN TGT_DTINI AS DATE 
	COLUMN TGT_DTFIM AS DATE 

	SELECT TGT_INDICE,
		   TGT_VALOR,
		   TGT_DTINI,
		   TGT_DTFIM
		FROM %Table:TGT% TGT
		WHERE TGT.TGT_FILIAL = %xFilial:TGT%
			AND TGT.TGT_TPITEM = "TFG"
			AND TGT.TGT_CDITEM = %report_param: (cAliasTFG)->TFG_COD%
			AND TGT.TGT_EXCEDT = '1'
			AND TGT.TGT_COMPET = %Exp:MV_PAR11%
			AND TGT.%NotDel%
	EndSql
    
END REPORT QUERY oSection6

BEGIN REPORT QUERY oSection7

BeginSql alias cAliasTFH
    SELECT TFH_FILIAL,TFH_COD,TFH_ITEM,TFH_PRODUT,TFH_QTDVEN,TFH_PRCVEN,TFH_PERINI,TFH_PERFIM,
	TFH_CODPAI,TFH_CONTRT, TFH_CONREV
    FROM %table:TFH% TFH
    WHERE TFH_FILIAL   = %xFilial:TFH% 
        AND TFH_CODPAI = %report_param: (cAliasTFF)->TFF_COD%
        AND TFH.%notDel% 
		AND EXISTS (SELECT 1 
					FROM %table:TGT% TGT 
					WHERE TGT.TGT_FILIAL = %xFilial:TGT% 
						AND TGT.TGT_TPITEM = "TFH" 
						AND TGT.TGT_CDITEM = TFH.TFH_COD 
						AND TGT.TGT_EXCEDT = '1'
						AND TGT.TGT_COMPET = %Exp:MV_PAR11%
						AND TGT.%NotDel%)

	ORDER BY TFH_COD
EndSql
    
END REPORT QUERY oSection7

BEGIN REPORT QUERY oSection8

BeginSql alias cAlias4
	COLUMN TGT_DTINI AS DATE 
	COLUMN TGT_DTFIM AS DATE 

	SELECT TGT_INDICE,
		   TGT_VALOR,
		   TGT_DTINI,
		   TGT_DTFIM
		FROM %Table:TGT% TGT
		WHERE TGT.TGT_FILIAL = %xFilial:TGT%
			AND TGT.TGT_TPITEM = "TFH"
			AND TGT.TGT_CDITEM = %report_param: (cAliasTFH)->TFH_COD%
			AND TGT.TGT_EXCEDT = '1'
			AND TGT.TGT_COMPET = %Exp:MV_PAR11%
			AND TGT.%NotDel%
	EndSql
    
END REPORT QUERY oSection8

oSection1:Print()

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VlrReajust
(long_description) Valor do Reajuste da tabela TGT
@author Kaique Schiller
@since 25/05/2022
@return nValRet, Numerico, Valor reajustado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function VlrReajust(cTabela,cCodOrc,cContr,cRevAtu,cEncerr,dDtEncerr,cCodTFF,cCompet,dDtIniTFF,dDtFimTFF,nQtdVend,nPrcVen,nMes)
Local nValRet 		:= 0
Local aTFFAtu  		:= {}
Local aMesVlr  		:= {}
Local lGetDtTFF		:= ExistBlock("GetDtTFF")
Local lValRetMes	:= ExistBlock("ValRetMes")

Default cCodOrc := "" 
Default cContr := ""
Default cRevAtu := "" 
Default cEncerr := ""
Default dDtEncerr := sTod("")
Default cCodTFF := ""
Default cCompet := ""
Default dDtIniTFF := sTod("")
Default dDtFimTFF := sTod("") 
Default nQtdVend := 0 
Default nPrcVen := 0
Default nMes	:= 0

DbSelectArea("TGT")
TGT->(DbSetOrder(2)) //TGT_FILIAL+TGT_TPITEM+TGT_CDITEM+TGT_COMPET
If TGT->(DbSeek(xFilial("TGT")+cTabela+cCodTFF+cCompet)) 
	While TGT->(!EOF()) .And. xFilial("TGT") == TGT->TGT_FILIAL .And.;
										TGT->TGT_CODTFJ = cCodOrc.And.;
										TGT->TGT_TPITEM == cTabela .And.;
										TGT->TGT_CDITEM == cCodTFF .And.;
										TGT->TGT_COMPET == cCompet
		If TGT->TGT_EXCEDT == "1"
			aTFFAtu := {}
			aAdd(aTFFAtu,{cTabela+'_COD'	,cCodTFF})
			aAdd(aTFFAtu,{cTabela+'_QTDVEN'	,nQtdVend})
			aAdd(aTFFAtu,{cTabela+'_PRCVEN'	,nPrcVen})
			If dDtIniTFF <= TGT->TGT_DTINI
				aAdd(aTFFAtu,{cTabela+'_PERINI',TGT->TGT_DTINI})
			Else 
				aAdd(aTFFAtu,{cTabela+'_PERINI',dDtIniTFF})
			EndIf
			If dDtFimTFF >= TGT->TGT_DTFIM
				aAdd(aTFFAtu,{cTabela+'_PERFIM',TGT->TGT_DTFIM})
			Else 
				aAdd(aTFFAtu,{cTabela+'_PERFIM',dDtFimTFF})
			EndIf
			If lGetDtTFF .And. lValRetMes
				If cChaveTFF <> xFilial(cTabela) + cCodTFF + cTabela
					cChaveTFF :=  xFilial(cTabela) + cCodTFF + cTabela
				    aTFFVal := Execblock("GetDtTFF",.f.,.f.,{cTabela,1,xFilial(cTabela) + cCodTFF,cContr,TGT->TGT_DTINI,TGT->TGT_DTFIM,cEncerr = '1',dDtEncerr})
				EndIf 
				If !Empty(aTFFVal)
					aMesVlr := Execblock("ValRetMes",.f.,.f.,{aTFFVal,nMes,TGT->TGT_INDICE,TGT->TGT_VALREA})
					If !Empty(aMesVlr)
						nValRet := aMesVlr[1,2]
						Exit
					Endif
				Endif
			EndIf	
		Endif
		TGT->(DbSkip())
	EndDo
Endif

Return nValRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Atr87VlCmp
(long_description) Validação da competência do pergunte TECR871
@type  Function 
@author Kaique Schiller
@since 25/05/2022
@return lRet, Logico, Retorno validação da competência do pergunte TECR871
/*/
//--------------------------------------------------------------------------------------------------------------------
Function Atr87VlCmp(cCompet)
Local lRet := .T.

If Empty(Strtran(cCompet,"/"))
	Help(,, "Atr87VlCmp",, STR0033, 1, 0) //"A competência não está preenchida."
	lRet := .F.
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TGTReajust
(long_description) Query para selecionar as informações da TGT
@type  Function 
@author Kaique Schiller
@since 25/05/2022
@return cRet, Caracter, Retorno do campo da query
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TGTReajust(cCodTFF,cCompet,cCampo,cTabela)
Local cCampRet := ""
Local cAliasTGT := ""

If !Empty(cCodTFF)
	cAliasTGT := GetNextAlias()
	BeginSql Alias cAliasTGT
	
	COLUMN TGT_DTINI AS DATE 
	COLUMN TGT_DTFIM AS DATE 

	SELECT TGT_INDICE,
		   TGT_VALOR,
		   TGT_DTINI,
		   TGT_DTFIM
		FROM %Table:TGT% TGT
		WHERE TGT.TGT_FILIAL = %xFilial:TGT%
			AND TGT.TGT_TPITEM = %Exp:cTabela%
			AND TGT.TGT_CDITEM = %Exp:cCodTFF%
			AND TGT.TGT_COMPET = %Exp:cCompet%
			AND TGT.TGT_EXCEDT = '1'
			AND TGT.%NotDel%
	EndSql

	If (cAliasTGT)->(!Eof())
		cCampRet := (cAliasTGT)->&(cCampo)
	Endif

	(cAliasTGT)->(DbCloseArea())
Endif

Return cCampRet
