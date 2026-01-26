#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PCPXFUNB.CH"

Static _aLine   := {}
Static _oBDTemp := Nil
Static _oBDNF   := Nil
Static _oDBRASN := Nil

/*/{Protheus.doc} criaRas
Cria a base temporária e chama a função principal
@type Function
@author Breno Ferreira
@since 14/05/2025
@version P12
@param1 cProduto, Character, Produto da requisição.
@param2 cLote   , Character, Lote da requisição.
@param3 cSubLote, Character, Sub-Lote da requisição.
@param4 nChamad , Numeric, Numero de chamadas (Default 0).
@return _oBDTemp, Object, Retorna a base com os registros do produto.
/*/
Function criaRas(cProduto, cLote, cSubLote, nChamad)

    If _oBDTemp != Nil
        _oBDTemp:Delete()
        FreeObj(_oBDTemp)
    EndIf

    criaDBTemp("RASLT")

    buscaReq(cProduto, cLote, cSubLote, nChamad, cProduto,,,)
Return _oBDTemp

/*/{Protheus.doc} buscaReq
Buscas as requisições e grava produto acabado na tabela temporária.
@type Static Function
@author Breno Ferreira
@since 14/05/2025
@version P12
@param1 cProduto, Character, Produto da requisição.
@param2 cLote   , Character, Lote da requisição.
@param3 cSubLote, Character, Sub-Lote da requisição.
@param4 nChamad , Numeric  , Numero de chamadas (Default 0).
@param5 cProdOri, Character, Produto origem - Produto que está sendo pesquisado.
@param6 cOpPrd  , Character, Ordem de produção da última produção encontrada.
@param7 nQtdPrd , Numeric  , Quantidade produzida da última produção encontrada.
@param8 nRecPrd , Numeric  , Recno da SD5 da última produção encontrada.
@return Nil
/*/
Static Function buscaReq(cProduto, cLote, cSubLote, nChamad, cProdOri, cOpPrd, nQtdPrd, nRecPrd)
    Local aAreaBack1 := {}
    Local aAreaBack2 := {}
    Local aVarAux    := {}
    Local cAlias     := ""
    Local cBanco     := TCGetDB()
    Local cDadosPrdL := ""
    Local cDadosPrdS := ""
    Local cLocal     := CriaVar("D5_LOCAL",.F.)
    Local cOpAnt     := ""
    Local cQuery     := ""
    Local cTmSD3     := ""
    Local lSubLote   := Rastro(cProduto,"S")
    Local nNivMax    := SuperGetMV("MV_C040NIV",.F.,30)
    Local oExec      := Nil

    Default nChamad  := 0
    Default cOpPrd   := ""
    Default nQtdPrd  := 0
    Default nRecPrd  := 0

    cQuery :=   " SELECT SD5.D5_PRODUTO, "
    cQuery +=          " SD5.D5_LOTECTL, "
    cQuery +=          " SD5.D5_NUMLOTE, "
    cQuery +=          " SD5.D5_NUMSEQ, "
    cQuery +=          " SD5.D5_OP, "
    cQuery +=          " SD5.D5_QUANT, "
    cQuery +=          " SD5.D5_DOC, "
    cQuery +=          " SD5.D5_LOTEPRD, "
    cQuery +=          " SD5.D5_LOCAL, "
    cQuery +=          " SD5.D5_ORIGLAN, "
    cQuery +=          " SD5.D5_SLOTEPR, "
    cQuery +=          " SD5.D5_DTVALID, "
    cQuery +=          " SD5.R_E_C_N_O_ RECNOSD5 "
    cQuery +=    "  FROM " + RetSqlName("SD5") + " SD5 "
    cQuery +=    " WHERE SD5.D5_FILIAL  = ? "
    cQuery +=      " AND SD5.D5_PRODUTO = ? "
    cQuery +=      " AND SD5.D5_LOTECTL = ? "
    If !Empty(cSubLote) .And. lSubLote
        cQuery +=  " AND SD5.D5_NUMLOTE = ? "
    EndIf
    cQuery +=      " AND ((SD5.D5_ORIGLAN > '500') "
    cQuery +=       " OR (SUBSTR(SD5.D5_ORIGLAN,1,1) IN ('R'))) "
    cQuery +=      " AND SD5.D5_OP <> ' ' "
    cQuery +=      " AND SD5.D5_ESTORNO = ' ' "
    cQuery +=      " AND SD5.D_E_L_E_T_ = ' ' "

    If "MSSQL" $ cBanco
        cQuery := StrTran(cQuery, 'SUBSTR', 'SUBSTRING')
    EndIf

    oExec := FwExecStatement():New(cQuery)

    oExec:SetString(1, xFilial("SD5"))
    oExec:SetString(2, cProduto)
    oExec:SetString(3, cLote)
    If !Empty(cSubLote) .And. lSubLote
        oExec:SetString(4, cSubLote)
    EndIf

    cAlias := oExec:OpenAlias()

    While (cAlias)->(!Eof())
        cOpAnt := (cAlias)->D5_OP
        cLotePrdP := (cAlias)->D5_LOTEPRD

        dbSelectArea(cAlias)

        If aScan(_aLine,{|x| x[2] == (cAlias)->RECNOSD5}) <> 0
            (cAlias)->(dbSkip())
            Loop
        EndIf

        cDadosPrdL := cLotePrdP 
        cDadosPrdS := If(lSubLote, cSubLote, "")
        
        cLine := cProduto + cLocal + (cAlias)->D5_LOTECTL + " " + (cAlias)->D5_NUMLOTE + STR0001 + cOpAnt

        aAreaBack1 := (cAlias)->(GetArea())
        
        If nNivMax > nChamad
            nChamad++
            
            //Verifica se existe produção 
            If (cAlias)->D5_PRODUTO == cProdOri .Or. validPrd(cOpAnt)
                dbSelectArea("SD5")
                SD5->(dbSetOrder(4))
                SD5->(MsSeek(xFilial("SD5")+cOpAnt))
                While SD5->(!Eof()) .And. xFilial("SD5")+cOpAnt == SD5->D5_FILIAL+SD5->D5_OP
                                
                    If SD5->D5_ESTORNO = 'S'
                        SD5->(dbSkip())
                        Loop
                    EndIf

                    aAreaBack2 := SD5->(GetArea())

                    cTmSD3 := PCP040TM(SD5->D5_NUMSEQ, SD5->D5_ORIGLAN, SD5->D5_OP)
                    If Substr(cTmSD3,1,2) == "PR" .And.;
                        If((!Empty(SD5->D5_LOTEPRD) .And. !Empty(cDadosPrdL)),cDadosPrdL == SD5->D5_LOTEPRD, .T.) .And.;
                        If((!Empty(SD5->D5_SLOTEPR) .And. !Empty(cDadosPrdS)),cDadosPrdS == SD5->D5_SLOTEPR, .T.)
                    
                        If !existTab(SD5->(Recno()))
                            cOpPrd  := cOpAnt
                            nQtdPrd := SD5->D5_QUANT
                            nRecPrd := SD5->(Recno())
                            buscaReq(SD5->D5_PRODUTO, SD5->D5_LOTECTL, SD5->D5_NUMLOTE, @nChamad, cProdOri, cOpPrd, nQtdPrd, nRecPrd)
                            If !validReq(SD5->D5_PRODUTO, SD5->D5_LOTECTL, SD5->D5_NUMLOTE)
                                dbSelectArea("SB1")
                                SB1->(dbSetOrder(1))
                                SB1->(MsSeek(xFilial("SB1")+SD5->D5_PRODUTO))
                                gravaTabela(SD5->D5_PRODUTO, SD5->D5_LOTECTL, SD5->D5_NUMLOTE, SD5->D5_DOC, SD5->D5_QUANT, SD5->D5_NUMSEQ, SD5->D5_LOTEPRD, SD5->D5_OP, SD5->D5_DTVALID, SB1->B1_DESC, SD5->(Recno()))
                            EndIf
                        EndIf
                    EndIf
                
                    SD5->(RestArea(aAreaBack2))
                    SD5->(dbSkip())
                EndDo
            Else
                If !existTab((cAlias)->RECNOSD5)
                    dbSelectArea("SB1")
                    SB1->(dbSetOrder(1))
                    SB1->(MsSeek(xFilial("SB1")+(cAlias)->D5_PRODUTO))
                    gravaTabela((cAlias)->D5_PRODUTO, (cAlias)->D5_LOTECTL, (cAlias)->D5_NUMLOTE, (cAlias)->D5_DOC, nQtdPrd, (cAlias)->D5_NUMSEQ, (cAlias)->D5_LOTEPRD, cOpPrd, SToD((cAlias)->D5_DTVALID), SB1->B1_DESC, nRecPrd)
                EndIf
            EndIf
            nChamad--
        EndIf

        (cAlias)->(RestArea(aAreaBack1))
        dbSelectArea(cAlias)

        If !Empty(cLine)
             aVarAux  := { cProduto           ,; // [1] Produto
                           (cAlias)->RECNOSD5  } // [2] Nro registro SD5

            aAdd(_aLine,aVarAux)
        EndIf

        dbSelectArea(cAlias)
        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(dbCloseArea())
    oExec:Destroy()
    FreeObj(oExec)
    
