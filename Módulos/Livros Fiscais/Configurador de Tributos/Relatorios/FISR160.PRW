#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FISR160.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc}FISR160
Relatório de simples conferência dos tributos genéricos calculados nos 
documentos fiscais, indepentendemente se o tributo foi recolhido anteriormente
na nota fiscfiscal, se houve retenção na fonte, trata-se de uma listagem 
de todos os documentos fiscais que possuem o tributo genérico calculado.

@author Erick G Dias
@since 25/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FISR160()

Local oReport
Local cMsg      := ""
Local ccAlias   := getNextAlias()
Local cRelease as character

Local cEndWeb		:= "https://tdn.totvs.com/pages/viewpage.action?pageId=821580859"

cRelease 	:=  GetRPORelease()     

If !IsBlind() 
    If FindFunction("DlgRelVer")
        DlgRelVer("FISR160","Relatorio Lancamentos fiscais",cEndWeb )  
    EndIf
EndIf

dbSelectArea("F2D")
F2D->(dbSetOrder(1))

If Pergunte("FISR160",.T.)        
    cMsg    := ChkPerg()
    If Empty(cMsg)        
        oReport := ReportDef(ccAlias, "FISR160")
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
@since 25/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ReportDef(ccAlias, cPerg )

Local oReport
Local oSection1
Local oSection2
Local cTitle    := STR0002 + MV_PAR04 + STR0001 //" por Documento Fiscal" //"Listagem do Tributo "
Local oBreak1   := Nil
Local nBorder    := 1 //superior
Local nBorder4   := 4 //direita
Default ccAlias   := getNextAlias()

oReport	:= TReport():New('FISR160', cTitle ,cPerg,{|oReport|ReportPrint(oReport,ccAlias, MV_PAR01, MV_PAR02, (MV_PAR03 == 1), MV_PAR04)},'')
oReport:SetLandScape()
oReport:HideParamPage()
oReport:SetLineHeight(40)

oSection1 := TRSection():New( oReport, STR0003, {"F2B"} ) //"Regra de Cálculo"
oSection1:SetPageBreak(.T.)
oSection1:SetBorder(2)

//Seção 1 - Regra do Tributo
TRCell():New(oSection1,"F2B_FILIAL", "F2B", STR0004) //"Filial"
TRCell():New(oSection1,"FT_TIPOMOV", "SFT", STR0005,,30,,{||FSR160OpNf(FT_TIPOMOV, FT_TIPO)}) //"Operação NF"
TRCell():New(oSection1,"F2B_REGRA",	 "F2B", STR0006) //"Regra do Tributo"
TRCell():New(oSection1,"F2B_DESC",	 "F2B", STR0007) //"Descrição da Regra"
TRCell():New(oSection1,"",  "", "","@!",60) 

// Seção 2 - Documentos Fiscais
oSection2 := TRSection():New(oSection1 , STR0037, {"SFT"})//"Tributos por Documentos Fiscais"
TRCell():New(oSection2,"FT_NFISCAL", "SFT", STR0008) //"Número NF"
TRCell():New(oSection2,"FT_SERIE",	 "SFT", STR0009) //"Série NF"
TRCell():New(oSection2,"FT_CLIEFOR", "SFT", STR0010) //"Cod. Participante"
TRCell():New(oSection2,"FT_LOJA",	 "SFT", STR0011) //"Loja Participante"
TRCell():New(oSection2,"CNOME",      "",    STR0041,,30,,{||FSR160CF((ccAlias)->FT_TIPOMOV, (ccAlias)->FT_TIPO,(ccAlias)->FT_CLIEFOR,(ccAlias)->FT_LOJA,"1")}) //"Razão Social"
TRCell():New(oSection2,"CCGC",	     "",    STR0042,,22,,{||FSR160CF((ccAlias)->FT_TIPOMOV, (ccAlias)->FT_TIPO,(ccAlias)->FT_CLIEFOR,(ccAlias)->FT_LOJA,"2")}) //"CGC"
TRCell():New(oSection2,"FT_EMISSAO", "SFT", STR0012) //"Data"
TRCell():New(oSection2,"FT_ITEM",	 "SFT", STR0013) //"Item NF"
TRCell():New(oSection2,"FT_CFOP",    "SFT", STR0038) //"CFOP"
TRCell():New(oSection2,"B1_UM",    "SB1", STR0039) //"Unidade de Medida"
TRCell():New(oSection2,"F2D_BASQTD","F2D", STR0040) //"Base de Cálculo - Quantidade"
TRCell():New(oSection2,"F2D_BASE", "F2D", STR0014) //"Base Cálculo Tributo"
TRCell():New(oSection2,"F2D_ALIQ", "F2D", STR0015) //"Alíquota Tributo"
TRCell():New(oSection2,"F2D_VALOR", "F2D", STR0016) //"Valor Tributo"

