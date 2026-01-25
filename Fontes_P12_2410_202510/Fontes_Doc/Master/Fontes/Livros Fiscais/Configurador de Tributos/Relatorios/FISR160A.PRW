#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISR160.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}FISR160A
Relatório de simples conferência dos tributos genéricos calculados nos 
documentos fiscais, indepentendemente se o tributo foi recolhido anteriormente
na nota fiscfiscal, se houve retenção na fonte, trata-se de uma listagem 
de todos os documentos fiscais que possuem o tributo genérico calculado.

@author Erick G Dias
@since 09/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Function FISR160A()

Local oReport
Local cMsg      := ""
Local ccAlias   := getNextAlias()

dbSelectArea("F2D")
F2D->(dbSetOrder(1))

If Pergunte("FISR160A",.T.)
    cMsg    := ChkPerg()
    If Empty(cMsg)        
        oReport := ReportDef(ccAlias, "FISR160A")
        oReport:PrintDialog()
    
        If Select(ccAlias) > 0
            dbSelectArea(ccAlias)
            (ccAlias)->(DbCloseArea())
        EndIf

    Else
        MsgAlert(cMsg)
    EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ReportDef

Função que montará a estrutura do relatório

@author Erick G Dias
@since 09/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ReportDef(ccAlias, cPerg )

Local oReport
Local oSection1
Local oSection2
Local cTitle    := STR0043 + " - " + Iif(MV_PAR05 == 1,"Analítico","Sintético")//"Relatório de conferência da escrituração dos Tributos"//STR0002 + MV_PAR04 + STR0001 //" por Documento Fiscal" //"Listagem do Tributo "
Local oBreak1   := Nil
Local nBorder    := 1 //superior
Local nBorder4   := 4 //direita
Default ccAlias   := getNextAlias()

oReport	:= TReport():New('FISR160A', cTitle ,cPerg,{|oReport|ReportPrint(oReport,ccAlias, MV_PAR01, MV_PAR02, (MV_PAR03 == 1), MV_PAR04, MV_PAR05 )},'')
oReport:SetLandScape()
oReport:HideParamPage()
oReport:SetLineHeight(40)

oSection1 := TRSection():New( oReport, STR0003, {"F2B"} ) //"Regra de Cálculo"
oSection1:SetPageBreak(.T.)
oSection1:SetBorder(2)

//Seção 1 - Regra do Tributo
TRCell():New(oSection1,"FT_FILIAL",  "SFT", STR0004) //"Filial"
TRCell():New(oSection1,"FT_TIPOMOV", "SFT", STR0005,,30,,{||FSR160OpNf(FT_TIPOMOV, FT_TIPO)}) //"Operação NF"
TRCell():New(oSection1,"F2B_REGRA",	 "F2B", STR0006) //"Regra do Tributo"
TRCell():New(oSection1,"F2B_DESC",	 "F2B", STR0007) //"Descrição da Regra"

If MV_PAR05 == 2 //Aqui o valor é menor pois não terá a coluna do item
    TRCell():New(oSection1,"",  "", "","@!",68) 
Else //Aqui terá uma coluna a mais, por isso o valor é maior
    TRCell():New(oSection1,"",  "", "","@!",78) 
EndIF

// Seção 2 - Documentos Fiscais
oSection2 := TRSection():New(oSection1 , STR0037, {"SFT"})//"Tributos por Documentos Fiscais"
TRCell():New(oSection2,"FT_NFISCAL", "SFT", STR0008) //"Número NF"
TRCell():New(oSection2,"FT_SERIE",	 "SFT", STR0009) //"Série NF"
TRCell():New(oSection2,"FT_CLIEFOR", "SFT", STR0010) //"Cod. Participante"
TRCell():New(oSection2,"FT_LOJA",	 "SFT", STR0011) //"Loja Participante"
TRCell():New(oSection2,"CNOME",       ""  , STR0041,,30,,{||FSR160CF((ccAlias)->FT_TIPOMOV, (ccAlias)->FT_TIPO,(ccAlias)->FT_CLIEFOR,(ccAlias)->FT_LOJA,"1")}) //"Razão Social"
TRCell():New(oSection2,"CCGC",	      ""  , STR0042,,22,,{||FSR160CF((ccAlias)->FT_TIPOMOV, (ccAlias)->FT_TIPO,(ccAlias)->FT_CLIEFOR,(ccAlias)->FT_LOJA,"2")}) //"CGC"

