#INCLUDE "RPTDEF.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE 'GTPR421C.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR421C()
Relatório Composição do espelho do caixa

@sample GTPR421C()

@author jose.darocha
@since 29/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR421C()

	Local oReport
	Local cPerg  	:= 'GTPR421C'
    Local aVisao    := {STR0014,STR0015}    // 'Analitico' 'Sintetico'
    Local cVisao    := ''
    Local aParamBox := {}
    Local aRet      := {}
    Local nMv       := 0
    Local aMvPar    := {}

	If ( !FindFunction("GTPHASACCESS") .Or.; 
		( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

		If Pergunte(cPerg, .T.)
            aadd(aParamBox, {2, STR0016, cVisao, aVisao, 50, ".T.", .F., ".T." })   // 'Visão'
            For nMv := 1 To 40
               aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
            Next nMv
            ParamBox(aParamBox,STR0017,@aRet)   // "Seleção visão"
            For nMv := 1 To Len( aMvPar )
                &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
            Next nMv
            cVisao := Iif(!Empty(aRet),Left(aRet[1],1),'A')
            oReport := ReportDef(cPerg, cVisao)
            FwMsgRun(,{|| oReport:PrintDialog() },, STR0003 )	//Processando
		EndIf 

	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Definição do Relatório 

@sample ReportDef(cPerg)

@param cPerg - caracter - Nome da Pergunta

@return oReport - Objeto - Objeto TREPORT

@author jose.darocha 
@since 29/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg, cVisao)

	Local cTitle      := STR0001    // 'Composição do espelho do caixa'
	Local cHelp       := STR0002    // 'Posição de conta corrente'
	Local cAliasQry   := GetNextAlias()
	Local lEndReport  := .F.
    Local nLeftMargin := 5
    Local nTam        := 0
	Local oReport
	Local oCabec
	Local oSecDetalhe
    Local oSecRodape
	Local oBreak
	Local oFunTot1

	oReport := TReport():New('GTPR421C',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry,cVisao)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,.F./*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
	oReport:SetPortrait(.T.)
	oReport:nFontBody := 5
	oReport:SetTotalInLine(.F.)
    oReport:SetLeftMargin(nLeftMargin)

	oCabec := TRSection():New(oReport, 'CABECALHO', NIL)
	oCabec:SetTotalInLine(.F.)

	TRCell():New(oCabec,"G6X_AGENCI", cAliasQry	,RetTitle('G6X_AGENCI') , /*Picture*/, TamSX3('G6X_AGENCI')[1]/*Tamanho*/   , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,"GI6_DESCRI", cAliasQry	,RetTitle('GI6_DESCRI') , /*Picture*/, TamSX3('GI6_DESCRI')[1]/*Tamanho*/   , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,"G6X_DTINI"	, cAliasQry	,RetTitle('G6X_DTINI')	, /*Picture*/, 20/*Tamanho*/                        , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oCabec,"G6X_DTFIN"	, cAliasQry	,RetTitle('G6X_DTFIN')	, /*Picture*/, 20/*Tamanho*/                        , /*lPixel*/, /*{|| code-block de impressao }*/) 

	oSecDetalhe := TRSection():New(oReport,cTitle,cAliasQry)
	oSecDetalhe:SetTotalInLine(.F.)

	TRCell():New(oSecDetalhe,"GZG_COD"   , cAliasQry	,RetTitle('GZG_COD')    , /*Picture*/, TamSX3('GZG_COD')[1]/*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSecDetalhe,"GZG_DESCRI", cAliasQry	,RetTitle('GZG_DESCRI') , /*Picture*/, TamSX3('GZG_DESCRI')[1]/*Tamanho*/   , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSecDetalhe,"GZG_VALOR" , cAliasQry	,RetTitle('GZG_VALOR')  , /*Picture*/, TamSX3('GZG_VALOR')[1]/*Tamanho*/    , /*lPixel*/, /*{|| code-block de impressao }*/) 

	oSecRodape := TRSection():New(oReport,cTitle,cAliasQry)
	oSecRodape:SetTotalInLine(.F.)

    nTam := TamSX3('GZG_COD')[1] + TamSX3('GZG_DESCRI')[1] + 08
	TRCell():New(oSecRodape , "TXTCOL1" , '' , '', "@!"        , nTam/*Tamanho*/   , /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 
	TRCell():New(oSecRodape , "VLRCOL2" , '' , '', PesqPict("GZG","GZG_VALOR")/*Picture*/ ,TamSX3('GZG_VALOR')[1]/*Tamanho*/      , /*lPixel*/	,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/	,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.) 	 

	oBreak := TRBreak():New(oSecDetalhe,{||(cAliasQry)->GZG_TIPO}, STR0004) // "Total"
	//oBreak := TRBreak():New(oSecDetalhe,{||(cAliasQry)->GZG_TIPO}, {|| GetDescTotal(oSecDetalhe) })
	oBreak:SetPageBreak(.F.)
	oFunTot1 := TRFunction():New(oSecDetalhe:Cell('GZG_VALOR')	, , 'SUM' ,oBreak ,,,,.F.,.T.,.F.,oSecDetalhe,,,)	
	oFunTot1:SetEndReport(lEndReport)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
	   cAliasQry  - Alias  - Nome do Alias para utilização na Query

@author jose.darocha 
@since 29/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry,cVisao)

	Local oSecCabec    := oReport:Section(1)
	Local oSecDetalhe  := oReport:Section(2)
	Local oSecRodape   := oReport:Section(3)
    Local cAgencia     := ''
    Local cNumFech     := ''
    Local cTipo        := ''
    Local aSubTotal    := {}
    Local nCount       := 0
    Local nPos         := 0
    Local nVlrBilhetes := 0
    Local cDtIni       := ''
    Local lImpCabec    := .F.
    Local cCampo       := 'G6X_VLRLIQ'
    Local cExpressao   := ''

    If G6X->(FieldPos('G6X_VLDIFE')) > 0
        cCampo := 'G6X_VLDIFE'
    EndIf 

    cExpressao:= '%' + cCampo + '%'

    Aadd( aSubTotal,{STR0005,0})    //1 'Valor do Saldo da Ficha Anterior'
    Aadd( aSubTotal,{STR0006,0})    //2 'Total de Bilhetes'
    Aadd( aSubTotal,{STR0007,0})    //3 'Total de Receitas'
    Aadd( aSubTotal,{STR0008,0})    //4 'Total de Despesas'
    Aadd( aSubTotal,{STR0009,0})    //5 'Total de Estornos'
    Aadd( aSubTotal,{STR0010,0})    //6 'Total de Depositos'
    Aadd( aSubTotal,{STR0011,0})    //7 'Total Saldo da Ficha Atual'

	oSecDetalhe:BeginQuery()
        BeginSQL Alias cAliasQry
            Select
                G6X_AGENCI,
                GI6_DESCRI,
                G6X_NUMFCH,
                G6X_DTINI,
                G6X_DTFIN,
                G6X_VLRREI,
                G6X_VLTOES,
                G6X_VLTODE,
                GZG_SEQ,
                GZG_TIPO,
                GZG_COD,
                GZG_DESCRI,
                GZG_VALOR,
                %Exp:cExpressao%
            From
                %table:G6X% G6X
            Left Join 
                %table:GZG% GZG on GZG_FILIAL = %xFilial:GZG% and GZG_AGENCI = G6X_AGENCI and GZG_NUMFCH = G6X_NUMFCH and GZG.%NotDel%
            Inner Join
                %table:GI6% GI6 on GI6_FILIAL = %xFilial:GI6% and GI6_CODIGO = G6X_AGENCI and GI6.%NotDel%
            Where
                    G6X_FILIAL = %xFilial:G6X%
                and G6X_AGENCI between %Exp:Mv_par01% and %Exp:Mv_par02%
                and G6X_DTINI between %Exp:Dtos(Mv_par03)% and %Exp:Dtos(Mv_par04)%    
                and G6X.%NotDel%
            Order by G6X_AGENCI,G6X_NUMFCH,GZG_TIPO,GZG_SEQ
        EndSql
	oSecDetalhe:EndQuery()
	
	oReport:SetMeter((cAliasQry)->(RecCount()))
	
	While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())
        
		oReport:StartPage()

		oSecCabec:Init()
		oSecCabec:PrintLine()	

        cAgencia     := (cAliasQry)->G6X_AGENCI
        cNumFech     := (cAliasQry)->G6X_NUMFCH
        cTipo        := (cAliasQry)->GZG_TIPO
        cDtIni       := Dtos((cAliasQry)->G6X_DTINI)
        nVlrBilhetes := (cAliasQry)->G6X_VLRREI
        lImpCabec    := .T.

        //Atualiza o saldo anterior
        aSubTotal[1][2] := GetVlrSld(cAgencia, cNumFech, cDtIni)

        //Atualiza o valor de Estorno
        aSubTotal[5][2] := (cAliasQry)->G6X_VLTOES
        
        //Atualiza o valor de deposito
        aSubTotal[6][2] := (cAliasQry)->G6X_VLTODE

        //Atualiza o Saldo Atual
        aSubTotal[7][2] := (cAliasQry)->&cCampo

        WHILE !oReport:Cancel() .AND. (cAliasQry)->(!Eof())	.And. cAgencia == (cAliasQry)->G6X_AGENCI .And. cNumFech == (cAliasQry)->G6X_NUMFCH

            If !Empty(cTipo)

                //Sub Total Receita / Despesa
                nPos := Iif((cAliasQry)->GZG_TIPO=='1',3,4)
                aSubTotal[nPos][2] += (cAliasQry)->GZG_VALOR

                If cVisao == 'A'    // Analitico
                    If lImpCabec
                        lImpCabec := .F.
                        oSecDetalhe:Init()
                        oReport:SkipLine(1)
                        oReport:PrtLeft(Iif(cTipo == '1',STR0012,STR0013))  // 'RECEITA' 'DESPESA'
                    EndIf 

                    If cTipo <> (cAliasQry)->GZG_TIPO
                        cTipo := (cAliasQry)->GZG_TIPO
                        oSecDetalhe:Finish()
                        oSecDetalhe:Init()
                        oReport:SkipLine(1)
                        oReport:PrtLeft(Iif(cTipo == '1',STR0012,STR0013))    // 'RECEITA' 'DESPESA'
                    EndIf 

                    oSecDetalhe:PrintLine()
                EndIf 

            EndIf

            (cAliasQry)->(DbSkip())  
            
        EndDo 

        //Atualiza valor dos bilhetes
        aSubTotal[2][2] := nVlrBilhetes - aSubTotal[3][2]

        If cVisao == 'A'    // Analitico        
            oSecDetalhe:Finish()
            oSecCabec:Finish()
        EndIf 

		oSecRodape:Init()
        For nCount:=1 To Len( aSubTotal )
            oSecRodape:Cell("TXTCOL1"):SetValue(aSubTotal[nCount][1])
            oSecRodape:Cell("VLRCOL2"):SetValue(aSubTotal[nCount][2])
            oSecRodape:PrintLine()	
        Next nCount            
		oSecRodape:Finish()	

		oReport:EndPage()	  

        //Zera o valor do subtotal da Agencia Atual
        aEval( aSubTotal,{|e| e[2]:= 0} )
        nVlrBilhetes := 0

   EndDo 
   
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlrSld(cAgencia, cNumFch)

