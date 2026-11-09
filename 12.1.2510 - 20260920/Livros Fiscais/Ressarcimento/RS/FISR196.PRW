#Include "FISR196.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR196

Relatorio de conferencia Apuração do ICMS Presumido e Efetivo.

@return	Nil

@author Eduardo Vicente da Silva
@since 30/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR196()
Local	oReport

						
If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel

	If Pergunte("FISR196",.T.)
		oReport:= ReportDef(mv_par01,mv_par02,mv_par03)
		oReport:PrintDialog()
	Endif	

Else
	Alert(STR0001)  //"Rotina disponível apenas em TReport (Relatório Personalizável)."
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Eduardo V. da Silva
@since 30/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cMesAno, cLivro, cTpImp)
Local	oReport
Local	oSection, oSection1, oBreak, oBreak2
Local	aSF2Stru	:= {} 
Local	aCD0Stru	:= {} 
Local	cQuery		:= GetNextAlias()
Local 	cTitRel		:= STR0002  //"Relatório de Conferência"

Private lAutomato := Iif(IsBlind(),.T.,.F.)

IF lAutomato
    cMesAno := MV_PAR01  
    cLivro  := MV_PAR02
    cTpImp  := MV_PAR03
EndIF

oReport := TReport():New("FISR196",cTitRel,"FISR196",{|oReport| ReportPrint(oReport,oSection,cQuery,cMesAno, cLivro, cTpImp)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.

oSection := TRSection():New(oReport,cTitRel,{cQuery,"F3Q","F3S","F3R","F3T","SA1","SA2","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:lHeaderVisible := .F.
oSection:SetHeaderSection(.T.)
oSection:SetHeaderPage(.T.)
oSection:SetLinesBefore(2)

If cTpImp == 1
    TRCell():New(oSection,"F3Q_PERIOD"	,cQuery,STR0003,/*cPicture*/					         ,TamSx3("F3Q_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Ano/Mês"
    TRCell():New(oSection,"F3Q_LIVRO"	,cQuery,STR0004  ,/*cPicture*/					         ,TamSx3("F3Q_LIVRO")[1], /*lPixel*/,/*{|| code-block de impressao }*/)  //"Livro"
    TRCell():New(oSection,"F3Q_ICMSEF"	,cQuery,STR0005      ,PesqPict("F3Q","F3Q_ICMSEF"),TamSx3("F3Q_ICMSEF")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Efetivo"
    TRCell():New(oSection,"F3Q_ICMSPR"	,cQuery,STR0006    ,PesqPict("F3Q","F3Q_ICMSPR"),TamSx3("F3Q_ICMSPR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Presumido"
    TRCell():New(oSection,"F3Q_ICMSDE"	,cQuery,STR0007     ,PesqPict("F3Q","F3Q_ICMSDE"),TamSx3("F3Q_ICMSDE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Deduzido"
    TRCell():New(oSection,"F3Q_TOTCOM"	,cQuery,STR0008 ,PesqPict("F3Q","F3Q_TOTCOM"),TamSx3("F3Q_TOTCOM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Complementar"
    TRCell():New(oSection,"F3Q_TOTRES"	,cQuery,STR0009    ,PesqPict("F3Q","F3Q_TOTRES"),TamSx3("F3Q_TOTRES")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Restituir"
ElseIf cTpImp == 2
    TRCell():New(oSection,"F3S_PERIOD"	,cQuery,STR0003           ,/*cPicture*/				 ,TamSx3("F3S_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Ano/Mês"
    TRCell():New(oSection,"F3S_REGRA"	,cQuery,STR0010     ,/*cPicture*/				 ,TamSx3("F3S_REGRA")[1], /*lPixel*/,/*{|| code-block de impressao }*/)  //"Regra Cálculo"
    TRCell():New(oSection,"F3S_LIVRO"	,cQuery,STR0004             ,/*cPicture*/				 ,TamSx3("F3S_LIVRO")[1], /*lPixel*/,/*{|| code-block de impressao }*/)  //"Livro"
    TRCell():New(oSection,"F3S_ICMSEF"	,cQuery,STR0005      ,PesqPict("F3S","F3S_ICMSEF"),TamSx3("F3S_ICMSEF")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Efetivo"
    TRCell():New(oSection,"F3S_ICMSPR"	,cQuery,STR0006    ,PesqPict("F3S","F3S_ICMSPR"),TamSx3("F3S_ICMSPR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Presumido"
    TRCell():New(oSection,"F3S_ICMSDE"	,cQuery,STR0007     ,PesqPict("F3S","F3S_ICMSDE"),TamSx3("F3S_ICMSDE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Deduzido"
    TRCell():New(oSection,"F3S_QTDPAR"	,cQuery,STR0011  ,PesqPict("F3S","F3S_QTDPAR"),TamSx3("F3S_QTDPAR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Qtde de Parcelas"
    TRCell():New(oSection,"F3S_UTLPAR"	,cQuery,STR0012 ,PesqPict("F3S","F3S_UTLPAR"),TamSx3("F3S_UTLPAR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Parcela Utilizada"
    TRCell():New(oSection,"F3S_VLRPAR"	,cQuery,STR0013  ,PesqPict("F3S","F3S_VLRPAR"),TamSx3("F3S_VLRPAR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor da Parcela"
    TRCell():New(oSection,"F3S_VLRTOT"	,cQuery,STR0014       ,PesqPict("F3S","F3S_VLRTOT"),TamSx3("F3S_VLRTOT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Valor Total"
ElseIf cTpImp == 3
    TRCell():New(oSection,"F3R_PERIOD"	,cQuery,STR0003           ,/*cPicture*/				 ,TamSx3("F3R_PERIOD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Ano/Mês"
    TRCell():New(oSection,"F3R_LIVRO"	,cQuery,"Livro"             ,/*cPicture*/				 ,TamSx3("F3R_LIVRO")[1], /*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSection,"F3R_PRODUT"	,cQuery,STR0015           ,/*cPicture*/				 ,TamSx3("F3R_PRODUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Produto"
    TRCell():New(oSection,"F3R_NFISCA"	,cQuery,STR0016       ,/*cPicture*/				 ,TamSx3("F3R_NFISCA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"Nota Fiscal"
    TRCell():New(oSection,"F3R_SERIE"	,cQuery,STR0017             ,/*cPicture*/				 ,TamSx3("F3R_SERIE")[1], /*lPixel*/,/*{|| code-block de impressao }*/)  //"Serie"
    TRCell():New(oSection,"F3R_ITEM"	,cQuery,"Item"              ,/*cPicture*/				 ,TamSx3("F3R_ITEM")[1],  /*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSection,"F3R_PARTIC"	,cQuery,STR0018,/*cPicture*/				 ,TamSx3("F3R_PARTIC")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Cliente / Fornecedor"
    TRCell():New(oSection,"F3R_LOJA"	,cQuery,STR0019              ,/*cPicture*/				 ,TamSx3("F3R_LOJA")[1],  /*lPixel*/,/*{|| code-block de impressao }*/) //"Loja"
    TRCell():New(oSection,"F3R_ICMSEF"	,cQuery,STR0005      ,PesqPict("F3R","F3R_ICMSEF"),TamSx3("F3R_ICMSEF")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Efetivo"
    TRCell():New(oSection,"F3R_ICMSPR"	,cQuery,STR0006    ,PesqPict("F3R","F3R_ICMSPR"),TamSx3("F3R_ICMSPR")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Presumido"
    TRCell():New(oSection,"F3R_ICMSDE"	,cQuery,STR0007     ,PesqPict("F3R","F3R_ICMSDE"),TamSx3("F3R_ICMSDE")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Deduzido"
    //TRCell():New(oSection,"F3R_VLRCOM"	,cQuery,STR0008 ,PesqPict("F3R","F3R_VLRCOM"),TamSx3("F3R_VLRCOM")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Complementar"
    //TRCell():New(oSection,"F3R_VLRRES"	,cQuery,STR0009    ,PesqPict("F3R","F3R_VLRRES"),TamSx3("F3R_VLRRES")[1],/*lPixel*/,/*{|| code-block de impressao }*/)  //"ICMS Restituir"
EndIf

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Mauro A. Gonçalves
@since 05/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSection,cQuery,cMesAno, cLivro, cTpImp)

Local cSelect	:= ""
Local cFrom     := ""
Local cWhere    := ""
Local cOrder     := ""

If cTpImp == 1
    cSelect := "F3Q.F3Q_PERIOD, F3Q.F3Q_LIVRO, F3Q.F3Q_ICMSEF, F3Q.F3Q_ICMSPR, F3Q.F3Q_ICMSDE, F3Q.F3Q_TOTCOM, F3Q.F3Q_TOTRES "
    cFrom   := RetSqlName("F3Q") + " F3Q "
    cWhere  := "F3Q.F3Q_FILIAL = '" + xFilial("F3Q") + "' AND "
    cWhere  += "F3Q.F3Q_PERIOD = '" + cMesAno + "' AND "
    cWhere  += "F3Q.F3Q_LIVRO  = '" + cLivro  + "' AND "
    cWhere  += "F3Q.D_E_L_E_T_ = ' ' "
    cOrder  := "F3Q.F3Q_PERIOD"
ElseIf cTpImp == 2
    cSelect := "F3S.F3S_PERIOD, F3S.F3S_REGRA, F3S.F3S_LIVRO, F3S.F3S_ICMSEF, F3S.F3S_ICMSPR, F3S.F3S_ICMSDE, F3S.F3S_QTDPAR, F3S.F3S_UTLPAR, F3S.F3S_VLRPAR, F3S.F3S_VLRTOT "
    cFrom   := RetSqlName("F3S") + " F3S "
    cWhere  := "F3S.F3S_FILIAL = '" + xFilial("F3S") + "' AND "
    cWhere  += "F3S.F3S_PERIOD = '" + cMesAno + "' AND "
    cWhere  += "F3S.F3S_LIVRO  = '" + cLivro  + "' AND "
    cWhere  += "F3S.D_E_L_E_T_ = ' ' " 
    cOrder  := "F3S.F3S_REGRA"

ElseIf cTpImp == 3
    cSelect := "F3R.F3R_PERIOD, F3R.F3R_LIVRO, F3R.F3R_PRODUT, F3R.F3R_NFISCA, F3R.F3R_SERIE, F3R.F3R_ITEM, F3R.F3R_PARTIC, F3R.F3R_LOJA, F3R.F3R_ICMSEF, F3R.F3R_ICMSPR, F3R.F3R_ICMSDE, "
    cSelect += "F3R.F3R_VLRRES, F3R.F3R_VLRCOM, F3R.F3R_LOTE, F3R.F3R_TIPO, F3R.F3R_QTDMOV, F3R.F3R_DTMOV"
    cFrom   := RetSqlName("F3R") + " F3R "
    cWhere  := "F3R.F3R_FILIAL = '" + xFilial("F3R") + "' AND "
    cWhere  += "F3R.F3R_PERIOD = '" + cMesAno + "' AND "
    cWhere  += "F3R.F3R_LIVRO  = '" + cLivro  + "' AND "
    cWhere  += "F3R.D_E_L_E_T_ = ' ' " 
    cOrder  := "F3R.F3R_NFISCA, F3R.F3R_SERIE, F3R.F3R_ITEM "
EndIf

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"
cOrder	:= '%'+cOrder+'%'

oSection:BeginQuery()

BeginSql Alias cQuery
    /*
	If cTpImp == 3
        COLUMN F3R_DTMOV AS DATE
    EndIf
	*/		
    SELECT %Exp:cSelect%
	FROM  %Exp:cFrom% 
	WHERE %Exp:cWhere%
    Order by %Exp:cOrder%

EndSQL

oSection:EndQuery()

oReport:SetMeter((cQuery)->(RecCount()))

//-- Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.
If cTpImp == 2
    TRPosition():New(oSection ,"F3T",1,{||xFilial("F3T")+(cQuery)->F3S_REGRA})
EndIf
If cTpImp == 3
    TRPosition():New(oSection,"SA1",1,{||xFilial("SA1")+(cQuery)->(F3R_PARTIC+F3R_LOJA)})
    TRPosition():New(oSection,"SA2",1,{||xFilial("SA2")+(cQuery)->(F3R_PARTIC+F3R_LOJA)})
    TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(F3R_PRODUT)})
EndIf

oReport:Section(1):Init()

While !oReport:Cancel() .And. !(cQuery)->(Eof())

    If cTpImp == 1
        oSection:Cell("F3Q_PERIOD"):SetValue((cQuery)->F3Q_PERIOD)
        oSection:Cell("F3Q_LIVRO"):SetValue((cQuery)->F3Q_LIVRO)
        oSection:Cell("F3Q_ICMSEF"):SetValue((cQuery)->F3Q_ICMSEF)
        oSection:Cell("F3Q_ICMSPR"):SetValue((cQuery)->F3Q_ICMSPR)
        oSection:Cell("F3Q_ICMSDE"):SetValue((cQuery)->F3Q_ICMSDE)
        oSection:Cell("F3Q_TOTCOM"):SetValue((cQuery)->F3Q_TOTCOM)
        oSection:Cell("F3Q_TOTRES"):SetValue((cQuery)->F3Q_TOTRES)
    
    ElseIf cTpImp == 2
        oSection:Cell("F3S_PERIOD"):SetValue((cQuery)->F3S_PERIOD)
        oSection:Cell("F3S_REGRA"):SetValue((cQuery)->F3S_REGRA)
        oSection:Cell("F3S_LIVRO"):SetValue((cQuery)->F3S_LIVRO)
        oSection:Cell("F3S_ICMSEF"):SetValue((cQuery)->F3S_ICMSEF)
        oSection:Cell("F3S_ICMSPR"):SetValue((cQuery)->F3S_ICMSPR)
        oSection:Cell("F3S_ICMSDE"):SetValue((cQuery)->F3S_ICMSDE)
        oSection:Cell("F3S_QTDPAR"):SetValue((cQuery)->F3S_QTDPAR)
        oSection:Cell("F3S_UTLPAR"):SetValue((cQuery)->F3S_UTLPAR)
        oSection:Cell("F3S_VLRPAR"):SetValue((cQuery)->F3S_VLRPAR)
        oSection:Cell("F3S_VLRTOT"):SetValue((cQuery)->F3S_VLRTOT)
    
    ElseIf cTpImp == 3
        oSection:Cell("F3R_PERIOD"):SetValue((cQuery)->F3R_PERIOD)
        oSection:Cell("F3R_LIVRO"):SetValue((cQuery)->F3R_LIVRO)
        oSection:Cell("F3R_PRODUT"):SetValue((cQuery)->F3R_PRODUT)
        oSection:Cell("F3R_NFISCA"):SetValue((cQuery)->F3R_NFISCA)
        oSection:Cell("F3R_SERIE"):SetValue((cQuery)->F3R_SERIE)
        oSection:Cell("F3R_ITEM"):SetValue((cQuery)->F3R_ITEM)
        oSection:Cell("F3R_PARTIC"):SetValue((cQuery)->F3R_PARTIC)
        oSection:Cell("F3R_LOJA"):SetValue((cQuery)->F3R_LOJA)
        oSection:Cell("F3R_ICMSEF"):SetValue((cQuery)->F3R_ICMSEF)
        oSection:Cell("F3R_ICMSPR"):SetValue((cQuery)->F3R_ICMSPR)
        oSection:Cell("F3R_ICMSDE"):SetValue((cQuery)->F3R_ICMSDE)
        //oSection:Cell("F3R_VLRCOM"):SetValue((cQuery)->F3R_VLRCOM)
        //oSection:Cell("F3R_VLRRES"):SetValue((cQuery)->F3R_VLRRES)
    EndIf

	oReport:Section(1):PrintLine()
				
	(cQuery)->(dbSkip())
	oReport:IncMeter()
EndDo

(cQuery)->(dbCloseArea())

oReport:Section(1):Finish()
oReport:Section(1):SetPageBreak(.T.)

Return(oReport)
