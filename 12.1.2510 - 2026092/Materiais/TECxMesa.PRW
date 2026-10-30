#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc}

Função de query Principal para retornos nos filtros em PO UI - Mesa Operacional

@Param      oParamBody -> Objeto BODY JSON da seleção dos filtros
            cMetodo    -> Metodo para formação do select da query

@Return     cAliasTmp  -> Alias contendo a resposta da Query

@author     Maratona Serviços - Mesa Operacional PO UI
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
Function qryFormer(oParamBody, cMetodo)
Local cAliasTmp     := GetNextAlias()
Local cIn           := ""
Local cInnerArea    := ""
Local cInnerBusca   := ""
Local cJoinABS      := ""
Local cJoinTFJ      := ""
Local cJoinTFL      := ""
Local cJoinTFF      := ""
Local cJoinSA1      := ""
Local cJoinABQ      := ""
Local cJoinABB      := ""
Local cJoinAA1      := ""
Local cJoinTDW      := ""
Local cJoinTGY      := ""
Local cSelect       := ""
Local cWhereCN9     := ""
Local cDataIni      := ""
Local cDataFim      := ""
Local aAreas        := {}
Local aClientes     := {}
Local aContratos    := {}
Local aLocais       := {}
Local aPostos       := {}
Local lMultFil      := IsMultFil()

//Inicializa parametros do Body JSON passado do Front:
cFilTMP     := oParamBody['filial']
aAreas      := oParamBody['area']
aClientes   := oParamBody['cliente']
aContratos  := oParamBody['contrato']
aLocais     := oParamBody['local']
aPostos     := oParamBody['posto']
cDataIni    := oParamBody['dataIni']
cDataFim    := oParamBody['dataFim']

//Definição do Select de acordo com método (cMetodo)
If cMetodo == "area"
    cSelect := "% AB.ABS_CODSUP, TGS.TGS_DESCRI %"

ElseIf cMetodo == "cliente"
    cSelect := "% TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME %"

    //Composição do Where: FILIAL+AREAS
    cIn  := whereSQL("AREA", aAreas)

ElseIf cMetodo == "contrato"
    cSelect := "% TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV %"

    //Composição do Where: FILIAL+AREAS+CLIENTES
    cIn  := whereSQL("AREA", aAreas) + ;
            whereSQL("CLIENTE", aClientes)

ElseIf cMetodo == "localidade"
    cSelect := "% AB.ABS_LOCAL, AB.ABS_DESCRI, ABS_FILCC, ABS_CCUSTO %"

    //Composição do Where: FILIAL+AREAS+CLIENTES+CONTRATOS
    cIn  := whereSQL("AREA", aAreas) + ;
            whereSQL("CLIENTE", aClientes) + ;
            whereSQL("CONTRATO", aContratos)

ElseIf cMetodo == "posto"
    cSelect := "% TFF.TFF_COD, TFF.TFF_PRODUT, SB1.B1_DESC %"

    //Composição do Where: FILIAL+AREAS+CLIENTES+CONTRATOS+LOCAIS
    cIn  := whereSQL("AREA", aAreas) +;
            whereSQL("CLIENTE", aClientes) +;
            whereSQL("CONTRATO", aContratos) +;
            whereSQL("LOCAL", aLocais)

ElseIf cMetodo == "busca"
    cSelect := "% AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_CDFUNC, "+; //Funcionário
                "TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME, "+;       //Cliente
                "TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, "+;                  //Contrato
                "TFF.TFF_COD, TFF.TFF_PRODUT, TFF.TFF_ESCALA, SB1.B1_DESC, TFF.TFF_FUNCAO, TFF.TFF_QTPREV, "+; //Posto
                "TDW.TDW_DESC, TGY.TGY_SEQ, TFL.TFL_LOCAL %" //Descrição da escala

    //Composição do Where: FILIAL+AREAS+CLIENTES+CONTRATOS+LOCAIS+POSTOS
    cIn  := whereSQL("AREA", aAreas) + ;
            whereSQL("CLIENTE", aClientes) + ;
            whereSQL("CONTRATO", aContratos) + ;
            whereSQL("LOCAL", aLocais) + ;
            whereSQL("POSTO", aPostos) + ;
            ' AND ABB.ABB_DTINI >= ' + cDataIni + ;
            ' AND ABB.ABB_DTINI <= ' + cDataFim