Return

/*/{Protheus.doc} gravaTabela
Grava os conteúdos dentro da tabela temporária.
@type Static Function
@author Breno Ferreira
@since 14/05/2025
@version P12
@param1  cProduto, Character, Produto do produto acabado
@param2  cLote   , Character, Lote do produto acabado
@param3  cSubLote, Character, Sub-Lote do produto acabado
@param4  cDoc    , Character, Documento do produto acabado
@param5  nQuant  , Numeric  , Quantidade do produto acabado
@param6  cNumSeq , Character, Número da sequência do produto acabado
@param7  cLotePrd, Character, Lote produzido do produto acabado
@param8  cOp     , Character, Ordem de Produção do produto acabado
@param9  cTipo   , Character, Tipo do produto acabado
@param10 cDesc   , Character, Descrição do produto do produto acabado
@param11 nRecno  , Character, Recno referente ao registro da SD5
@return Nil
/*/
Static Function gravaTabela(cProduto, cLote, cSubLote, cDoc, nQuant, cNumSeq, cLotePrd, cOp, dValid, cDesc, nRecno)
    Local cQuery := ""
    
    cQuery := " INSERT INTO " + _oBDTemp:GetRealName()
    cQuery +=       " (RAS_PROD, "
    cQuery +=        " RAS_DESC, "
    cQuery +=        " RAS_LOTE, "
    cQuery +=        " RAS_NUMLT, "
    cQuery +=        " RAS_DOC, "
    cQuery +=        " RAS_QUANT, "
    cQuery +=        " RAS_NUMSEQ, "
    cQuery +=        " RAS_LTPRD, "
    cQuery +=        " RAS_OP, "
    cQuery +=        " RAS_DTVALI, "
    cQuery +=        " RAS_REC) "
    cQuery += " VALUES "
    cQuery += " ('" + cProduto + "', "
    cQuery +=   "'" + cDesc + "', "
    cQuery +=   "'" + cLote + "', "
    cQuery +=   "'" + cSubLote + "', "
    cQuery +=   "'" + cDoc + "', "
    cQuery +=   "'" + AllTrim(Str(nQuant)) + "', "
    cQuery +=   "'" + cNumSeq + "', "
    cQuery +=   "'" + cLotePrd + "', "
    cQuery +=   "'" + cOp + "', "
    cQuery +=   "'" + DToS(dValid) + "', "
    cQuery +=   "'" + AllTrim(Str(nRecno)) + "') "

    MATExecQry(cQuery)