If MV_PAR05 == 1 //Analítico adiciono coluna do item
    TRCell():New(oSection2,"FT_ITEM",	 "SFT", STR0013) //"Item NF"
EndIF

TRCell():New(oSection2,"FT_EMISSAO", "SFT", STR0012) //"Data"
TRCell():New(oSection2,"CJ3_VLTRIB", "CJ3", STR0044)//"Tributado"
TRCell():New(oSection2,"CJ3_VLISEN", "CJ3", STR0045)//"Isento"
TRCell():New(oSection2,"CJ3_VLOUTR", "CJ3", STR0046)//"Outros"
TRCell():New(oSection2,"CJ3_VLDIFE", "CJ3", STR0047)//"Diferido"
TRCell():New(oSection2,"CJ3_VLMAJO", "CJ3", STR0048)//"Majorado"

//Insere linha superior no cabeçalho
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CNOME"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CCGC"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CJ3_VLTRIB"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CJ3_VLISEN"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CJ3_VLOUTR"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CJ3_VLDIFE"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CJ3_VLMAJO"):SetBorder(nBorder,1,000000,.T.)

If MV_PAR05 == 1 //Analítico adiciono coluna do item
    oSection2:Cell("FT_ITEM"):SetBorder(nBorder,1,000000,.T.)    
EndIF

//Insere linha na direita no cabeçalho
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CNOME"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CCGC"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CJ3_VLTRIB"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CJ3_VLISEN"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CJ3_VLOUTR"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CJ3_VLDIFE"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CJ3_VLMAJO"):SetBorder(nBorder4,1,000000,.T.)

If MV_PAR05 == 1 //Analítico adiciono coluna do item
    oSection2:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.T.)    
EndIf

//Insere linha na direita nas linhas
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CNOME"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CCGC"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CJ3_VLTRIB"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CJ3_VLISEN"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CJ3_VLOUTR"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CJ3_VLDIFE"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CJ3_VLMAJO"):SetBorder(nBorder4,1,000000,.F.)

If MV_PAR05 == 1 //Analítico adiciono coluna do item
    oSection2:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.F.)    
EndIf

//Alinhamento centralizado
oSection2:Cell("FT_NFISCAL"):nAlign := 2
oSection2:Cell("FT_SERIE"):nAlign := 2
oSection2:Cell("FT_CLIEFOR"):nAlign := 2
oSection2:Cell("FT_EMISSAO"):nAlign := 2
oSection2:Cell("FT_LOJA"):nAlign := 2
oSection2:SetAutoSize(.T.)