EndIf

//Compõe Join/Where de acordo com multifilial ou não:
cJoinABS  := JoinSQL(lMultFil, "AB.ABS_FILIAL", "TFL", "ABS", cFilTMP, "JOIN")
cJoinTFJ  := JoinSQL(lMultFil, "TFJ.TFJ_FILIAL", "CN9", "TFJ", cFilTMP, "JOIN")
cJoinTFL  := JoinSQL(lMultFil, "TFL.TFL_FILIAL", "TFJ", "TFL", cFilTMP, "JOIN")
cJoinTFF  := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFL", "TFF", cFilTMP, "JOIN")
cJoinSA1  := JoinSQL(lMultFil, "SA1.A1_FILIAL" , "TFJ", "SA1", cFilTMP, "JOIN")
cJoinSB1  := JoinSQL(lMultFil, "SB1.B1_FILIAL" , "TFF", "SB1", cFilTMP, "JOIN")
cJoinTGS  := JoinSQL(lMultFil, "TGS.TGS_FILIAL", "ABS", "TGS", cFilTMP, "JOIN")
cJoinABQ  := JoinSQL(lMultFil, "ABQ.ABQ_FILIAL", "TFF", "ABQ", cFilTMP, "JOIN")
cJoinABB  := JoinSQL(lMultFil, "ABB.ABB_FILIAL", "TFF", "ABB", cFilTMP, "JOIN")
cJoinAA1  := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "ABB", "AA1", cFilTMP, "JOIN")
cJoinTDW  := JoinSQL(lMultFil, "TDW.TDW_FILIAL", "TFF", "TDW", cFilTMP, "JOIN")
cJoinTGY  := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TFF", "TGY", cFilTMP, "JOIN")
cWhereCN9 := JoinSQL(lMultFil, "CN9.CN9_FILIAL", "CN9", "CN9", cFilTMP, "WHERE")

//Compõe INNER JOIN de AREAS apenas se for selecionado alguma no Filtro:
If !Empty(aAreas) .Or. cMetodo == "area"
    cInnerArea := "INNER JOIN " + RetSqlName("TGS") + " TGS " +;
                    " ON "+ StrTran(cJoinTGS,'%','') +;
                    " AND TGS.TGS_COD = AB.ABS_CODSUP " +;
                    " AND TGS.D_E_L_E_T_ = ' ' "
EndIF

//Compõe INNER JOIN de BUSCA apenas método de busca:
If cMetodo == "busca"
    cInnerBusca := "INNER JOIN " + RetSqlName("ABQ") + " ABQ " +;
                    " ON "+ StrTran(cJoinABQ,'%','') +;
                    " AND ABQ.ABQ_CODTFF = TFF.TFF_COD " +;
                    " AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL " +;
                    " AND ABQ.D_E_L_E_T_ = ' ' "

    cInnerBusca += "INNER JOIN " + RetSqlName("ABB") + " ABB " +;
                    " ON "+ StrTran(cJoinABB,'%','') +;
                    " AND ABB.ABB_IDCFAL = CN9.CN9_NUMERO || ABQ.ABQ_ITEM || 'CN9' " +;
                    " AND ABB.D_E_L_E_T_ = ' ' "

    cInnerBusca += "INNER JOIN " + RetSqlName("AA1") + " AA1 " +;
                    " ON "+ StrTran(cJoinAA1,'%','') +;
                    " AND AA1.AA1_CODTEC = ABB.ABB_CODTEC " +;
                    " AND AA1.D_E_L_E_T_ = ' ' "

    cInnerBusca += "INNER JOIN " + RetSqlName("TDW") + " TDW " +;
                    " ON "+ StrTran(cJoinTDW,'%','') +;
                    " AND TDW.TDW_COD = TFF.TFF_ESCALA " +;
                    " AND TDW.D_E_L_E_T_ = ' ' "
                    
    cInnerBusca += "INNER JOIN " + RetSqlName("TGY") + " TGY " +;
                    " ON "+ StrTran(cJoinTGY,'%','') +;
                    " AND TGY.TGY_ESCALA = TFF.TFF_ESCALA " +;
                    " AND TGY.TGY_ATEND = AA1.AA1_CODTEC " +;
                    " AND TGY.TGY_CODTFF = TFF.TFF_COD " +;
                    " AND TGY.D_E_L_E_T_ = ' ' "