Return

/*/{Protheus.doc} criaDBTemp
Cria a base temporária
@type Static Function
@author Breno Ferreira
@since 14/05/2025
@version P12
@return Nil
/*/
Function criaDBTemp(cBanco)
    Local aFields := {}

    If cBanco == "RASLT"
        _aLine := {}

        Aadd(aFields, {"RAS_PROD"  , "C", TamSX3("D5_PRODUTO")[1], 0})
        Aadd(aFields, {"RAS_DESC"  , "C", TamSX3("B1_DESC")[1]   , 0})
        Aadd(aFields, {"RAS_QUANT" , "N", TamSX3("D5_QUANT")[1]  , TamSX3("D5_QUANT")[2]})
        Aadd(aFields, {"RAS_LOTE"  , "C", TamSX3("D5_LOTECTL")[1], 0})
        Aadd(aFields, {"RAS_NUMLT" , "C", TamSX3("D5_NUMLOTE")[1], 0})
        Aadd(aFields, {"RAS_NUMSEQ", "C", TamSX3("D5_NUMSEQ")[1] , 0})
        Aadd(aFields, {"RAS_DOC"   , "C", TamSX3("D5_DOC")[1]    , 0})
        Aadd(aFields, {"RAS_LTPRD" , "C", TamSX3("D5_LOTEPRD")[1], 0})
        Aadd(aFields, {"RAS_OP"    , "C", TamSX3("D5_OP")[1]     , 0})
        Aadd(aFields, {"RAS_DTVALI", "D", TamSX3("D5_DTVALID")[1], 0})
        Aadd(aFields, {"RAS_REC"   , "N", 11                     , 0})

        _oBDTemp := FWTemporaryTable():New(cBanco, aFields)
        _oBDTemp:Create()

    ElseIf cBanco == "RASNF"

        If _oBDNF != Nil
            _oBDNF:Delete()
            FreeObj(_oBDNF)
        EndIf

        aAdd(aFields, {"NF_NOTA"   , "C", TamSX3("D5_DOC")[1]    , 0})
        aAdd(aFields, {"NF_SERIE"  , "C", TamSX3("D5_SERIE")[1]  , 0})
        aAdd(aFields, {"NF_QUANT"  , "N", TamSX3("D5_QUANT")[1]  , TamSX3("D5_QUANT")[2]})
        aAdd(aFields, {"NF_LOJA"   , "C", TamSX3("D2_LOJA")[1]   , 0})
        aAdd(aFields, {"NF_CLIENTE", "C", TamSX3("D2_CLIENTE")[1], 0})
        aAdd(aFields, {"NF_NOME"   , "C", 15                     , 0})
        aAdd(aFields, {"NF_TIPO"   , "C", TamSX3("D2_TIPO")[1]   , 0})
        aAdd(aFields, {"NF_PROD"   , "C", TamSX3("D5_PRODUTO")[1], 0})
        aAdd(aFields, {"NF_LOTE"   , "C", TamSX3("D5_LOTECTL")[1], 0})

        _oBDNF := FWTemporaryTable():New(cBanco, aFields)
        _oBDNF:Create()

    ElseIf cBanco == "RAST"

        Aadd(aFields, {"RAST_PROD"  , "C", TamSX3("D5_PRODUTO")[1], 0})
        Aadd(aFields, {"RAST_LOTE"  , "C", TamSX3("D5_LOTECTL")[1], 0})
        Aadd(aFields, {"RAST_OP"    , "C", TamSX3("D5_OP")[1]     , 0})

        _oDBRASN := FWTemporaryTable():New(cBanco, aFields)
        _oDBRASN:Create()
    
    EndIf

