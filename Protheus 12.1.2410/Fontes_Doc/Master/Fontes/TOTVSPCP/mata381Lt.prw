#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA381LT.CH"

Static _cOp     := Nil
Static _lOk     := .F.
Static _oMark   := Nil
Static _oSugest := Nil

/*/{Protheus.doc} SugestaoLotesEnderecosMATA381
Classe para controle do processo de sugestão de lotes e endereços
@author breno.ferreira
@since 04/06/2025
@version P12
/*/
CLASS SugestaoLotesEnderecosMATA381 from LongClassName
    METHOD new() CONSTRUCTOR
    METHOD AbreLtEnd(cAliasSD4)
    METHOD destroy()
ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe de sugestao de lotes e enderecos dos empehos
@type  Method
@author breno.ferreira
@since 04/06/2025
@version P12
@return Self, objeto, instancia da classe
/*/
METHOD new() CLASS SugestaoLotesEnderecosMATA381
Return Self

/*/{Protheus.doc} destroy
Destroy a classe
@type Method
@author breno.ferreira
@since 04/06/2025
@version P12
/*/
METHOD destroy() CLASS SugestaoLotesEnderecosMATA381
    FreeObj(_oMark)
    _oMark := Nil

    FreeObj(_oSugest)
    _oSugest := Nil

Return

/*/{Protheus.doc} AbreLtEnd
Abre a tela para selecionar os campos para a sugestão de Lote/Endereço
@type Method
@author breno.ferreira
@since 04/06/2025
@version P12
@param 01 cAlias, Character, Alias dos campos da grid.
@return
/*/
METHOD AbreLtEnd(cAliasSD4) CLASS SugestaoLotesEnderecosMATA381
    Local aProd     := {}
    Local bSugest   :={|| ExecLtEnd()}
    Local cCondicao := ""
    Local cProd     := ""
    
    _cOp  := (cAliasSD4)->D4_OP
    aProd := getProd()
    _lOk  := .F.

    If Len(aProd) > 0
        cProd := ArrTokStr(aProd,",")
    Else 
        Return Help( ,, 'Help',,STR0004, 1, 0 ) //"Nâo existe nenhum produto para sugerir lote e endereço para essa ordem de produção."
    EndIf

    cCondicao := " D4_FILIAL = '" + xFilial("SD4") + "' "
    cCondicao += " AND D4_OP = '" + _cOp + "' "
    cCondicao += " AND D4_COD IN (" + cProd + ") "
    cCondicao += " AND D4_LOTECTL = ' ' "
    cCondicao += " AND (NOT EXISTS (SELECT 1 FROM " + RetSqlName("SDC") + " SDC "
    cCondicao +=                   " WHERE SDC.DC_OP      = D4_OP "
    cCondicao +=                     " AND SDC.DC_PRODUTO = D4_COD "
    cCondicao +=                     " AND SDC.DC_TRT     = D4_TRT " 
    cCondicao +=                     " AND SDC.D_E_L_E_T_ = ' ' )) "
    cCondicao += " AND D_E_L_E_T_ = ' ' "

    _oMark := FWMarkBrowse():New()
    _oMark:SetAlias("SD4")
    _oMark:SetDescription(STR0001) //"Sugerir Lote/Endereço"
    _oMark:SetFieldMark("D4_OK")
    _oMark:SetFilterDefault("@"+cCondicao)
    _oMark:SetAllMark({|| MarkAll() })
    _oMark:SetIgnoreARotina(.T.)
    _oMark:SetMenuDef("")
    _oMark:AddButton(STR0002,bSugest,,1,0) //"Confirmar"
    _oMark:Activate()

Return

/*/{Protheus.doc} MarkAll
Marca e desmarca todos os registros
@type Static Function
@author breno.ferreira
@since 04/06/2025
@version P12
@return
/*/
Static Function MarkAll()
    Local aArea := GetArea()

    While !SD4->(Eof())
        If _oMark:IsMark(_oMark:Mark())
            _oMark:MarkRec()
        Else
            _oMark:MarkRec()
        EndIf
        SD4->(DbSkip())
    End

    RestArea(aArea)
    _oMark:Refresh()
    _oMark:GoTop(.T.)
Return

/*/{Protheus.doc} ExecLtEnd
Executa a sugestão dos lotes e endereços
@type Static Function
@author breno.ferreira
@since 04/06/2025
@version P12
@return
/*/
Static Function ExecLtEnd()

    _oSugest := SugestaoLotesEnderecos():New(Nil, .F., .F., , "", "", , .T., "", "")

    DbSelectArea("SD4")
    SD4->(DbSetOrder(2))
    SD4->(DbSeek(xFilial("SD4")+_cOp))
    While SD4->(!Eof()) .And. SD4->D4_FILIAL == xFilial("SD4")
        If SD4->(IsMark("D4_OK", _oMark:Mark()))
            Processa({|lEnd| _oSugest:processarProduto(SD4->D4_COD, SD4->D4_LOCAL, 0, SD4->D4_OP, cValToChar(SD4->(Recno())))},I18n(STR0003, {SD4->D4_COD}), "", .F.) //"Sugerindo Lote/Endereço do produto: #1[produto]#"
            _lOk := .T.
        EndIf
        SD4->(dbSkip())
    End

    If _lOk
        CloseBrowse()
    Else
        Return Help( ,, 'Help',,STR0005, 1, 0 ) //"Deverá ser selecionado pelo menos um produto para sugerir lote e/ou endereço."
    EndIf

Return

/*/{Protheus.doc} getProd
Buscas os produtos a serem sugeridos lote/endereço.
@type Static Function
@author breno.ferreira
@since 16/07/2025
@version P12
@return
/*/
Static Function getProd()
    Local aProd     := {}
    Local aQtLt     := {}
    Local cAlias    := ""
    Local cQuery    := ""
    Local lConsVenc := SUPERGETMV("MV_LOTVENC",.T.,"N") == "S"
    Local nSaldo    := 0
    Local oCondicao := Nil

    cQuery := " SELECT DISTINCT SD4.D4_COD, D4_LOCAL, D4_TRT "
    cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
    cQuery +=  " WHERE SD4.D4_FILIAL  = ? "
    cQuery +=    " AND SD4.D4_OP      = ? "
    cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "

    oCondicao := FwExecStatement():New(cQuery)

    oCondicao:SetString(1, xFilial("SD4"))
    oCondicao:SetString(2, _cOp)

    cAlias := oCondicao:OpenAlias()

    While (cAlias)->(!Eof())
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
        If SB1->(dbseek(xFilial("SB1") + (cAlias)->D4_COD))
            If SB1->B1_LOCALIZ != 'N' .OR. SB1->B1_RASTRO != 'N'
                dbSelectArea("SDC")
                SDC->(dbSetOrder(2))
                If !SDC->(dbseek(xFilial("SDC") + (cAlias)->D4_COD + (cAlias)->D4_LOCAL + _cOp + (cAlias)->D4_TRT))
                    dbSelectArea("SD4")
                    SD4->(dbSetOrder(1))
                    If SD4->(dbseek(xFilial("SD4") + (cAlias)->D4_COD + _cOp + (cAlias)->D4_TRT))
                        If Alltrim(SD4->D4_LOTECTL) == ''
                            aQtLt := getQtProd((cAlias)->D4_COD)
                            If Len(aQtLt) > 0 .And. (aQtLt[1][1] == 1 .Or. aQtLt[1][2])
                                If SB1->B1_LOCALIZ != 'N'
                                    nSaldo := SaldoSBF(SD4->D4_LOCAL, "", SD4->D4_COD)
                                Else
                                    nSaldo := SaldoLote((cAlias)->D4_COD, SD4->D4_LOCAL, SD4->D4_LOTECTL, Nil, Nil, lConsVenc)
                                EndIf
                                If nSaldo > 0
                                    Aadd(aProd, "'" + Alltrim(SD4->D4_COD) + "'")
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(dbCloseArea())

    FreeObj(oCondicao)
    oCondicao := Nil

Return aProd

/*/{Protheus.doc} getQtProd
Busca a quantidade de produtos da OP para validar se já tem lote.
@type Static Function
@author breno.ferreira
@since 17/07/2025
@version P12
@param 01 cProd, Character, Produto para buscar a quantidade de registro.
@return aQtLt, Array, Array com as quantidades de registro e TRT's
/*/
Static Function getQtProd(cProd)
    Local aQtLt    := {}
    Local cAliasQt := ""
    Local cQueryQt := ""
    Local lTrt     := .F.
    Local oQtLt    := Nil

    cQueryQt := " SELECT COUNT(*) AS QTLT "
    cQueryQt +=   " FROM " + RetSqlName("SD4")
    cQueryQt +=  " WHERE D4_FILIAL  = ? "
    cQueryQt +=    " AND D4_COD     = ? "
    cQueryQt +=    " AND D4_OP      = ? "
    cQueryQt +=    " AND D_E_L_E_T_ = ' ' "

    oQtLt := FwExecStatement():New(cQueryQt)

    oQtLt:SetString(1, xFilial("SD4"))
    oQtLt:SetString(2, cProd)
    oQtLt:SetString(3, _cOp)       

    cAliasQt := oQtLt:OpenAlias()
    
    lTrt := getTRT(cProd)

    If (cAliasQt)->(!Eof())
        Aadd(aQtLt, {(cAliasQt)->QTLT, lTrt})
    EndIf

    (cAliasQt)->(dbCloseArea())

    FreeObj(oQtLt)
    oQtLt := Nil

Return aQtLt

/*/{Protheus.doc} getTRT
Valida se tem TRT na OP
@type Static Function
@author breno.ferreira
@since 18/07/2025
@version P12
@param 01 cProd, Character, Produto para buscar a quantidade de registro.
@return lTrt, Logical, Retorna True se tem TRT no produto e retorna falso se não tem.
/*/
Static Function getTRT(cProd)
    Local cAliasTrt := ""
    Local cQueryTrt := ""
    Local lTrt      := .F.
    Local oTrt      := Nil

    cQueryTrt := " SELECT COUNT(D4_TRT) AS TRT "
    cQueryTrt +=   " FROM " + RetSqlName("SD4")
    cQueryTrt +=  " WHERE D4_FILIAL  = ? "
    cQueryTrt +=    " AND D4_OP      = ? "
    cQueryTrt +=    " AND D4_COD     = ? "
    cQueryTrt +=    " AND D4_TRT    <> ' ' "
    cQueryTrt +=    " AND D_E_L_E_T_ = ' ' "

    oTrt := FwExecStatement():New(cQueryTrt)

    oTrt:SetString(1, xFilial("SD4"))
    oTrt:SetString(2, _cOp)
    oTrt:SetString(3, cProd)       

    cAliasTrt := oTrt:OpenAlias()

    If (cAliasTrt)->(!Eof())
        If (cAliasTrt)->TRT > 0
            lTrt := .T.
        EndIf
    EndIf

    (cAliasTrt)->(dbCloseArea())

    FreeObj(oTrt)
    oTrt := Nil

Return lTrt