EndIF

//Adição de % começo e fim
cIn  := sqlEmbeded(cIn)
cInnerArea := sqlEmbeded(cInnerArea)
cInnerBusca := sqlEmbeded(cInnerBusca)

BeginSql Alias cAliasTmp
    SELECT DISTINCT %exp:cSelect%
    FROM %table:CN9% CN9
        INNER JOIN %table:TFJ% TFJ //Contrato
            ON %exp:cJoinTFJ%
            AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO
            AND TFJ.TFJ_CONREV = CN9.CN9_REVISA
            AND TFJ.TFJ_STATUS = '1'
            AND TFJ.%NotDel%
        INNER JOIN %table:TFL% TFL //Local - Contrato
            ON %exp:cJoinTFL%
            AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO 
            AND TFL.%NotDel%
        INNER JOIN %table:ABS% AB //Local - Cadastro
            ON %exp:cJoinABS%
            AND AB.ABS_LOCAL = TFL.TFL_LOCAL 
            AND AB.%NotDel%
        INNER JOIN %table:TFF% TFF //Posto - Contrato
            ON %exp:cJoinTFF%
	        AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
            AND TFF.%NotDel% 
        INNER JOIN %table:SA1% SA1 //Clientes
            ON %exp:cJoinSA1%
	        AND SA1.A1_COD = TFJ.TFJ_CODENT
	        AND SA1.A1_LOJA = TFJ.TFJ_LOJA
            AND SA1.%NotDel%
            %exp:cInnerBusca%
        INNER JOIN %table:SB1% SB1 //Produtos
            ON %exp:cJoinSB1%
	        AND SB1.B1_COD = TFF.TFF_PRODUT
            AND SB1.%NotDel%
            %exp:cInnerArea%
    WHERE %exp:cWhereCN9%
            AND CN9.CN9_SITUAC = '05'
            AND CN9.%NotDel%
            %Exp:cIn%
EndSql

Return (cAliasTmp)