Return

/*/{Protheus.doc} validReq
Valida se já foi encontrado os produtos acabados
@type Static Function
@author Breno Ferreira
@since 14/05/2025
@version P12
@param1 cProduto, Character, Produto da requisição.
@param2 cLote   , Character, Lote da requisição.
@Param3 cSubLote, Character, Sub-Lote da requisição.
@return lOk, Logical, Retorna .T. caso tenha mais requisições e .F. caso seja o último item da requisição
/*/
Static Function validReq(cProduto, cLote, cSubLote)
    Local cAlias := ""
    Local cQuery := ""
    Local lOk    := .F.
    Local oExec  := Nil

    cQuery :=   " SELECT SD5.D5_PRODUTO, "
    cQuery +=          " SD5.D5_LOTECTL, "
    cQuery +=          " SD5.D5_NUMLOTE "
    cQuery +=     " FROM " + RetSqlName("SD5") + " SD5 "
    cQuery +=    " INNER JOIN " + RetSqlName("SD3") + " SD3 "
    cQuery +=       " ON SD3.D3_FILIAL  = ? "
    cQuery +=      " AND SD5.D5_PRODUTO = SD3.D3_COD "
    cQuery +=      " AND SD5.D5_DOC     = SD3.D3_DOC "
    cQuery +=      " AND SD5.D5_NUMSEQ  = SD3.D3_NUMSEQ "
    cQuery +=      " AND SD3.D3_CF     IN ('RE0', 'RE1') "
    cQuery +=      " AND SD3.D3_ESTORNO = ' ' "
    cQuery +=      " AND SD3.D_E_L_E_T_ = ' ' "
    cQuery +=    " WHERE SD5.D5_FILIAL  = ? "
    cQuery +=      " AND SD5.D5_PRODUTO = ? "
    cQuery +=      " AND SD5.D5_LOTECTL = ? "
    cQuery +=      " AND SD5.D5_ESTORNO = ' ' "
    cQuery +=      " AND SD5.D_E_L_E_T_ = ' ' "

    oExec := FwExecStatement():New(cQuery)

    oExec:SetString(1, xFilial("SD3"))
    oExec:SetString(2, xFilial("SD5"))
    oExec:SetString(3, cProduto)
    oExec:SetString(4, cLote)

    cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        lOk := .T.
    EndIf

    (cAlias)->(dbCloseArea())
    oExec:Destroy()
    FreeObj(oExec)