oBreak1 := TRBreak():New(oSection1,{|| (ccAlias)->(FT_FILIAL+F2B_REGRA+FT_TIPOMOV+FT_TIPO)  },STR0018,.F.,STR0017,.T.) //'Total da Regra por Operação NF' //'Total da Regra por Operação NF '
TRFunction():New(oSection2:Cell("CJ3_VLTRIB") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
TRFunction():New(oSection2:Cell("CJ3_VLISEN") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
TRFunction():New(oSection2:Cell("CJ3_VLOUTR") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
TRFunction():New(oSection2:Cell("CJ3_VLDIFE") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
TRFunction():New(oSection2:Cell("CJ3_VLMAJO") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
          
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc}ReportPrint

Função que fará a query para obter as informações

@author Erick G Dias
@since 09/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
static function ReportPrint(oReport, ccAlias, dDtIni, dDtFin, lSelFil, cTrib, nModoRelat)
local oSection1b := oReport:Section(1)
local oSection2b := ''
Local cFiltro    := ''
Local cSelect    := ''
Local cJoin      := ""
Local nContFil   := 0
Local aFil       := x173GetFil(lSelFil)
Local aAreaSM0 	 := SM0->(GetArea())

oSection2b := oReport:Section(1):Section(1)

For nContFil := 1 To Len(aFil)
    
    SM0->(DbGoTop ())
	SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL   

    //-----------------
    //Seção do select
    //-----------------
    cSelect := "%"     
    
    //No analítico adiciono coluna do item
    IF nModoRelat == 1 
        cSelect += " SFT.FT_ITEM,  "
    EndIF
    
    cSelect += " F2B.F2B_TRIB, F2B.F2B_FILIAL, F2B.F2B_REGRA, F2B.F2B_DESC, CJ3.CJ3_FILIAL, "
    cSelect += " SFT.FT_FILIAL, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_EMISSAO, SFT.FT_TIPOMOV, SFT.FT_TIPO, "
    cSelect += " Sum(CJ3.CJ3_VLTRIB) CJ3_VLTRIB, Sum(CJ3.CJ3_VLISEN) CJ3_VLISEN, Sum(CJ3.CJ3_VLOUTR) CJ3_VLOUTR, Sum(CJ3.CJ3_VLDIFE) CJ3_VLDIFE, Sum(CJ3.CJ3_VLMAJO) CJ3_VLMAJO "    
    cSelect += "%"

    //-----------------
    //Seção do where
    //-----------------
    cFiltro := "%"
    cFiltro += " CJ3.CJ3_FILIAL = " + ValToSQL(  xFilial('CJ3')  ) + " AND "
    cFiltro += " CJ3.CJ3_DTEXCL = ' ' AND CJ3.D_E_L_E_T_	= ' ' "
    
    //-----------------
    //Seção do Group By
    //-----------------
    cFiltro += " GROUP BY CJ3_FILIAL, F2B_TRIB, CJ3.CJ3_TRIB, F2B_FILIAL, F2B_REGRA, F2B_DESC, FT_FILIAL, FT_NFISCAL, FT_SERIE, FT_CLIEFOR, FT_LOJA, FT_EMISSAO,  FT_TIPOMOV, FT_TIPO  "

    //No analítico adiciono coluna do item
    IF nModoRelat == 1
        cFiltro += " ,SFT.FT_ITEM "
    EndIF
    
    //-----------------
    //Seção do Order By
    //-----------------
    cFiltro += " ORDER BY CJ3.CJ3_FILIAL, F2B.F2B_TRIB , CJ3.CJ3_TRIB, SFT.FT_TIPOMOV, SFT.FT_TIPO, SFT.FT_EMISSAO, SFT.FT_NFISCAL "
    //No analítico adiciono coluna do item
    IF nModoRelat == 1
        cFiltro += " ,SFT.FT_ITEM "
    EndIF
    cFiltro += "%"
    
    cJoin   := "%"
    If !Empty(cTrib)
        cJoin	+=	"JOIN "+RetSqlName("F2E")+" F2E ON F2E.F2E_FILIAL='"+xFilial("F2E")+"' AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.F2E_TRIB = " + ValToSQL( cTrib   ) + " AND F2E.D_E_L_E_T_=' ' " 	
    EndIf
    cJoin   += "%"
    
    oSection1b:BeginQuery()
    BeginSql Alias ccAlias
        SELECT
            %Exp:cSelect%            
        FROM
            %TABLE:CJ3% CJ3
            JOIN %Table:SFT% SFT ON( SFT.FT_FILIAL  = %xFilial:SFT% AND SFT.FT_IDTRIB = CJ3.CJ3_IDTGEN AND SFT.FT_ENTRADA >= %Exp:DToS(dDtIni)%  AND  SFT.FT_ENTRADA <= %Exp:DToS(dDtFin)% AND SFT.FT_DTCANC = ' ' AND SFT.%NotDel%)
            JOIN %Table:F2D% F2D ON( F2D.F2D_FILIAL = %xFilial:F2D% AND F2D.F2D_ID = CJ3.CJ3_IDF2D AND F2D.%NotDel%)
            JOIN %Table:F2B% F2B ON( F2B.F2B_FILIAL = %xFilial:F2B% AND F2B.F2B_ID = F2D.F2D_IDCAD AND F2B.%NotDel%)            
            %Exp:cJoin%
        WHERE
            %Exp:cFiltro%
    EndSql

    oSection1b:EndQuery()

    oSection2b:SetParentQuery()

    oSection2b:SetParentFilter({|cParam| (ccAlias)->F2B_REGRA + (ccAlias)->FT_TIPOMOV + (ccAlias)->FT_TIPO  == cParam}, {|| (ccAlias)->F2B_REGRA + (ccAlias)->FT_TIPOMOV + (ccAlias)->FT_TIPO })    

    oReport:SetMeter((ccAlias)->(RecCount()))
    oSection1b:Print()

Next nX
 
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL			

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ChkPerg

Função que fará as devidas validações dos parãmetros iniciais

@author Erick G Dias
@since 09/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ChkPerg()

Local cRet  := ""

Do Case
    Case Empty(MV_PAR01)
        cRet    := STR0020 //"Obrigatório informar data inicial"
    Case Empty(MV_PAR02)
        cRet    := STR0021 //"Obrigatório informar data final"    
    Case MV_PAR02 < MV_PAR01
        cRet    := STR0023 //"Data final não poderá ser inferior a data inicial"
EndCase

Return cRet