Função retorno de saldo da Ficha de Remessa

@author jose.darocha 
@since 29/07/2025
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetVlrSld(cAgencia, cNumFch, cDataIni)
    Local nValor    := 0
    Local aAreaAtu  := GetArea()
    Local cAliasQry := GetNextAlias()
    Local cCampo    := 'G6X_VLRLIQ'
    Local cExpressao:= ''

    If G6X->(FieldPos('G6X_VLDIFE')) > 0
        cCampo := 'G6X_VLDIFE'
    EndIf 

    cExpressao:= '%' + cCampo + '%'

    BeginSql Alias cAliasQry
        Select %Exp:cExpressao%
        From %Table:G6X% G6X
        Where G6X.G6X_FILIAL = %xFilial:G6X% and G6X.G6X_AGENCI = %Exp:cAgencia%
        and G6X.G6X_NUMFCH = ( 
                                Select MAX(G6X_NUMFCH) G6X_NUMFCH 
                                From %Table:G6X% J
                                Where   J.G6X_FILIAL = %xFilial:G6X% 
                                    and J.G6X_AGENCI = %Exp:cAgencia% 
                                    and J.G6X_DTINI < %Exp:cDataIni%
                                    and J.%NotDel% 
                            )
        and G6X.%NotDel%
    EndSql 
    If (cAliasQry)->(!Eof())
        nValor := (cAliasQry)->&cCampo
    EndIf 
    (cAliasQry)->(DbCloseArea())
    RestArea( aAreaAtu )
Return nValor