Return lOk

/*/{Protheus.doc} validPrd
Valida se existe produção para a OP
@type Static Function
@author Michele Girardi
@since 22/05/2025
@version P12
@param1 cOp, Character, Ordem de Produção
@return lRet, Logical, Retorna .T. caso tenha produção e .F. caso não tenha produção
/*/
Static Function validPrd(cOp)
    Local cAlias := ""
    Local cQuery := ""
    Local lRet   := .F.
    Local oExec  := Nil

    cQuery :=   " SELECT SD5.D5_PRODUTO "
    cQuery +=     " FROM " + RetSqlName("SD5") + " SD5 "
    cQuery +=    " INNER JOIN " + RetSqlName("SD3") + " SD3 "
    cQuery +=       " ON SD3.D3_FILIAL  = ? "
    cQuery +=      " AND SD5.D5_PRODUTO = SD3.D3_COD "
    cQuery +=      " AND SD5.D5_DOC     = SD3.D3_DOC "
    cQuery +=      " AND SD5.D5_NUMSEQ  = SD3.D3_NUMSEQ "
    cQuery +=      " AND SD3.D3_CF     IN ('PR0', 'PR1') "
    cQuery +=      " AND SD3.D3_OP      = ? "
    cQuery +=      " AND SD3.D3_ESTORNO = ' ' "
    cQuery +=      " AND SD3.D_E_L_E_T_ = ' ' "
    cQuery +=    " WHERE SD5.D5_FILIAL  = ? "
    cQuery +=      " AND SD5.D5_ESTORNO = ' ' "
    cQuery +=      " AND SD5.D_E_L_E_T_ = ' ' "

    oExec := FwExecStatement():New(cQuery)

    oExec:SetString(1, xFilial("SD3"))
    oExec:SetString(2, cOp)
    oExec:SetString(3, xFilial("SD5"))

    cAlias := oExec:OpenAlias()

    If (cAlias)->(!Eof())
        lRet := .T.
    EndIf

    (cAlias)->(dbCloseArea())
    oExec:Destroy()
    FreeObj(oExec)

Return lRet

/*/{Protheus.doc} existTab
Valida se o RECNO já foi incluído na tabela
@type Static Function
@author Michele Girardi
@since 22/05/2025
@version P12
@param1 nRecno, Numérico, Recno referente ao registro da SD5
@return lRet, Logical, Retorna .T. caso já exista e .F. caso não exista o Recno na tabela
/*/
Static Function existTab(nRecno)
    Local cAlias := ""
    Local cQuery := ""
    Local lRet   := .F.
    Local oExist := Nil

    cQuery := " SELECT COUNT(*) COUNT "
    cQuery +=   " FROM " + _oBDTemp:GetRealName()
    cQuery +=  " WHERE RAS_REC = ? "

    oExist := FwExecStatement():New(cQuery)

    oExist:SetNumeric(1, nRecno)

    cAlias := oExist:OpenAlias()

    If (cAlias)->(!Eof())
       If (cAlias)->COUNT > 0
           lRet := .T.
       EndIf
    EndIf

    (cAlias)->(dbCloseArea())
    oExist:Destroy()
    FreeObj(oExist)

Return lRet

/*/{Protheus.doc} PCPCriaNF
Cria o banco e grava as notas fiscais.

@type Static Function
@author Breno Ferreira
@since 13/08/2025
@version P12
@param1 cProduto , Character, Produto para a busca das notas fiscais.
@param2 cLote    , Character, Lote para a busca das notas fiscais.
@param3 cSubLote , Character, Sub-Lote para a busca das notas fiscais.
@return _oBDNF, Object, Retorna o banco das notas fiscais.
/*/
Function PCPCriaNF(cProduto, cLote, cSubLote)

    buscaNF(cProduto, cLote, cSubLote)

