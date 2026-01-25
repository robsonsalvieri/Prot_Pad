#INCLUDE "PROTHEUS.CH"
#include "REPORT.CH" 
#include "FISR181.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISR181

Relatorio de conferencia Apuração do Estorno do ICMS de produtos que possuem
Estrutura na SG1 e utilizam o operando VLR_ICMS_ULT_AQUI_ESTRUTURA e para
Produtos de Revenda que utilizam o operando QUANTIDADE_ULT_AQUI, ICMS_ULT_AQUI
BASE_ICMS_ULT_AQUI E ALQ_ICMS_ULT_AQUI

@return	Nil

@author Alexandre Esteves
@since 01/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR181()
Local oReport 
					
If Pergunte("FISR181",.T.)
		oReport:= ReportDef(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09,mv_par10,mv_par11)
		oReport:PrintDialog() 
Endif	

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Alexandre Esteves
@since 01/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(dDataDe, dDataAte ,cDocIni , cSerIni , cDocFim , cSerFim , lFilial , nOpcao , nOrdem , cProdDe , cProdAte)

Local	oSection 	
Local   oSection1   
Local   oBreak 		
Local	cQuery	:= ""	
Local 	cTitRel	:= ""	
Private lAutomato  := .F.  


Default cDocIni := ""
Default cDocFim := "999999999"
Default cSerini := ""
Default cSerFim := "ZZZ"
Default lFilial  := .F.
Default nOrdem  :=  1

cQuery := GetNextAlias()
cTitRel	:= STR0002 // "Relatorio de Conferência Estorno de Credito ICMS"
lAutomato := Iif(IsBlind(),.T.,.F.)

IF lAutomato
    dDatade  := MV_PAR01
	dDataAte := MV_PAR02  
    cDocIni  := MV_PAR03
    cSerIni  := MV_PAR04
    cDocFim  := MV_PAR05
    cSerFim  := MV_PAR06
	lFilial  := mv_par07
	nOpcao   := mv_par08
	nOrdem   := mv_par09
	cProdDe  := mv_par10
	cProdAte := mv_par11
EndIF