//Insere linha superior no cabeçalho
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CNOME"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("CCGC"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("FT_ITEM"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("F2D_BASE"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("F2D_ALIQ"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("F2D_VALOR"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("F2D_BASQTD"):SetBorder(nBorder,1,000000,.T.)
oSection2:Cell("B1_UM"):SetBorder(nBorder,1,000000,.T.)

//Insere linha na direita no cabeçalho
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CNOME"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("CCGC"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("F2D_BASE"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("F2D_ALIQ"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("F2D_BASQTD"):SetBorder(nBorder4,1,000000,.T.)
oSection2:Cell("B1_UM"):SetBorder(nBorder4,1,000000,.T.)
//oSection2:Cell("F2D_VALOR"):SetBorder(nBorder4,1,000000,.T.)

//Insere linha na direita nas linhas
oSection2:Cell("FT_NFISCAL"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_SERIE"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CFOP"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_CLIEFOR"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_LOJA"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CNOME"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("CCGC"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_EMISSAO"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("FT_ITEM"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("F2D_BASE"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("F2D_ALIQ"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("F2D_BASQTD"):SetBorder(nBorder4,1,000000,.F.)
oSection2:Cell("B1_UM"):SetBorder(nBorder4,1,000000,.F.)

//Alinhamento centralizado
oSection2:Cell("FT_NFISCAL"):nAlign := 2
oSection2:Cell("FT_SERIE"):nAlign := 2
oSection2:Cell("FT_CFOP"):nAlign := 2
oSection2:Cell("FT_CLIEFOR"):nAlign := 2
oSection2:Cell("FT_EMISSAO"):nAlign := 2
oSection2:Cell("FT_LOJA"):nAlign := 2
oSection2:Cell("FT_ITEM"):nAlign := 2
oSection2:Cell("B1_UM"):nAlign := 2
oSection2:SetAutoSize(.T.)

oBreak1 := TRBreak():New(oSection1,{|| (ccAlias)->(F2B_FILIAL+F2B_REGRA+FT_TIPOMOV+FT_TIPO)  },STR0018,.F.,STR0017,.T.) //'Total da Regra por Operação NF' //'Total da Regra por Operação NF '
TRFunction():New(oSection2:Cell("F2D_VALOR") ,  ,"SUM", oBreak1,STR0019 ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
          
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc}ReportPrint

Função que fará a query para obter as informações

@author Erick G Dias
@since 25/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
static function ReportPrint(oReport, ccAlias, dDtIni, dDtFin, lSelFil, cTrib)
local oSection1b := oReport:Section(1)
local oSection2b := ''
Local cFiltro    := ''
Local cJoin      := ''   
Local nContFil   := 0
Local aFil       := x173GetFil(lSelFil)
Local aAreaSM0 	 := SM0->(GetArea())

oSection2b := oReport:Section(1):Section(1)


For nContFil := 1 To Len(aFil)
    
    SM0->(DbGoTop ())
	SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL

    cFiltro = "%"
    cFiltro += "F2D.F2D_FILIAL = " + ValToSQL(  xFilial('F2D')  ) + " AND "    
    cFiltro += "F2D.D_E_L_E_T_	= ' ' ORDER BY F2D.F2D_FILIAL, F2D.F2D_TRIB, SFT.FT_TIPOMOV, SFT.FT_TIPO, SFT.FT_EMISSAO, SFT.FT_NFISCAL, SFT.FT_ITEM"
    cFiltro += "%"

    cJoin   := "%"
    If !Empty(cTrib)
        cJoin	+=	"JOIN "+RetSqlName("F2E")+" F2E ON F2E.F2E_FILIAL='"+xFilial("F2E")+"' AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.F2E_TRIB = " + ValToSQL( cTrib   ) + " AND F2E.D_E_L_E_T_= ' ' " 	
    EndIf
    cJoin   += "%"

    oSection1b:BeginQuery()
    BeginSql Alias ccAlias    

        SELECT            
            F2B.F2B_TRIB, F2B_FILIAL, F2B_REGRA, F2B_DESC,
            F2D.F2D_BASE, F2D.F2D_ALIQ, F2D.F2D_VALOR, F2D.F2D_IDREL, F2D.F2D_BASQTD,
            SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_EMISSAO,SFT.FT_ITEM, SFT.FT_IDTRIB, SFT.FT_TIPOMOV, SFT.FT_TIPO, SFT.FT_CFOP,
            SB1.B1_UM, SFT.FT_PRODUTO
        FROM
            %TABLE:F2D% F2D
            JOIN %Table:SFT% SFT ON( SFT.FT_FILIAL  = %xFilial:SFT% AND SFT.FT_IDTRIB = F2D.F2D_IDREL AND SFT.FT_ENTRADA >= %Exp:DToS(dDtIni)%  AND  SFT.FT_ENTRADA <= %Exp:DToS(dDtFin)% AND SFT.FT_DTCANC = ' ' AND SFT.%NotDel%)
            JOIN %Table:SB1% SB1 ON( SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.%NotDel%)
            JOIN %Table:F2B% F2B ON( F2B.F2B_FILIAL = %xFilial:F2B% AND F2B.F2B_ID = F2D.F2D_IDCAD AND F2B.%NotDel%)            
            %Exp:cJoin%

        WHERE
            %Exp:cFiltro%
    EndSql

    oSection1b:EndQuery()

    oSection2b:SetParentQuery()


    oSection2b:SetParentFilter({|cParam| (ccAlias)->F2B_REGRA + (ccAlias)->FT_TIPOMOV + (ccAlias)->FT_TIPO  == cParam}, {|| (ccAlias)->F2B_REGRA + (ccAlias)->FT_TIPOMOV + (ccAlias)->FT_TIPO })

    TRPosition():New(oSection2b,"SFT",1,{|| xFilial("SFT")+(ccAlias)->FT_TIPOMOV+(ccAlias)->FT_SERIE+(ccAlias)->FT_NFISCAL+(ccAlias)->FT_CLIEFOR+(ccAlias)->FT_LOJA+(ccAlias)->FT_ITEM+(ccAlias)->FT_PRODUTO})


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
@since 25/10/2018
@version P12.1.17

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

//-------------------------------------------------------------------
/*/{Protheus.doc}FSR160OpNf

Função que retornará o texto a ser impresso no cabeçalho do relatório, 
identificando o tipo da nota fiscal.

@author Erick G Dias
@since 25/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSR160OpNf(cTipoMov, cTipo)

Local cRet  := ""

If Empty(cTipo) 

    If cTipoMov == "E"
        cRet    := STR0024 //"Entrada Normal"
    ElseIF cTipoMov == "S"
        cRet    := STR0025 //"Saída Normal"
    EndIF

ElseIF cTipo == "S"

    If cTipoMov == "E"
        cRet    := STR0026 //"Serviço Tomado"
    ElseIF cTipoMov == "S"
        cRet    := STR0027 //"Serviço Prestado"
    EndIF

ElseIF cTipo == "D"

    If cTipoMov == "E"
        cRet    := STR0028 //"Devolução de Venda"
    ElseIF cTipoMov == "S"
        cRet    := STR0029 //"Devolução de Compra"
    EndIF

Else

    If cTipoMov == "E"
        cRet    := STR0030 //"Entrada - "
    ElseIF cTipoMov == "S"
        cRet    := STR0031 //"Saída - "
    EndIF

    If cTipo == "L"
        cRet += STR0032 //"Nota em Lote"
    ElseIf cTipo == "B"
        cRet += STR0033     //"Beneficiamento"
    ElseIf cTipo == "P"
        cRet += STR0034 //"Compl. IPI"
    ElseIf cTipo == "I"
        cRet += STR0035 //"Compl. ICMS"
    ElseIf cTipo == "C"
        cRet += STR0036 //"Complemento"
    Else   
        cRet += cTipo
    EndIF

EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FSR160CF

Função que retornará a razão social e CGC

@author Erich Buttner
@since 31/01/2019
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSR160CF(cTipoMov, cTipo, cCliFor, cLoja,cTpDado)

Local cRet  := ""

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(MsSeek(xFilial("SA1")+cCliFor+cLoja))

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(MsSeek(xFilial("SA2")+cCliFor+cLoja))



If (cTipoMov == "E" .And. cTipo $ "S/L/B/P/I/C/ ") .Or. (cTipoMov == "S" .And. cTipo $ "D")
   cRet    := Iif (cTpDado == "1", SA2->A2_NOME, Iif(SA2->A2_TIPO == "F", TRANSFORM(SA2->A2_CGC,"@R 999.999.999-99"),TRANSFORM(SA2->A2_CGC,"@R! NN.NNN.NNN/NNNN-99") )) //"Entrada Normal"
ElseIF (cTipoMov == "S" .And. cTipo $ "S/L/B/P/I/C/ ") .Or. (cTipoMov == "E" .And. cTipo $ "D")
   cRet    := Iif (cTpDado == "1", SA1->A1_NOME, Iif(SA1->A1_PESSOA == "F", TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99"),TRANSFORM(SA1->A1_CGC,"@R! NN.NNN.NNN/NNNN-99") )) //"Saída Normal"
EndIF

Return cRet