Return _oBDNF

/*/{Protheus.doc} buscaNF
Busca as notas fiscais e grava elas.

@type Static Function
@author Breno Ferreira
@since 13/08/2025
@version P12
@param1 cProduto , Character, Produto para a busca das notas fiscais.
@param2 cLote    , Character, Lote para a busca das notas fiscais.
@param3 cSubLote , Character, Sub-Lote para a busca das notas fiscais.
@return Nil
/*/
Static Function buscaNF(cProduto, cLote, cSubLote)
    Local cAlias    := ""
    Local cAliasF4  := ""
    Local cBanco    := TCGetDB()
    Local cCliente  := ""
    Local cLoja     := ""
    Local cNomeCli  := ""
    Local cQuery    := ""
    Local cQueryF4  := ""
    Local cTipo     := ""
    Local lSubLote  := Rastro(cProduto, "S")
    Local nPosParam := 0
    Local oExecF4   := Nil
    Local oExecNF   := Nil

    cQuery := " SELECT SD5.D5_PRODUTO, "
    cQuery +=        " SD5.D5_LOTECTL, "
    cQuery +=        " SD5.D5_NUMLOTE, "
    cQuery +=        " SD5.D5_DOC, "
    cQuery +=        " SD5.D5_SERIE, " 
    cQuery +=        " SD5.D5_NUMSEQ, "
    cQuery +=        " SD5.D5_LOCAL, "
    cQuery +=        " SD5.D5_QUANT, "
    cQuery +=        " SD5.D5_LOCAL "
    cQuery +=  " FROM " + RetSqlName("SD5") + " SD5 "
    cQuery += " WHERE SD5.D5_FILIAL  = ? "
    cQuery +=   " AND SD5.D5_PRODUTO = ? "
    cQuery +=   " AND SD5.D5_LOTECTL = ? "
    If !Empty(cSublote) .And. lSubLote
        cQuery +=   " AND SD5.D5_NUMLOTE = ? "
    EndIf
    cQuery +=   " AND SD5.D5_ESTORNO = ' ' "
    cQuery +=   " AND ((SD5.D5_ORIGLAN > '500') "
    cQuery +=    " OR (SUBSTR(SD5.D5_ORIGLAN,1,1) IN ('R'))) "
    cQuery +=   " AND SD5.D_E_L_E_T_ = ' ' "

    If "MSSQL" $ cBanco
        cQuery := StrTran(cQuery, 'SUBSTR', 'SUBSTRING')
    EndIf

    nPosParam := 1

    oExecNF := FwExecStatement():New(cQuery)

    oExecNF:setString(nPosParam++, xFilial("SD5"))
    oExecNF:setString(nPosParam++, cProduto)
    oExecNF:setString(nPosParam++, cLote)
    If !Empty(cSublote) .And. lSubLote
        oExecNF:setString(nPosParam++, cSublote)
    EndIf

    cAlias := oExecNF:OpenAlias()

    While (cAlias)->(!Eof())

        dbSelectArea("SD2")
        SD2->(dbSetOrder(1))
        If SD2->(MsSeek(xFilial("SD2")+(cAlias)->D5_PRODUTO+(cAlias)->D5_LOCAL+(cAlias)->D5_NUMSEQ))
            
            cQueryF4 := " SELECT SF4.F4_CODIGO, "
            cQueryF4 +=        " SF4.F4_PODER3 "
            cQueryF4 +=   " FROM " + RetSqlName("SF4") + " SF4 "
            cQueryF4 +=  " WHERE SF4.F4_FILIAL  = ? "
            cQueryF4 +=    " AND SF4.F4_CODIGO  = ? "
            cQueryF4 +=    " AND SF4.D_E_L_E_T_ = ' ' "

            oExecF4 := FwExecStatement():New(cQueryF4)

            oExecF4:setString(1, xFilial("SF4"))
            oExecF4:setString(2, SD2->D2_TES)

            cAliasF4 := oExecF4:OpenAlias()

            If (cAliasF4)->(!EoF())
                dbSelectArea(If(SD2->D2_TIPO $ "DB","SA2","SA1"))
                dbSetOrder(1)
                If MsSeek(xFilial(If(SD2->D2_TIPO $ "DB","SA2","SA1"))+SD2->D2_CLIENTE+SD2->D2_LOJA)
                    cNomeCli := SubStr(AllTrim(If(SD2->D2_TIPO $ "DB",SA2->A2_NREDUZ,SA1->A1_NREDUZ)),1,15)
                EndIf
                cTipo := (cAliasF4)->F4_PODER3

                (cAliasF4)->(DBSkip())

                (cAliasF4)->(DBCloseArea())
                oExecF4:Destroy()
                FreeObj(oExecF4)
            EndIf

            cCliente := SD2->D2_CLIENTE
            cLoja    := SD2->D2_LOJA

            gravaNF((cAlias)->D5_DOC, (cAlias)->D5_SERIE, cCliente, cLoja, cTipo, (cAlias)->D5_QUANT, cNomeCli, (cAlias)->D5_PRODUTO, (cAlias)->D5_LOTECTL)
        EndIf

        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(DBCloseArea())
    oExecNF:Destroy()
    FreeObj(oExecNF)