//------------------------------------------------------------------------------
/*/{Protheus.doc}

Função que verifica se é Multifilial (Parametro + Permissão de usuário)

@Return     lRet  -> Se parametro ativo e usuário com permissão retorna True.

@author     Maratona Serviços - Mesa Operacional PO UI
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
Function isMultFil()
Local lRet := .F.

If SuperGetMV("MV_GSMSFIL",,.F.) .AND. At680Perm(NIL, __cUserId, "043", .T.)
    lRet := .T.
EndIf

Return (lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc}

Monta a condição WHERE de acordo com o metodo de filtro

@Param      cTipo  -> Método: "AREA" | "CLIENTE" | "CONTRATO" | "LOCAL" | "POSTO"
            aArray -> Array do objeto JSON com os selecionados no Filtro 

@Return     cSqlIN -> String para compor o Where na query principal

@author     Jack Junior
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
Function whereSQL(cTipo, aArray)
Local nX := 0
Local cSqlIN := ""

Default aArray := {}

If cTipo == "AREA"
    For nX := 1 To Len(aArray)
        cSqlIN += "'" + aArray[nX]['value']+ "'," //cód. area
    Next nX

    If !Empty(cSqlIN)
        cSqlIN := Left(cSqlIN, Len(cSqlIN)-1) //Remove ultima virgula
        If Len(aArray) > 1
            cSqlIN := " AND AB.ABS_CODSUP IN("+cSqlIN+")"
        Else
            cSqlIN := " AND AB.ABS_CODSUP = " + cSqlIN
        EndIF
    EndIf

ElseIf cTipo == "CLIENTE"
    For nX := 1 To Len(aArray)
        cSqlIN += "'" + aArray[nX]['value'] + "'," //Cliente+Loja
    Next nX

    If !Empty(cSqlIN)
        cSqlIN := Left(cSqlIN, Len(cSqlIN)-1) //Remove ultima virgula
        If Len(aArray) > 1
            cSqlIN := " AND TFJ.TFJ_CODENT+TFJ.TFJ_LOJA IN("+cSqlIN+")"
        Else
            cSqlIN := " AND TFJ.TFJ_CODENT+TFJ.TFJ_LOJA = " + cSqlIN
        EndIF
    EndIf

ElseIf cTipo == "CONTRATO"
    For nX := 1 To Len(aArray)
        cSqlIN += "'" + aArray[nX]['value'] + "'," //Contrato+Revisao
    Next nX

    If !Empty(cSqlIN)
        cSqlIN := Left(cSqlIN, Len(cSqlIN)-1) //Remove ultima virgula
        If Len(aArray) > 1
            cSqlIN := " AND TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV IN("+cSqlIN+")"
        Else
            cSqlIN := " AND TFJ.TFJ_CONTRT+TFJ.TFJ_CONREV = " + cSqlIN
        EndIF
    EndIf

ElseIf cTipo == "LOCAL"
    For nX := 1 To Len(aArray)
        cSqlIN += "'" + aArray[nX]['value']+ "'," //cód. local
    Next nX

    If !Empty(cSqlIN)
        cSqlIN := Left(cSqlIN, Len(cSqlIN)-1) //Remove ultima virgula
        If Len(aArray) > 1
            cSqlIN := " AND AB.ABS_LOCAL IN("+cSqlIN+")"
        Else
            cSqlIN := " AND AB.ABS_LOCAL = " + cSqlIN
        EndIF
    EndIf

ElseIf cTipo == "POSTO"
    For nX := 1 To Len(aArray)
        cSqlIN += "'" + aArray[nX]['value']+ "'," //cód. TFF
    Next nX

    If !Empty(cSqlIN)
        cSqlIN := Left(cSqlIN, Len(cSqlIN)-1) //Remove ultima virgula
        If Len(aArray) > 1
            cSqlIN := " AND TFF.TFF_COD IN("+cSqlIN+")"
        Else
            cSqlIN := " AND TFF.TFF_COD = " + cSqlIN
        EndIF
    EndIf

ElseIf cTipo == "BASE"
    For nX := 1 To Len(aArray)
        cSqlIN += "'" + aArray[nX]['value']+ "'," //cód. Base Operacional
    Next nX

    If !Empty(cSqlIN)
        cSqlIN := Left(cSqlIN, Len(cSqlIN)-1) //Remove ultima virgula
        If Len(aArray) > 1
            cSqlIN := " AND AA0.AA0_CODIGO IN("+cSqlIN+")"
        Else
            cSqlIN := " AND AA0.AA0_CODIGO = " + cSqlIN
        EndIF
    EndIf
EndIf

Return (cSqlIN)

//------------------------------------------------------------------------------
/*/{Protheus.doc}

Monta o JOIN ou WHERE de acordo com MULTIFILIAL

@Param      cCampo  -> Campo filial
            cTab1   -> Alias da primeira tabela
            cTab2   -> Alias da segunda tabela
            cFilTMP -> Filial selecionada no primeiro filtro da tela
            cTipo   -> Tipo "JOIN" ou "WHERE" para composição da string

@Return     cString -> Alias contendo a resposta da Query

@author     Jack Junior
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
Function JoinSQL(lMultFil, cCampo, cTab1, cTab2, cFilTMP, cTipo)
Local cString := ""

If lMultFil
    If cTipo == "JOIN"
        cString := FWJoinFilial(cTab1,;
                                cTab2,;
                                IIF(cTab1 == "ABS", Left(cTab1, 2), cTab1),;
                                IIF(cTab2 == "ABS", Left(cTab2, 2), cTab2),;
                                .T.)
    ElseIf cTipo == "WHERE"
        cString := cCampo + " = '" + xFilial(cTab1, cFilTMP) + "'"
    EndIf
Else
    cString := cCampo + " = '" + xFilial(cTab2) + "'"
EndIf

cString := sqlEmbeded(cString)

Return (cString)

//------------------------------------------------------------------------------
/*/{Protheus.doc}

Ajusta % no começo e fim da String para query Embedded

@Param      cString  -> String para adição dos %'s

@Return     cString -> "% " + cString + " %"

@author     Maratona Serviços - Mesa Operacional PO UI
@since      01/09/2023
/*/
//------------------------------------------------------------------------------
Function sqlEmbeded(cString)