oReport:=TReport():New("Relatório Estorno de Crédito",cTitRel,"Relatório Estorno de Crédito",{|oReport| ReportPrint(oReport,cQuery,dDataDe, dDataAte ,cDocIni,cSerIni,cDocFim,cSerfim,lFilial,nOpcao,nOrdem,cProdDe,cProdAte)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
oReport:lHeaderVisible := .T.

oSection := TRSection():New(oReport,cTitRel,{cQuery,"CJM","SA1","SA2","SB1"},,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:SetLinesBefore(2)



If nOrdem == 1 
	TRCell():New(oSection,"CJM_FILIAL"	,cQuery,STR0003,/*cPicture*/,TamSx3("CJM_FILIAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Filial"
	TRCell():New(oSection,"CJM_PERIOD"	,cQuery,STR0004,/*cPicture*/,TamSx3("CJM_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Ano/Mês"
	TRCell():New(oSection,"CJM_DOCSAI"	,cQuery,STR0015,/*cPicture*/,TamSx3("CJM_DOCSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"NF de Saída"
	TRCell():New(oSection,"CJM_SERSAI"	,cQuery,STR0016,/*cPicture*/,TamSx3("CJM_SERSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie Saída"
	TRCell():New(oSection,"CJM_DTSAI"	,cQuery,STR0030,/*cPicture*/,TamSx3("CJM_DTSAI" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Dt Emissao Saída"
	TRCell():New(oSection,"CJM_CLIFOR"	,cQuery,STR0017,/*cPicture*/,TamSx3("CJM_CLIFOR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Cliente"
	TRCell():New(oSection,"CJM_LOJA"	,cQuery,STR0018,/*cPicture*/,TamSx3("CJM_LOJA"  )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Loja"
	TRCell():New(oSection,"CJM_PRDFIM"	,cQuery,STR0019,/*cPicture*/,TamSx3("CJM_PRDFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prod Saída"
	TRCell():New(oSection,"B1_DESC"	    ,cQuery,STR0031,/*cPicture*/,TamSx3("B1_DESC"   )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Descrição do Produto"
	TRCell():New(oSection,"CJM_ITEFIM"	,cQuery,STR0020,/*cPicture*/,TamSx3("CJM_ITEFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Item NF Saída"
	TRCell():New(oSection,"CJM_QTDSAI"	,cQuery,STR0021,/*cPicture*/,TamSx3("CJM_QTDSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtd Nf Saída"
	TRCell():New(oSection,"CDA_CODLAN"	,cQuery,STR0028,/*cPicture*/,TamSx3("CDA_CODLAN")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Lançamento"
		
		
	oSection1 := TRSection():New(oSection,"Detalhe dos Produtos",{cQuery,"CJM","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:nLeftMargin := oSection:nLeftMargin + 5
	oSection1:SetLinesBefore(0)
		
	TRCell():New(oSection1,"CJM_DOCORI"	,cQuery,STR0005,/*cPicture*/,TamSx3("CJM_DOCORI")[1], /*lPixel*/,/*{||code-block de impressao }*/)  //"Nf Ult Ent"
	TRCell():New(oSection1,"CJM_SERORI"	,cQuery,STR0006,/*cPicture*/,TamSx3("CJM_SERORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie Ult Ent"
	TRCell():New(oSection1,"CJM_FORNEC"	,cQuery,STR0007,/*cPicture*/,TamSx3("CJM_FORNEC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Forne Ult Ent"
	TRCell():New(oSection1,"CJM_LOJAEN"	,cQuery,STR0008,/*cPicture*/,TamSx3("CJM_LOJAEN")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Loja Forne Ult Ent"
	If nOpcao <> 	2
		TRCell():New(oSection1,"CJM_PRDORI"	,cQuery,STR0009,/*cPicture*/,TamSx3("CJM_PRDORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prod Ult Ent"
	Endif
	TRCell():New(oSection1,"CJM_DTORIG"	,cQuery,STR0010,/*cPicture*/,TamSx3("CJM_DTORIG")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Dt Entrada Ult Ent"
	TRCell():New(oSection1,"CJM_LOTORI"	,cQuery,STR0011,/*cPicture*/,TamSx3("CJM_LOTORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Lote Ult Ent"
	TRCell():New(oSection1,"CJM_UM"	    ,cQuery,STR0012,/*cPicture*/,TamSx3("CJM_UM"    )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Unid Medida"

	//Melhoria Futura para Segunda unidade de Medida
	//TRCell():New(oSection1,"CJM_SEGUM"	,cQuery,STR0013,/*cPicture*/,TamSx3("CJM_SEGUM" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Seg UM"
	//TRCell():New(oSection1,"CJM_QTSEGU"	,cQuery,STR0014,/*cPicture*/,TamSx3("CJM_QTSEGU")[1],/*lPixel*/,/*{||code-block de impressao }*/)   //"Qtd Seg UM"

	TRCell():New(oSection1,"CJM_ICMUNT"	,cQuery,STR0022,/*cPicture*/,TamSx3("CJM_ICMUNT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Unitario"

	If nOpcao <> 2
		TRCell():New(oSection1,"CJM_QTESTR"	,cQuery,STR0023,/*cPicture*/,TamSx3("CJM_QTESTR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtd Estorno"
		TRCell():New(oSection1,"CJM_PRDINT"	,cQuery,STR0024,/*cPicture*/,TamSx3("CJM_PRDINT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prd Intermediario"
		TRCell():New(oSection1,"CJM_PRCOMP"	,cQuery,STR0025,/*cPicture*/,TamSx3("CJM_PRCOMP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Componente" 
	Endif 
	TRCell():New(oSection1,"CJM_ICMEST"	,cQuery,STR0026,/*cPicture*/,TamSx3("CJM_ICMEST")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Estorno"


	oBreak := TRBreak():New(oSection1,{|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA+CJM_ITEFIM+CJM_PRDFIM)  },/*TEXTO*/,.F.,/*TEXTO*/,.T.) // Quebra inicial por NF
	TRFunction():New(oSection1:Cell("CJM_ICMEST") ,  ,"SUM", oBreak, STR0027 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor total do Estorno"

Elseif nOrdem == 2
	TRCell():New(oSection,"CJM_PRDFIM"	,cQuery,STR0019,/*cPicture*/,TamSx3("CJM_PRDFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prod Saída"
	TRCell():New(oSection,"B1_DESC"	    ,cQuery,STR0031,/*cPicture*/,TamSx3("B1_DESC"   )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Descrição do Produto"

	oSection1 := TRSection():New(oSection,"Detalhe dos Produtos",{cQuery,"CJM","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:nLeftMargin := oSection:nLeftMargin + 5
	oSection1:SetLinesBefore(0)

	TRCell():New(oSection1,"CJM_FILIAL"	,cQuery,STR0003,/*cPicture*/,TamSx3("CJM_FILIAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Filial"
	TRCell():New(oSection1,"CJM_PERIOD"	,cQuery,STR0004,/*cPicture*/,TamSx3("CJM_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Ano/Mês"
	TRCell():New(oSection1,"CJM_DOCSAI"	,cQuery,STR0015,/*cPicture*/,TamSx3("CJM_DOCSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"NF de Saída"
	TRCell():New(oSection1,"CJM_SERSAI"	,cQuery,STR0016,/*cPicture*/,TamSx3("CJM_SERSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie Saída"
	TRCell():New(oSection1,"CJM_DTSAI"	,cQuery,STR0030,/*cPicture*/,TamSx3("CJM_DTSAI" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Dt Emissao Saída"
	TRCell():New(oSection1,"CJM_CLIFOR"	,cQuery,STR0017,/*cPicture*/,TamSx3("CJM_CLIFOR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Cliente"
	TRCell():New(oSection1,"CJM_LOJA"	,cQuery,STR0018,/*cPicture*/,TamSx3("CJM_LOJA"  )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Loja"
	TRCell():New(oSection1,"CJM_PRDFIM"	,cQuery,STR0019,/*cPicture*/,TamSx3("CJM_PRDFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prod Saída"
	TRCell():New(oSection1,"CJM_ITEFIM"	,cQuery,STR0020,/*cPicture*/,TamSx3("CJM_ITEFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Item NF Saída"
	TRCell():New(oSection1,"CJM_QTDSAI"	,cQuery,STR0021,/*cPicture*/,TamSx3("CJM_QTDSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtd Nf Saída"
	TRCell():New(oSection1,"CDA_CODLAN"	,cQuery,STR0028,/*cPicture*/,TamSx3("CDA_CODLAN")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Lançamento"
	TRCell():New(oSection1,"CJM_DOCORI"	,cQuery,STR0005,/*cPicture*/,TamSx3("CJM_DOCORI")[1], /*lPixel*/,/*{||code-block de impressao }*/)  //"Nf Ult Ent"
	TRCell():New(oSection1,"CJM_SERORI"	,cQuery,STR0006,/*cPicture*/,TamSx3("CJM_SERORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie Ult Ent"
	TRCell():New(oSection1,"CJM_FORNEC"	,cQuery,STR0007,/*cPicture*/,TamSx3("CJM_FORNEC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Forne Ult Ent"
	TRCell():New(oSection1,"CJM_LOJAEN"	,cQuery,STR0008,/*cPicture*/,TamSx3("CJM_LOJAEN")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Loja Forne Ult Ent"
	TRCell():New(oSection1,"CJM_DTORIG"	,cQuery,STR0010,/*cPicture*/,TamSx3("CJM_DTORIG")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Dt Entrada Ult Ent"
	TRCell():New(oSection1,"CJM_LOTORI"	,cQuery,STR0011,/*cPicture*/,TamSx3("CJM_LOTORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Lote Ult Ent"
	TRCell():New(oSection1,"CJM_UM"	    ,cQuery,STR0012,/*cPicture*/,TamSx3("CJM_UM"    )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Unid Medida"
	If nOpcao <> 2
		TRCell():New(oSection1,"CJM_QTESTR"	,cQuery,STR0023,/*cPicture*/,TamSx3("CJM_QTESTR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtd Estorno"
		TRCell():New(oSection1,"CJM_PRDINT"	,cQuery,STR0024,/*cPicture*/,TamSx3("CJM_PRDINT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prd Intermediario"
		TRCell():New(oSection1,"CJM_PRCOMP"	,cQuery,STR0025,/*cPicture*/,TamSx3("CJM_PRCOMP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Componente" 
	Endif 
	TRCell():New(oSection1,"CJM_ICMEST"	,cQuery,STR0026,/*cPicture*/,TamSx3("CJM_ICMEST")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Estorno"
	

	//oBreak := TRBreak():New(oSection1,{|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA+CJM_ITEFIM+CJM_PRDFIM)  },/*TEXTO*/,.F.,/*TEXTO*/,.T.) // Quebra inicial por NF
	oBreak := TRBreak():New(oSection1,{|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_PRDFIM)  },/*TEXTO*/,.F.,/*TEXTO*/,.T.) // Quebra inicial por NF
	TRFunction():New(oSection1:Cell("CJM_ICMEST") ,  ,"SUM", oBreak, STR0027 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor total do Estorno"

ElseIF nOrdem == 3
	
	TRCell():New(oSection,"CJM_FILIAL"	,cQuery,STR0003,/*cPicture*/,TamSx3("CJM_FILIAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Filial"
	TRCell():New(oSection,"CJM_DOCORI"	,cQuery,STR0005,/*cPicture*/,TamSx3("CJM_DOCORI")[1], /*lPixel*/,/*{||code-block de impressao }*/)  //"Nf Ult Ent"
	TRCell():New(oSection,"CJM_SERORI"	,cQuery,STR0006,/*cPicture*/,TamSx3("CJM_SERORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie Ult Ent"
	TRCell():New(oSection,"CJM_FORNEC"	,cQuery,STR0007,/*cPicture*/,TamSx3("CJM_FORNEC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Forne Ult Ent"
	TRCell():New(oSection,"CJM_LOJAEN"	,cQuery,STR0008,/*cPicture*/,TamSx3("CJM_LOJAEN")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Loja Forne Ult Ent"
	TRCell():New(oSection,"CJM_DTORIG"	,cQuery,STR0010,/*cPicture*/,TamSx3("CJM_DTORIG")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Dt Entrada Ult Ent"
	TRCell():New(oSection,"CJM_LOTORI"	,cQuery,STR0011,/*cPicture*/,TamSx3("CJM_LOTORI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Lote Ult Ent"
	TRCell():New(oSection,"CJM_UM"	    ,cQuery,STR0012,/*cPicture*/,TamSx3("CJM_UM"    )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Unid Medida"
	If nOpcao <> 2
		TRCell():New(oSection,"CJM_QTESTR"	,cQuery,STR0023,/*cPicture*/,TamSx3("CJM_QTESTR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtd Estorno"
		TRCell():New(oSection,"CJM_PRDINT"	,cQuery,STR0024,/*cPicture*/,TamSx3("CJM_PRDINT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prd Intermediario"
		TRCell():New(oSection,"CJM_PRCOMP"	,cQuery,STR0025,/*cPicture*/,TamSx3("CJM_PRCOMP")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Componente" 
	Endif 

	oSection1 := TRSection():New(oSection,"Detalhe dos Produtos",{cQuery,"CJM","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSection1:nLeftMargin := oSection:nLeftMargin + 5
	oSection1:SetLinesBefore(0)

	
	TRCell():New(oSection1,"CJM_PERIOD"	,cQuery,STR0004,/*cPicture*/,TamSx3("CJM_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Ano/Mês"
	TRCell():New(oSection1,"CJM_DOCSAI"	,cQuery,STR0015,/*cPicture*/,TamSx3("CJM_DOCSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"NF de Saída"
	TRCell():New(oSection1,"CJM_SERSAI"	,cQuery,STR0016,/*cPicture*/,TamSx3("CJM_SERSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie Saída"
	TRCell():New(oSection1,"CJM_DTSAI"	,cQuery,STR0030,/*cPicture*/,TamSx3("CJM_DTSAI" )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Dt Emissao Saída"
	TRCell():New(oSection1,"CJM_CLIFOR"	,cQuery,STR0017,/*cPicture*/,TamSx3("CJM_CLIFOR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Cliente"
	TRCell():New(oSection1,"CJM_LOJA"	,cQuery,STR0018,/*cPicture*/,TamSx3("CJM_LOJA"  )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Loja"
	TRCell():New(oSection1,"CJM_PRDFIM"	,cQuery,STR0019,/*cPicture*/,TamSx3("CJM_PRDFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Prod Saída"
	TRCell():New(oSection1,"B1_DESC"	,cQuery,STR0031,/*cPicture*/,TamSx3("B1_DESC"   )[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Descrição do Produto"
	TRCell():New(oSection1,"CJM_ITEFIM"	,cQuery,STR0020,/*cPicture*/,TamSx3("CJM_ITEFIM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Item NF Saída"
	TRCell():New(oSection1,"CJM_QTDSAI"	,cQuery,STR0021,/*cPicture*/,TamSx3("CJM_QTDSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtd Nf Saída"
	TRCell():New(oSection1,"CDA_CODLAN"	,cQuery,STR0028,/*cPicture*/,TamSx3("CDA_CODLAN")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Cod Lançamento"
	TRCell():New(oSection1,"CJM_ICMEST"	,cQuery,STR0026,/*cPicture*/,TamSx3("CJM_ICMEST")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Estorno"


	oBreak := TRBreak():New(oSection1,{|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCORI+CJM_SERORI+CJM_FORNEC+CJM_LOJAEN+CJM_PRDFIM)  },/*TEXTO*/,.F.,/*TEXTO*/,.T.) // Quebra inicial por NF
	TRFunction():New(oSection1:Cell("CJM_ICMEST") ,  ,"SUM", oBreak, STR0027 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor total do Estorno"
	
Endif



Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Alexandre Esteves
@since 01/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport ,cQuery ,dDataDe, dDataAte ,cDocIni ,cSerIni ,cDocFim ,cSerfim , lFilial , nOpcao ,nOrdem ,cProdDe ,cProdAte )  

Local cSelect	:= ""
Local cFrom     := ""
Local cWhere    := ""
Local cOrder    := ""
Local oSection1b 
Local oSection2b 
Local aFil      := {}   
Local cTpDb		:= tcgetdb()
Local nContFil   := 0 
Local aAreaSM0 	 := SM0->(GetArea()) 

Default nOpcao    := 1
Default nOrdem    := 1
 
aFil       := FISR181FIL(lFilial)

For nContFil := 1 To Len(aFil)

		SM0->(DbGoTop ())
		SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		oSection1b := oReport:Section(1)
		oSection2b := oReport:Section(1):Section(1)

		//Construção do Embbeded SQL
		If cTpDb == "ORACLE"
			cSelect :="NVL(CDA.CDA_CODLAN,'SEM LCTO') AS CDA_CODLAN, "
		ElseIf cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL"
			cSelect :="COALESCE(CDA.CDA_CODLAN,'SEM LCTO') CDA_CODLAN, "
		Else
			cSelect :="ISNULL(CDA.CDA_CODLAN,'SEM LCTO') AS CDA_CODLAN, "	
		Endif
		cSelect += "CJM.CJM_FILIAL, CJM.CJM_PERIOD, CJM.CJM_DOCORI, CJM.CJM_SERORI, CJM.CJM_FORNEC, CJM.CJM_LOJAEN, CJM.CJM_PRDORI,CJM.CJM_DTORIG, "
		cSelect += "CJM.CJM_LOTORI, CJM.CJM_UM, CJM.CJM_SEGUM, CJM.CJM_QTSEGU, CJM.CJM_DOCSAI, CJM.CJM_SERSAI, CJM.CJM_CLIFOR, CJM.CJM_LOJA, "
		cSelect += "CJM.CJM_PRDFIM, CJM.CJM_ITEFIM, CJM.CJM_QTDSAI, CJM.CJM_ICMUNT, CJM.CJM_QTESTR, CJM.CJM_PRDINT, CJM.CJM_PRCOMP,CJM.CJM_ICMEST, CJM.CJM_DTSAI, SB1.B1_DESC  "

		cFrom   := RetSqlName("CJM") + " CJM "
		cFrom   += "LEFT JOIN "+RetSqlName("CDA")+" CDA  ON  (CDA.CDA_FILIAL = '" + xFilial("CDA")+"' AND CDA.CDA_NUMERO = CJM.CJM_DOCSAI AND CDA.CDA_SERIE = CJM.CJM_SERSAI AND CDA.D_E_L_E_T_=' ') "
		cFrom   += "LEFT JOIN "+RetSqlName("SB1")+" SB1  ON  (SB1.B1_FILIAL = '" + xFilial("SB1")+"' AND SB1.B1_COD = CJM.CJM_PRDFIM AND SB1.D_E_L_E_T_=' ') "
						
		cWhere  := "CJM.CJM_FILIAL = '" + xFilial("CJM") + "' AND "
		cWhere  += "CJM.CJM_DTSAI  BETWEEN  '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + " ' AND "
		cWhere  += "CJM.CJM_DOCSAI BETWEEN  '" + cDocIni + "' AND '" + cDocFim + " ' AND "
		cWhere  += "CJM.CJM_SERSAI BETWEEN  '" + cSerIni + "' AND '" + cSerFim + " ' AND "
		cWhere  += "CJM.CJM_PRDFIM BETWEEN  '" + cProdDe + "' AND '" + cProdAte + " ' AND "
		If nOpcao == 1
			cWhere  += "CJM_PRCOMP <> ' ' AND "
		ElseIF nOpcao == 2
			cWhere  += "CJM_PRCOMP = ' ' AND "
		Endif
		cWhere  += "CJM.D_E_L_E_T_ = ' ' "
		if nOrdem == 1
			cOrder  := "CJM.CJM_PERIOD, CJM.CJM_DOCSAI, CJM.CJM_SERSAI, CJM.CJM_PRDFIM "
		Elseif nOrdem == 2
			cOrder  := "CJM.CJM_PERIOD, CJM.CJM_PRDFIM, CJM.CJM_DOCSAI, CJM.CJM_SERSAI " 
		Elseif nOrdem == 3
			cOrder  := "CJM.CJM_PERIOD, CJM.CJM_DOCORI, CJM.CJM_SERORI, CJM.CJM_PRDFIM "
		Endif	
			

		cSelect := "%" + cSelect + "%"
		cFrom   := "%" + cFrom   + "%"
		cWhere  := "%" + cWhere  + "%"
		cOrder	:= "%" + cOrder  + "%"

		oSection1b:BeginQuery()

		BeginSql Alias cQuery
			
			COLUMN CJM_DTORIG AS DATE

			SELECT %Exp:cSelect%
			FROM  %Exp:cFrom% 
			WHERE %Exp:cWhere%
			Order by %Exp:cOrder%

		EndSQL

		oSection1b:EndQuery()
		oSection2b:SetParentQuery()

		oReport:SetMeter((cQuery)->(RecCount()))

		If nOrdem == 1
			oSection2b:SetParentFilter({|cParam| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA+CJM_ITEFIM+CJM_PRDFIM) == cParam}, {|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA+CJM_ITEFIM+CJM_PRDFIM)})
		ElseIf nOrdem == 2
			oSection2b:SetParentFilter({|cParam| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_PRDFIM) == cParam}, {|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_PRDFIM)})
		ElseIF nOrdem == 3
			oSection2b:SetParentFilter({|cParam| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCORI+CJM_SERORI+CJM_FORNEC+CJM_LOJAEN+CJM_PRDFIM) == cParam}, {|| (cQuery)->(CJM_FILIAL+CJM_PERIOD+CJM_DOCORI+CJM_SERORI+CJM_FORNEC+CJM_LOJAEN+CJM_PRDFIM)})
		Endif

		//-- Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.
		TRPosition():New(oSection1b,"SA1",1,{||xFilial("SA1")+(cQuery)->(CJM_CLIFOR+CJM_LOJA)})
		TRPosition():New(oSection1b,"SA2",1,{||xFilial("SA2")+(cQuery)->(CJM_FORNEC+CJM_LOJAEN)})
		TRPosition():New(oSection1b,"SB1",1,{||xFilial("SB1")+(cQuery)->(CJM_PRDFIM)})
		TRPosition():New(oSection2b,"SB1",1,{||xFilial("SB1")+(cQuery)->(CJM_PRDORI)})
		
		oSection1b:Print()	
Next
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL	

Return


//------------------------------------------------------------
/*/{Protheus.doc} FISR181FIL

Função que fará tratamento das filiais selecionadas pelo usuário, e que 
serão consideradas no relatorio.

@author Bruce Mello	
@since 17/08/2022
@version 12.1.2210
/*/
//------------------------------------------------------------------
Function FISR181FIL(lFilial)

Local aFil	    := {} 
Local aSM0	    := {} 
Local aAreaSM0	:= {} 
Local nFil	    := 0 

Default lFilial	:= .F.

//nFilial indica se deverá ser exibda a tela para o usuário selecionar quais filiais deverão ser processadas
//Se nFilial estiver 2, a função retornará a filial logada.
If lFilial 
    //chama função para usuário escolher filial
    aFil:= MatFilCalc( .T. )
    If len(aFil) ==0
        MsgAlert(STR0029) //'Nenhuma filial foi selecionada, o processamento não será realizado.'
    EndiF

Else	
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF

IF Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente
	//--------------------------------------------------------
	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof())
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. (aFil[nFil][1] .OR. !lFilial) .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf

	SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0