Return

/*/{Protheus.doc} gravaNF
Grava na tabela os items da nota fiscal.

@type Static Function
@author Breno Ferreira
@since 13/08/2025
@version P12
@param1 cNota    , Character, Numero da nota fiscal.
@param2 cSerie   , Character, Serie da nota fiscal.
@param3 cCliente , Character, Cliente da nota fiscal.
@param4 cLoja    , Character, Loja da nota fiscal.
@param5 cTipo    , Character, Tipo da nota fiscal.
@param6 nQuant   , Numeric  , Quantidade da nota fiscal.
@param7 cNomeCli , Character, Nome do cliente da nota fiscal.
@param8 cProduto , Character, Prduto da nota fiscal.
@param9 cLote    , Character, Lote da nota fiscal.
@return Nil
/*/
Static Function gravaNF(cNota, cSerie, cCliente, cLoja, cTipo, nQuant, cNomeCli, cProduto, cLote)
    Local cQuery := ""

    cQuery := " INSERT INTO " + _oBDNF:GetRealName()
    cQuery +=        " (NF_NOTA, "
    cQuery +=         " NF_SERIE, "
    cQuery +=         " NF_QUANT, "
    cQuery +=         " NF_LOJA, "
    cQuery +=         " NF_CLIENTE, "
    cQuery +=         " NF_NOME, "
    cQuery +=         " NF_TIPO, "
    cQuery +=         " NF_PROD, "
    cQuery +=         " NF_LOTE) "
    cQuery += " VALUES "
    cQuery +=       " ('" + cNota + "', "
    cQuery +=         "'" + cSerie + "', "
    cQuery +=         "'" + AllTrim(Str(nQuant)) + "', "
    cQuery +=         "'" + cLoja + "', "
    cQuery +=         "'" + cCliente + "', "
    cQuery +=         "'" + cNomeCli + "', "
    cQuery +=         "'" + cTipo + "', "
    cQuery +=         "'" + cProduto + "', "
    cQuery +=         "'" + cLote + "') "

    MATExecQry(cQuery)

Return

/*/{Protheus.doc} gravaTotal
Cria a base temporária e grava todos os regstros da query principal do relatório.
@type Function
@author Breno Ferreira
@since 05/09/2025
@version P12
@param1 oDBTemp , Object, Banco da query principal do relatório.
@param2 nIndic  , Numeric, Indica qual a é o tipo do relatório.
@return _oDBRASN, Object, Retorna o banco com todos os registros.
/*/
Function gravaTotal(oDBTemp, nIndic)
    
    If _oDBRASN != Nil
        _oDBRASN:Delete()
        FreeObj(_oDBRASN)
    EndIf

    criaDBTemp("RAST")

    buscaRAST(oDBTemp, nIndic)

Return _oDBRASN

