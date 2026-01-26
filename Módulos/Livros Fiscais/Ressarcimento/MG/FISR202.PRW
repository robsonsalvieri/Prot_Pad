#Include "FISR202.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR202

Relatorio de conferencia Apuração do ICMS Presumido e Efetivo.

@return	Nil

@author Eduardo Vicente da Silva
@since 08/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR202()
Local	oReport

						
If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel

	If Pergunte("FISR202",.T.)
		oReport:= ReportDef(mv_par01,mv_par02,mv_par03,mv_par04,Iif(mv_par05==2,.T.,.F.))
		oReport:PrintDialog()
	Endif	

Else
	Alert(STR0001)  //STR0001 //"Rotina disponível apenas em TReport (Relatório Personalizável)."
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Eduardo V. da Silva
@since 08/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cMesAnoDe, cMesAnoAte, cProdDe, cProdAte, lImpEntrada)
Local	oReport
Local	oSection
Local	aSF2Stru	:= {} 
Local	aCD0Stru	:= {} 
Local	cQuery		:= GetNextAlias()
Local 	cTitRel		:= STR0002  //STR0002 //"Relatório de Conferência"

oReport := TReport():New("FISR202",cTitRel,"FISR202",{|oReport| ReportPrint(oReport,oSection,cQuery,cMesAnoDe,cMesAnoAte,cProdDe,cProdAte,lImpEntrada)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
oReport:SetLandScape(.T.)

oSection := TRSection():New(oReport,cTitRel,{cQuery,"F3Y","SA1","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection:lHeaderVisible := .F.
oSection:SetHeaderSection(.T.)
oSection:SetHeaderPage(.T.)
oSection:SetLinesBefore(2)

TRCell():New(oSection,"F3Y_PERIOD"	,cQuery,STR0003,PesqPict("F3Y","F3Y_PERIOD") ,TamSx3("F3Y_PERIOD")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0003 //"Ano/Mês"
TRCell():New(oSection,"F3Y_DTMOVT"	,cQuery,STR0004,/*cPicture*/				 ,TamSx3("F3Y_DTMOVT")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0004 //"Data do Movimento"
TRCell():New(oSection,"F3Y_PRODUT"	,cQuery,STR0005,/*cPicture*/				 ,TamSx3("F3Y_PRODUT")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0005 //"Produto"
TRCell():New(oSection,"F3Y_NFISCA"	,cQuery,STR0006,/*cPicture*/				 ,TamSx3("F3Y_NFISCA")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0006 //"Nota Fiscal"
TRCell():New(oSection,"F3Y_SERIE"	,cQuery,STR0007,/*cPicture*/				 ,TamSx3("F3Y_SERIE")[1]    , /*lPixel*/,/*{|| code-block de impressao }*/) //STR0007 //"Serie"
TRCell():New(oSection,"F3Y_ITEM"	,cQuery,STR0008,/*cPicture*/				 ,TamSx3("F3Y_ITEM")[1]     ,  /*lPixel*/,/*{|| code-block de impressao }*/) //STR0008 //"Item"
TRCell():New(oSection,"F3Y_CODPAR"	,cQuery,STR0009,/*cPicture*/				 ,TamSx3("F3Y_CODPART")[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0009 //"Participante"
TRCell():New(oSection,"F3Y_LOJPAR"	,cQuery,STR0010,/*cPicture*/				 ,TamSx3("F3Y_LOJPART")[1]  ,  /*lPixel*/,/*{|| code-block de impressao }*/) //STR0010 //"Loja"
TRCell():New(oSection,"F3Y_QUANT"	,cQuery,STR0011,PesqPict("F3Y","F3Y_QUANT")  ,TamSx3("F3Y_QUANT")[1]    ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0011 //"Quantidade"
TRCell():New(oSection,"F3Y_VLRUNI"	,cQuery,STR0012,PesqPict("F3Y","F3Y_VLRUNI") ,TamSx3("F3Y_VLRUNI")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0012 //"Valor Unitário"
TRCell():New(oSection,"F3Y_VLRTOT"	,cQuery,STR0013,PesqPict("F3Y","F3Y_VLRTOT") ,TamSx3("F3Y_VLRTOT")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Efetivo"
TRCell():New(oSection,"F3Y_VLRPRE"	,cQuery,STR0014,PesqPict("F3Y","F3Y_VLRPRE") ,TamSx3("F3Y_VLRPRE")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Valor Presumido"
TRCell():New(oSection,"F3Y_VLRCOM"	,cQuery,STR0016,PesqPict("F3Y","F3Y_VLRCOM") ,TamSx3("F3Y_VLRCOM")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Complemento"
TRCell():New(oSection,"F3Y_VLRRES"	,cQuery,STR0017,PesqPict("F3Y","F3Y_VLRRES") ,TamSx3("F3Y_VLRRES")[1]   ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Restituição"
TRCell():New(oSection,"VLRCOMFEM"	,      ,STR0023,PesqPict("F3Y","F3Y_VLRCOM") ,18                        ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Complemento FEM"
TRCell():New(oSection,"VLRRESFEM"	,      ,STR0024,PesqPict("F3Y","F3Y_VLRRES") ,18                        ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Restituição FEM"
TRCell():New(oSection,"TIPO"	    ,      ,STR0018,/*cPicture*/				 ,12                        ,/*lPixel*/,/*{|| code-block de impressao }*/) //STR0018 //"Tipo"

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Eduardo V. da Silva
@since 08/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,oSection,cQuery,cMesAnoDe,cMesAnoAte,cProdDe,cProdAte,lImpEntrada)

Local cSelect	    := ""
Local cFrom         := ""
Local cInner        := ""
Local cWhere        := ""
Local cOrder        := ""
Local aDadosEnt     := {}
Local nPos          := 0
Local oMovEntrada
Local nVlrCom       := 0
Local nVlrRes       := 0
Local nVlrComFem    := 0
Local nVlrResFem    := 0

cSelect := "F3Y.F3Y_PERIOD, F3Y.F3Y_PRODUT, F3Y.F3Y_NFISCA, F3Y.F3Y_SERIE, F3Y.F3Y_ITEM, F3Y.F3Y_CODPAR, F3Y.F3Y_LOJPAR, F3Y.F3Y_QUANT, F3Y.F3Y_VLRPRE, F3Y.F3Y_VLRRES, F3Y.F3Y_VLRCOM, "
cSelect += "F3Y.F3Y_TIPOMO, F3Y.F3Y_DTMOVT, F3Y.F3Y_VLRUNI, F3Y.F3Y_VLRTOT, F3Y.F3Y_ALIQIC, SFT.FT_ALIQICM, SFT.FT_ALQFECP "
cFrom   := RetSqlName("F3Y") + " F3Y "
cInner  := RetSqlName("SFT") + " SFT ON( SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND SFT.FT_NFISCAL = F3Y.F3Y_NFISCA AND SFT.FT_SERIE = F3Y.F3Y_SERIE AND SFT.FT_CLIEFOR = F3Y.F3Y_CODPAR AND SFT.FT_LOJA = F3Y.F3Y_LOJPAR AND SFT.FT_PRODUTO = F3Y.F3Y_PRODUT AND SFT.FT_ITEM = F3Y.F3Y_ITEM AND SFT.D_E_L_E_T_ = ' ') "
cWhere  := "F3Y.F3Y_FILIAL = '" + xFilial("F3Y") + "' AND "
cWhere  += "F3Y.F3Y_PERIOD BETWEEN '" + cMesAnoDe + "' AND '" + cMesAnoAte + "' AND " 
cWhere  += "F3Y.F3Y_PRODUT BETWEEN '" + cProdDe   + "' AND '" + cProdAte   + "' AND "
cWhere  += "F3Y.D_E_L_E_T_ = ' ' " 
cOrder  := "F3Y.F3Y_NFISCA, F3Y.F3Y_SERIE, F3Y.F3Y_ITEM "

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cInner  := "%" + cInner  + "%"
cWhere  := "%" + cWhere  + "%"
cOrder	:= '%' + cOrder  + '%'

oSection:BeginQuery()

BeginSql Alias cQuery
    
    COLUMN F3Y_DTMOVT AS DATE
    	
    SELECT %Exp:cSelect%
	FROM   %Exp:cFrom% 
    INNER JOIN %Exp:cInner% 
	WHERE  %Exp:cWhere%
    Order by %Exp:cOrder%

EndSQL

oSection:EndQuery()

oReport:SetMeter((cQuery)->(RecCount()))

//-- Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.
TRPosition():New(oSection,"SA1",1,{||xFilial("SA1")+(cQuery)->(F3Y_CODPAR+F3Y_LOJPAR)})
TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(F3Y_PRODUT)})

oReport:Section(1):Init()

While !oReport:Cancel() .And. !(cQuery)->(Eof())

    nVlrComFem := 0
    nVlrResFem := 0
    nVlrCom    := (cQuery)->F3Y_VLRCOM
    nVlrRes    := (cQuery)->F3Y_VLRRES

    If (cQuery)->FT_ALQFECP > 0
        nVlrComFem := ((cQuery)->F3Y_VLRCOM * (cQuery)->FT_ALQFECP) / (cQuery)->FT_ALIQICM
        nVlrResFem := ((cQuery)->F3Y_VLRRES * (cQuery)->FT_ALQFECP) / (cQuery)->FT_ALIQICM 

        nVlrCom := nVlrCom - nVlrComFem
        nVlrRes := nVlrRes - nVlrResFem
    EndIf

    oSection:Cell("F3Y_PERIOD"):SetValue((cQuery)->F3Y_PERIOD)
    oSection:Cell("F3Y_DTMOVT"):SetValue((cQuery)->F3Y_DTMOVT)
    oSection:Cell("F3Y_PRODUT"):SetValue((cQuery)->F3Y_PRODUT)
    oSection:Cell("F3Y_NFISCA"):SetValue((cQuery)->F3Y_NFISCA)
    oSection:Cell("F3Y_SERIE"):SetValue((cQuery)->F3Y_SERIE)
    oSection:Cell("F3Y_ITEM"):SetValue((cQuery)->F3Y_ITEM)
    oSection:Cell("F3Y_CODPAR"):SetValue((cQuery)->F3Y_CODPAR)
    oSection:Cell("F3Y_LOJPAR"):SetValue((cQuery)->F3Y_LOJPAR)
    oSection:Cell("F3Y_QUANT"):SetValue((cQuery)->F3Y_QUANT)
    oSection:Cell("F3Y_VLRUNI"):SetValue((cQuery)->F3Y_VLRUNI)
    oSection:Cell("F3Y_VLRTOT"):SetValue((cQuery)->F3Y_VLRTOT)
    oSection:Cell("F3Y_VLRPRE"):SetValue((cQuery)->F3Y_VLRPRE)
    oSection:Cell("F3Y_VLRCOM"):SetValue(nVlrCom)
    oSection:Cell("F3Y_VLRRES"):SetValue(nVlrRes)
    oSection:Cell("VLRCOMFEM"):SetValue(nVlrComFem)
    oSection:Cell("VLRRESFEM"):SetValue(nVlrResFem)
    oSection:Cell(STR0021):SetValue(Iif((cQuery)->F3Y_TIPOMO=="S",STR0019,STR0020)) //"Saída" //"Devolução" //"TIPO"

	oReport:Section(1):PrintLine()

    If (cQuery)->F3Y_TIPOMO == "S" .And. lImpEntrada

        oMovEntrada   := FISA197MOVIMENTO():New()
        oMovEntrada:cCodProd    := (cQuery)->F3Y_PRODUT
        oMovEntrada:nQtdade     := (cQuery)->F3Y_QUANT
        oMovEntrada:dDataMov    := (cQuery)->F3Y_DTMOVT
        oMovEntrada:cNumLote    := ""
        oMovEntrada:cLoteCli    := ""
        oMovEntrada:cTipoProc := "M"
        oMovEntrada:ICMSUnitEnt()
        
        aDadosEnt := oMovEntrada:aSldVlrDet

        For nPos:=1 to Len(aDadosEnt)
            oSection:Cell("F3Y_PERIOD"):SetValue("")
            oSection:Cell("F3Y_DTMOVT"):SetValue("")
            oSection:Cell("F3Y_PRODUT"):SetValue("")
            oSection:Cell("F3Y_NFISCA"):SetValue(aDadosEnt[nPos,1])
            oSection:Cell("F3Y_SERIE"):SetValue(aDadosEnt[nPos,2])
            oSection:Cell("F3Y_ITEM"):SetValue(aDadosEnt[nPos,5])
            oSection:Cell("F3Y_CODPAR"):SetValue(aDadosEnt[nPos,3])
            oSection:Cell("F3Y_LOJPAR"):SetValue(aDadosEnt[nPos,4])
            oSection:Cell("F3Y_QUANT"):SetValue(aDadosEnt[nPos,7])
            oSection:Cell("F3Y_VLRUNI"):SetValue(aDadosEnt[nPos,8])
            oSection:Cell("F3Y_VLRTOT"):SetValue(0)
            oSection:Cell("F3Y_VLRPRE"):SetValue(aDadosEnt[nPos,9])
            oSection:Cell("F3Y_VLRCOM"):SetValue(0)
            oSection:Cell("F3Y_VLRRES"):SetValue(0)
            oSection:Cell("VLRCOMFEM"):SetValue(0)
            oSection:Cell("VLRRESFEM"):SetValue(0)
            oSection:Cell(STR0021):SetValue(STR0022) //"Entrada" //"TIPO"

            oReport:Section(1):PrintLine()
        Next

    Endif

	oReport:ThinLine()			
	(cQuery)->(dbSkip())
	oReport:IncMeter()
EndDo

(cQuery)->(dbCloseArea())

oReport:Section(1):Finish()
oReport:Section(1):SetPageBreak(.T.)

Return