cString := "% " + cString + " %"

Return (cString)

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteABR()

Verifica se uma determina ABB possui uma ABR

@author Jack Junior
@since 14/11/2023
/*/
//------------------------------------------------------------------
Function ExisteABR(cCodABB, cFilAg)
Local lRet := .F.
Local cQry := GetNextAlias()
Local cXfilAbb
Default cFilAg := cFilAnt

cXfilAbb := xFilial("ABB",cFilAg)

If !Empty(cCodABB)
	BeginSQL Alias cQry
		SELECT 1 REC
		  FROM %Table:ABR% ABR
		 WHERE ABR.ABR_FILIAL = %Exp:cXfilAbb%
		   AND ABR.%NotDel%
		   AND ABR.ABR_AGENDA = %Exp:cCodABB%
	EndSQL

	lRet := (cQry)->(!Eof())
	(cQry)->(DbCloseArea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdTGY()

Verifica a quantidade de TGYs unicas para um certo Posto

@author Jack Junior
@since 17/11/2023
/*/
//------------------------------------------------------------------
Function QtdTGY(cFilTMP, cCodTFF, cDataIni, cDataFim)
Local cQry      := GetNextAlias()
Local cWhereTGY := ""
Local nTGY      := 0
Local lMultFil  := IsMultFil()

cWhereTGY := JoinSQL(lMultFil, "TGY.TGY_FILIAL", "TGY", "TGY", cFilTMP, "WHERE")

If !Empty(cCodTFF) .And. !Empty(cDataIni) .And. !Empty(cDataFim)
	BeginSQL Alias cQry
		SELECT COUNT(TGY_CODTFF) QTD_TGY
		  FROM %Table:TGY% TGY
		 WHERE %exp:cWhereTGY% 
            AND TGY.TGY_CODTFF = %exp:cCodTFF%
            AND TGY.TGY_DTINI <= %exp:cDataFim% AND TGY.TGY_DTFIM >= %exp:cDataIni%
            AND TGY.%NotDel%
	EndSQL

	If (cQry)->(!Eof())
        nTGY := (cQry)->QTD_TGY
    EndIf

	(cQry)->(DbCloseArea())
EndIf

Return nTGY

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdTGY()

Verifica se existe alguma manutenção sem substituto no posto (inconsistencia)

@author Jack junior
@since 20/11/2023
/*/
//------------------------------------------------------------------
Function ExistIncon(cFilTMP, cCodCN9, cCodTFF, cDataIni, cDataFim)
Local cQry      := GetNextAlias()
Local lRet      := .F.
Local cJoinABQ  := ""
Local cJoinABB  := ""
Local cJoinABR  := ""
Local cWhereTFF := ""
Local lMultFil  := IsMultFil()

cJoinABQ := JoinSQL(lMultFil, "ABQ.ABQ_FILIAL", "TFF", "ABQ", cFilTMP, "WHERE")
cJoinABB := JoinSQL(lMultFil, "ABB.ABB_FILIAL", "ABQ", "ABB", cFilTMP, "WHERE")
cJoinABR := JoinSQL(lMultFil, "ABR.ABR_FILIAL", "ABB", "ABR", cFilTMP, "WHERE")
cWhereTFF := JoinSQL(lMultFil, "TFF.TFF_FILIAL", "TFF", "TFF", cFilTMP, "WHERE")

If !Empty(cCodCN9) .And. !Empty(cCodTFF) .And. !Empty(cDataIni) .And. !Empty(cDataFim)
	BeginSQL Alias cQry
		SELECT 1
        FROM %Table:TFF% TFF
            INNER JOIN %Table:ABQ% ABQ
                ON (%exp:cJoinABQ%
                    AND ABQ.ABQ_CODTFF = TFF.TFF_COD
                    AND ABQ.ABQ_FILTFF = TFF.TFF_FILIAL
                    AND ABQ.%NotDel%)
            INNER JOIN %Table:ABB% ABB
                ON (%exp:cJoinABB%
                    AND ABB.ABB_IDCFAL = %exp:cCodCN9% || ABQ.ABQ_ITEM || 'CN9'
                    AND ABB.%NotDel%)
            INNER JOIN %Table:ABR% ABR
                ON (%exp:cJoinABR%
                    AND ABR.ABR_AGENDA = ABB.ABB_CODIGO
                    AND ABR.%NotDel%)
        WHERE %exp:cWhereTFF% 
            AND TFF.TFF_COD = %exp:cCodTFF%
            AND ABB.ABB_DTINI >= %exp:cDataIni% 
            AND ABB.ABB_DTINI <= %exp:cDataFim%
            AND ABR.ABR_CODSUB = ' '
            AND TFF.%NotDel%
	EndSQL

	If (cQry)->(!Eof())
        lRet := .T.
    EndIf

	(cQry)->(DbCloseArea())
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} mesaxBenef
	Retorna array com descrição e valor de um benefício a depender de seu tipo.
@author		Jack Junior
@since		21/11/2023
/*/
//-------------------------------------------------------------------------------
Function mesaxBenef(cChave,cTipoBen)
Local aRet 		:= {}
Local aArea 	:= {}
Default cChave	:= ""
Default cTipoBen := ""