/*/{Protheus.doc} buscaRAST
Busca todos os registros da query principal.
@type Static Function
@author Breno Ferreira
@since 05/09/2025
@version P12
@param1 oDBTemp , Object, Banco da query principal do relatório.
@param2 nIndic  , Numeric, Indica qual a é o tipo do relatório.
@return Nil
/*/
Static Function buscaRAST(oDBTemp, nIndic)
    Local cAlias := ""
    Local cOp    := ""
    Local cQuery := ""
    Local oExec  := Nil

    cQuery := " SELECT RAS_PROD, "
    cQuery +=        " RAS_LOTE, "
    If nIndic == 2
        cQuery +=    " RAS_OP, "
    EndIf
    cQuery +=        " SUM(RAS_QUANT) AS QUANT " 
    cQuery += " FROM " + oDBTemp:GetRealName()
    cQuery += " GROUP BY RAS_PROD, "
    cQuery +=          " RAS_LOTE "
    If nIndic == 2
        cQuery +=      " ,RAS_OP "
    EndIf
    cQuery += " ORDER BY RAS_PROD, "
    cQuery +=          " RAS_LOTE "

    oExec  := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

    While (cAlias)->(!EoF())

        If nIndic == 2
            cOp := (cAlias)->RAS_OP
        Else
            cOp := ""
        EndIf

        gravaRAST((cAlias)->RAS_PROD, (cAlias)->RAS_LOTE, cOp)

        (cAlias)->(dbskip())
    EndDo

    (cAlias)->(DBCloseArea())
    oExec:Destroy()
    FreeObj(oExec)

Return

/*/{Protheus.doc} gravaRAST
Grava os conteúdos dentro da tabela temporária.
@type Static Function
@author Breno Ferreira
@since 05/09/2025
@version P12
@param1 cProduto, Character, Produto do produto acabado
@param2 cLote   , Character, Lote do produto acabado
@param3 cOp     , Character, Ordem de Produção do produto acabado
@return Nil
/*/
Static Function gravaRAST(cProduto, cLote, cOp)
    Local cQuery := ""

    cQuery := " INSERT INTO " + _oDBRASN:GetRealName()
    cQuery +=       " (RAST_PROD, "
    cQuery +=        " RAST_LOTE, "
    cQuery +=        " RAST_OP) "
    cQuery += " VALUES "
    cQuery += " ('" + cProduto + "', "
    cQuery +=   "'" + cLote + "', "
    cQuery +=   "'" + cOp + "') "

    MATExecQry(cQuery)

Return

/*/{Protheus.doc} PCP040TM
Recupera o tipo de movimento do registro.

@type Static Function
@author Breno Ferreira
@since 10/09/2025
@version P12
@param1 cNumSeq , Character, Numero da sequencia do produto
@param2 cOrigLan, Character, Origem do produto
@param3 cOp     , Character, Ordem de Produção do produto selecionado
@return cRet    , Character, Retorna o tipo de movimento
/*/
Static Function PCP040TM(cNumSeq,cOrigLan, cOp)
    Local aArea     := GetArea()
    Local cAliasSD3 := ""
    Local cRet      := ""
    Local oExecSD3  := Nil

    cQuery := " SELECT SD3.D3_CF "
    cQuery +=   " FROM " + RetSqlName('SD3') + " SD3 "
    cQuery +=  " WHERE SD3.D3_FILIAL  = ? "
    cQuery +=    " AND SD3.D3_NUMSEQ  = ? "
    cQuery +=    " AND SD3.D3_OP      = ? "
    cQuery +=    " AND SD3.D3_ESTORNO = ' ' "
    cQuery +=    " AND SD3.D_E_L_E_T_ = ' ' "

    oExecSD3 := FwExecStatement():New(cQuery)

    oExecSD3:SetString(1, xFilial("SD3"))
    oExecSD3:SetString(2, cNumSeq)
    oExecSD3:SetString(3, cOp)

    cAliasSD3 := oExecSD3:OpenAlias()

    While (cAliasSD3)->(!Eof())
        cRet := (cAliasSD3)->D3_CF
        If (Substr((cAliasSD3)->D3_CF,1,1) $ "DP" .And. cOriglan <= "500") .Or. ;
           (Substr((cAliasSD3)->D3_CF,1,1) == "R" .And. cOriglan > "500" )
            Exit
        EndIf
        (cAliasSD3)->(dbSkip())
    EndDo
    (cAliasSD3)->(dbCloseArea())
    oExecSD3:Destroy()
    FreeObj(oExecSD3)

    RestArea(aArea)
Return cRet