If !Empty(cChave)
	aArea := GetArea()
	cChave := AllTrim(cChave)
	If cTipoBen == "VR"
		//1=Vale Refeicao;2=Vale Alimentacao
        AADD(aRet, {Fdesc("RFO", "1"+cChave, "RFO_DESCR"),;
                    Fdesc("RFO", "1"+cChave, "RFO_VALOR")})
	ElseIf cTipoBen == "VA"
		//1=Vale Refeicao;2=Vale Alimentacao
        AADD(aRet, {Fdesc("RFO", "2"+cChave, "RFO_DESCR"),;
                    Fdesc("RFO", "2"+cChave, "RFO_VALOR")})	
    ElseIf cTipoBen == "PS"
        AADD(aRet, {Fdesc("SG0", cChave, "G0_DESCR")})
	Else
        AADD(aRet, {Fdesc("RIS", cTipoBen+cChave, "RIS_DESC"),;
                    Fdesc("RIS", cTipoBen+cChave, "RIS_REF")})
	EndIf
	RestArea(aArea)
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} projSemana
	Projeta os dias da semana de uma agenda de acordo com a escala e sequencia
@author		Jack junior
@since		22/11/2023
/*/
//-------------------------------------------------------------------------------
Function projSemana(cFilTMP, cEscala, cSeq)
Local aHorario  := {}
Local aRet      := {}
Local cQry      := GetNextAlias()
Local cStatus   := ""
Local cTurno    := ""
Local cWhereTDX := ""
Local nX        := 0
Local lMultFil  := IsMultFil()

// Busca Conf Aloc
cWhereTDX := JoinSQL(lMultFil, "TDX.TDX_FILIAL", "TDX", "TDX", cFilTMP, "WHERE")

BeginSQL Alias cQry
	SELECT COALESCE(TDX.TDX_TURNO,' ') TURNO
	FROM %Table:TDX% TDX
	WHERE %Exp:cWhereTDX%
		AND TDX.TDX_CODTDW = %Exp:cEscala%
		AND TDX.TDX_SEQTUR = %Exp:cSeq%
		AND TDX.%NotDel%
EndSql

cTurno := (cQry)->(TURNO)
(cQry)->(DbCloseArea())

aHorario := RetHorTur( cTurno, cSeq )

For nX := 1 To Len(aHorario)
    If aHorario[nX,4] <> "3"
        cDoW := EncodeUtf8(TECCdow(Val(aHorario[nX,1])))
        nPos := aScan(aRet,{|x|x[1]==cDoW})
        If nPos == 0
            If aHorario[nX,4] == "1"
                cStatus := "Trabalha"
            Else
                cStatus := "Folga"
            EndIf
            aAdd(aRet,Array(4))
            nPos := Len(aRet)
            aRet[nPos,1] := cDoW
            aRet[nPos,2] := StrZero(Int(aHorario[nX,2]),2)+":"+StrZero(aHorario[nX,2]-Int(aHorario[nX,2]),2)
            aRet[nPos,4] := cStatus
        EndIf
        aRet[nPos,3] := StrZero(Int(aHorario[nX,3]),2)+":"+StrZero(aHorario[nX,3]-Int(aHorario[nX,3]),2)
    EndIf
Next nX

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetHorTur()

Retorna todos os periodos e intervalos da tabela de horario padrao

@param      cTurno, String, turno qual devera ser localizado a tabela
@param      cSequencia, String, sequencia do turno que devera ser localizado a tabela

@author Serviços
@since 16/11/2023
/*/
//------------------------------------------------------------------
Function RetHorTur( cTurno, cSequencia )
Local aRet      := {}
Local aDomingo  := {}
Local aArea     := GetArea()
Local nI        := 0

dbSelectArea("SPJ")
SPJ->(dbSetOrder(1)) // PJ_FILIAL+PJ_TURNO+PJ_SEMANA

If SPJ->(dbSeek(xFilial("SPJ")+cTurno+cSequencia))
    While SPJ->(!Eof()) .And. SPJ->PJ_TURNO == cTurno .And. ;
            SPJ->PJ_SEMANA == cSequencia
            If SPJ->PJ_DIA == "1" // Domingo
                aAdd( aDomingo, SPJ->(Recno()) )
                SPJ->(dbSkip())
                Loop
            EndIf
            At580IntHor( @aRet )
        SPJ->(dbSkip())
    EndDo
EndIf

// Adiciona o domingo na ultima posição
If Len(aDomingo) > 0
    For nI:=1 To Len(aDomingo)
        SPJ->(dbGoTo(aDomingo[nI]))
        At580IntHor( @aRet )
    Next nI
EndIf

RestArea( aArea )
Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TabelaS011()

Retorna array contendo as informações da S011 do RH.

@author Serviços
@since 01/02/2024
/*/
//------------------------------------------------------------------

Function TabelaS011()
Local aRet 	:= {}
Local aBen 	:= {}
Local nI	:= 1
Local aTb11	:= {}

aadd(aBen,{"VR","Vale Refeição"})//"Vale Refeição"
aadd(aBen,{"VA","Vale Alimentação"})//"Vale Alimentação"
aadd(aBen,{"PS","Plano de Saude"})//"Plano de Saude"

For nI := 1 To Len(aBen)
	aadd(aRet,{1,1})
	aRet[nI][1]	:= 1
	aRet[nI][2]	:= {aBen[nI][1],aBen[nI][2]}
Next nI

fCarrTab(@aTb11,"S011" )
fVerVinc(@aTb11)

For nI := 1 To Len(aTb11)
	aadd(aRet,{1,1})
	aRet[len(aRet)][1]	:= 1
	aRet[len(aRet)][2]	:= {aTb11[nI][5],aTb11[nI][6]}
Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DescBenS011()

Retorna descrição do tipo de benefício proveniente da S011. 

@Param cChave    -> Chave do tipo de benefício (LY_TIPO)
       aArrayS011-> Array com dados da S011 do RH.

@author Serviços
@since 01/02/2024
/*/
//------------------------------------------------------------------

Function DescBenS011(cChave,aArrayS011)
Local nPos		:= 0
Local cRet		:= "" 

If !Empty(cChave)
	nPos := ascan(aArrayS011,{|x| x[2][1] == cChave})
Endif
	
If nPos > 0
	cRet := AllTrim(aArrayS011[nPos][2][2])
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MascReais()

Retorna valor com máscara de valor em Reais, ex: R$ 20,00

@Param nValor -> Valor NUMÉRICO a ser utilizado na máscara

@author Serviços
@since 01/02/2024
/*/
//------------------------------------------------------------------

Function MascReais(nValor)

cReal := "R$ " + allTrim(str(nValor, ,2))

Return cReal

//------------------------------------------------------------------------------
/*/{Protheus.doc} MesaManType

@description Retorna os tipos de manutenção permitidos de acordo com as 
agendas selecionadas.

@author	Serviços
@since	19/04/2024
/*/
//------------------------------------------------------------------------------
Function MesaManType(aMarks)
Local aRet := {'01',;	//FALTA
				'02',;	//ATRASO
				'03',;	//SAIDA ANTECIPADA
				'04',;	//HORA EXTRA
				'05',;	//CANCELAMENTO DE AGENDA
				'',;	//TRANSFERENCIA - [Descontinuado]
				'',;	//AUSENCIA - [Descontinuado]
				'08',;	//REALOCAÇÃO
				'09',;	//COMPENSAÇÃO
				'10'}	//RECICLAGEM
Local aRet2 := {}
Local aInfo := {}
Local nX
Local nY
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cFil1 := ""
Local lContinua := .T.
Local nContPer	:= 0
Local nContReg	:= 0

aRet[09] := "" //Compensação

If lMV_MultFil
	For nX := 1 To LEN(aMarks)
		If !EMPTY(aMarks[nX][1])
			If Empty(cFil1)
				cFil1 := aMarks[nX][12]
			ElseIf cFil1 != aMarks[nX][12]
				lContinua := .F.
			EndIf
		EndIf
	Next nX
EndIf
If lContinua
	For nX := 1 To LEN(aMarks)
		If !EMPTY(aMarks[nX][1])
			If Empty(aInfo)
				AADD(aInfo, {aMarks[nX][2],; //ABB_DTINI
							aMarks[nX][3],; //ABB_HRINI
							aMarks[nX][4],; //ABB_DTFIM
							aMarks[nX][5]}) //ABB_HRFIM
			Else
				For nY := 1 To LEN(aInfo)
                    //Tira atraso:
					If HrsToVal(aInfo[nY][2]) != HrsToVal(aMarks[nX][3])
						aRet[2] := ""
						aRet[7] := ""
						aRet[4] := "" 
					EndIf
                    //Tira Saída antecipada:
					If HrsToVal(aInfo[nY][4]) != HrsToVal(aMarks[nX][5])
						aRet[3] := ""
						aRet[7] := ""
						aRet[4] := ""
					EndIf	
					// Treinamento
					If 	(aInfo[nY][1] = aMarks[nX][2]) .And.;
						(aInfo[nY][3] = aMarks[nX][4]) 
						nContPer++
					EndIf
				Next nY  
				AADD(aInfo, {aMarks[nX][2],; //ABB_DTINI
							aMarks[nX][3],; //ABB_HRINI
							aMarks[nX][4],; //ABB_DTFIM
							aMarks[nX][5]}) //ABB_HRFIM 
			EndIf
			nContReg++ 
		EndIf 
	Next nX
Else
	For Nx := 1 To LEN(aRet)
		aRet[nX] := ""
	Next Nx
EndIf

//Para Postos LIberados, somente o tipo Cancelamento pode ser realizado, os outros tipos são Limpos
If TecAgPstLib(aMarks)
	For nY := 1 To Len(aRet)
		If nY <> 5
			aRet[nY] := "" 
		EndIf 
	Next nY
EndIf 

If Len(aMarks) == 1 
	aRet[10] := "" 
ElseIf nContPer == 0
	aRet[10] := "" 
ElseIf nContReg / 2 == nContPer 
	aRet[10] := "10" //Treinamento
    aRet[09] := "09" //Compensação
Else 
	aRet[10] := "" 
EndIf

For nY := 1 TO LEN(aRet)
	If !EMPTY(aRet[nY])
		AADD(aRet2, aRet[nY])
	EndIF
Next nY

Return {aRet2, lContinua}

//------------------------------------------------------------------------------
/*/{Protheus.doc} HrsToVal

@description Converte uma String em formato de horário em um valor numérico

@author	Serviços
@since	07/06/2019
/*/
//------------------------------------------------------------------------------
Static Function HrsToVal(cHora)

Return VAL(STRTRAN(cHora,":"))

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtDescCbox

@description Retorna a descrição de um combo box de acordo com a chave e campo

@author	Jack Junior
@since	27/05/2024
/*/
//------------------------------------------------------------------------------
Function AtDescCbox(cChave, cCampo)
Local aArea       := GetArea()
Local aCombo      := {}
Local nX          := 0
Local cDescri     := ""
Default cChave    := ""
Default cCampo    := ""

//Se tiver campo
If !Empty(cCampo)
    aCombo := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)
        
    //Percorre as posições do combo
    For nX := 1 To Len(aCombo)
        //Se for a mesma chave, seta a descrição
        If ValType(cChave) == ValType(aCombo[nX][2])
            If AllTrim(cChave) == AllTrim(aCombo[nX][2])
                cDescri := aCombo[nX][3]
                Exit
            EndIf
        EndIf
    Next nX
EndIf
    
RestArea(aArea)
Return AllTrim(cDescri)
