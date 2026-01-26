#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVERAGE.CH"
#include 'FWMVCDEF.CH'
#INCLUDE "EICFL101.CH"

/*/{Protheus.doc} EICFL101
    Função para a Integração de Fundamento Legal junto ao Pontal Único

    @type  Function
    @author THTS - Tiago Tudisco
    @since 02/10/2024
    @param 
    @return 
    /*/
Function EICFL101(cTela)
Local lIsBlind := isBlind()
local aPergFL101 := {}
local cAliasPAIS := GetNextALias()
local cAliasNCM  := GetNextALias()
local cFieldMark := "REG_MARCA"
local cMarcaPAIS := "X"
Local _aTabsPais := {}
Local _aTabsNCM  := {}

Default cTela := ""
If !lIsBlind
    WizardFLPU(cTela, cAliasPAIS, cFieldMark, cMarcaPAIS, @aPergFL101, lIsBlind, _aTabsPais, cAliasNCM, _aTabsNCM)
//Else

EndIf

Return


/*
Função     : WizardFLPU
Objetivo   : Função do wizard para Montagem dos dados a serem integrados do portal unico
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function WizardFLPU(cTela, cAliasPAIS, cFieldMark, cMarcaPAIS, aPergFL101, lIsBlind, _aTabsPais, cAliasNCM, _aTabsNCM)
local aCoords    := {}
local oStepWiz   := nil
local oStep1     := nil
local oStep2     := nil
local oStep3     := nil
local oStep4     := nil
local oMrkBrPAIS := nil
local oMrkBrNCM  := nil
local cStep      := "0"
local lOpcionais := .F.
local _aTabsRes  := {}
local cAliasTela := GetNextALias()
Local cNCMIni    := ""
Local cNCMFim    := ""
Local lGeraNCM   := .T.
Local lGeraPais  := .T.

If cTela == "NCM"
    cNCMIni := SYD->YD_TEC
    cNCMFim := SYD->YD_TEC
EndIf
aCoords := FWGetDialogSize()
oStepWiz := FWWizardControl():New(,{aCoords[3] * 0.9, aCoords[4] * 0.9})
oStepWiz:ActiveUISteps()

cStep := soma1(cStep)
oStep1 := oStepWiz:AddStep(cStep, { |oPanel| ViewIntrod( oPanel )  })
oStep1:SetStepDescription(STR0001) // "Introdução"
oStep1:SetNextTitle(STR0002) // "Avançar"
oStep1:SetNextAction( { || VldNextNCM(cAliasNCM, cFieldMark, cMarcaPAIS, _aTabsNCM, cNCMIni, @lGeraNCM)})
oStep1:SetCancelAction({|| MsgYesNo(STR0003, STR0004) }) // "Deseja cancelar a integração de Regime Tributário?" ### "Integrar Regime Tributário"

cStep := soma1(cStep)
oStep2 := oStepWiz:AddStep(cStep)
oStep2:SetStepDescription("NCMs") // "NCMs"
oStep2:SetConstruction({|oPanel| ViewNCM(oPanel, cAliasNCM, cFieldMark, cMarcaPAIS, @oMrkBrNCM), oMrkBrNCM:oBrowse:Refresh(.T.) })
oStep2:SetPrevTitle(STR0006) // "Voltar"
oStep2:SetNextTitle(STR0002) // "Avançar"
oStep2:SetNextAction({|| VldNext(cTela, cAliasPAIS, cFieldMark, cMarcaPAIS, @aPergFL101, _aTabsPais, @cNCMIni, @cNCMFim, @lOpcionais, cAliasNCM, @lGeraPais) })
oStep2:SetCancelAction({|| MsgYesNo(STR0003, STR0004) }) // "Deseja cancelar a integração de Regime Tributário?" ### "Integrar Regime Tributário"

cStep := soma1(cStep)
oStep3 := oStepWiz:AddStep(cStep)
oStep3:SetStepDescription(STR0007) // "Países"
oStep3:SetConstruction({|oPanel| ViewPaises(oPanel, cAliasPAIS, cFieldMark, cMarcaPAIS, @oMrkBrPAIS), oMrkBrPAIS:oBrowse:Refresh(.T.) })
oStep3:SetNextTitle(STR0002) // "Avançar"
oStep3:SetNextAction({|| vldPaises(cTela, cAliasPAIS, cFieldMark, cMarcaPAIS) })
oStep3:SetPrevTitle(STR0006) // "Voltar"
//oStep3:SetPrevAction({|| clearTmp(cAliasPAIS, cFieldMark, cMarcaPAIS, _aTabsPais), oMrkBrPAIS:DeActivate() ,.T.})
oStep3:SetCancelAction({|| MsgYesNo(STR0003, STR0004) }) // "Deseja cancelar a integração de Regime Tributário?" ### "Integrar Regime Tributário"

cStep := soma1(cStep)
oStep4 := oStepWiz:AddStep(cStep)
oStep4:SetStepDescription(STR0008) // "Integrar"
oStep4:SetConstruction({|oPanel| ViewResul( oPanel, cAliasPAIS, cAliasNCM, cFieldMark, cNCMIni, cNCMFim, lOpcionais, cAliasTela, _aTabsRes) })
oStep4:SetNextTitle(STR0009) // "Fechar"
oStep4:SetNextAction({|| .T. })
oStep4:SetPrevTitle(STR0076) // "Exportar"
oStep4:SetPrevAction({|| geraExcel(cAliasTela) })
oStep4:SetCancelWhen({|| .F. })

oStepWiz:Activate()
oStepWiz:Destroy()

// deleta os arquivos temporarios, tem que ser após devido para evitar errorlog ao destruir os objetos
If !Empty(_aTabsRes)
    eraseTmp(_aTabsRes)
EndIf
If !Empty(_aTabsPais)
    eraseTmp(_aTabsPais)
EndIf
If !Empty(_aTabsNCM)
    eraseTmp(_aTabsNCM)
EndIf
FwFreeObj( oStepWiz )

Return

Static Function ViewIntrod(oPanel)
Local aCoords    := {}
Local cIntrod    := "" 
Local oSay       := nil
Local oFont      := nil

aCoords := FWGetDialogSize(oPanel)
cIntrod := STR0010 + ENTER + ENTER + ; //"Esta rotina foi desenvolvida para facilitar a integração dos dados de tratamento tributário com o Portal Único. Seu principal objetivo é auxiliar o importador no preenchimento preciso da lista de 'tributos' para a inclusão de itens na DUIMP."
           STR0011 + ENTER + ENTER + ; //"O processo se inicia com a seleção das NCMs (Nomenclatura Comum do Mercosul) desejadas, formando a base para a integração. Em seguida, na próxima etapa, você seleciona os países com os quais deseja criar pares de NCM x País. Esses pares serão processados por meio de uma API, garantindo que todas as informações necessárias sejam incluídas."
           STR0012 + ENTER + ENTER+; //"O serviço retorna dados abrangentes, incluindo Fundamentos Legais de uso normal e teto, além de todos os Fundamentos Legais de uso opcional, com ou sem atributos adicionais. Isso assegura que o importador tenha todas as informações necessárias para uma declaração precisa e completa."
           STR0013 //"Para iniciar o processo, clique em 'Avançar'."
oFont := TFont():New('Courier new',,-16,.T.)
oSay := TSay():New( aCoords[1] + 10 , aCoords[2] + 05 , {|| cIntrod },oPanel,,oFont,,,,.T.,CLR_RED, , aCoords[3] - 75, aCoords[4] )
oSay:CtrlRefresh()
oSay:SetTextAlign( 0, 0 )

Return


/*
Função     : VldNextNCM
Objetivo   : Função para validar os proximos passos
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function VldNextNCM(cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, cNCMIni, lGeraNCM)
Local lRet       := .F.

Begin Sequence

    FWMsgRun(, {|oSay| lRet := getNCMs(cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, cNCMIni, @lGeraNCM) }, STR0017, STR0062) //"Integração de Regime Tributário"###"Selecionando NCMs..."

End Sequence

Return lRet

/*
Função     : VldNext
Objetivo   : Função para validar os proximos passos
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function VldNext(cTela, cAliasPAIS, cFieldMark, cMarcaPAIS, aPergFL101, _aTabsPais, cNCMIni, cNCMFim, lOpcionais, cAliasNCM, lGeraPais)
Local lRet       := .F.
Local nPaisUso   := 1
Local cPaisIni   := ""
Local cPaisFim   := ""
Local nFundOpc   := 1
Local aAreaNCM   := (cAliasNCM)->(getArea())

nPaisUso   := 1 // Apenas países em uso?
cPaisIni   := "" // País de?
cPaisFim   := "" // País até?
nFundOpc   := 1 // Integrar Fundamentos Opcionais?

Begin Sequence
    lOpcionais := nFundOpc == 1 //Intrea opcionais igual a SIM

    (cAliasNCM)->(dbSetOrder(3)) //REG_MARCA
    If !(cAliasNCM)->(dbSeek(cMarcaPAIS))
        lRet := .F.
        EasyHelp(STR0065, STR0015, STR0066) // "Não é possível prosseguir com a integração, pois nenhuma NCM foi selecionada."###"Atenção"###"Marque ao menos uma NCM para prosseguir."
        break
    EndIf

    FWMsgRun(, {|oSay| lRet := getPaises(cAliasPAIS, cFieldMark, cMarcaPAIS, cNCMIni, cNCMFim, nPaisUso, cPaisIni, cPaisFim, _aTabsPais, @lGeraPais) }, STR0017, STR0018) //"Integração de Regime Tributário"###"Selecionando países..."
    if !lRet
        MsgInfo(STR0067 + ENTER+ENTER + STR0068, STR0017)//"Nenhum País foi listado com base no Cadastro de Fornecedores."###"Ainda será possível prosseguir, incluindo qualquer País manualmente."####"Integração de Regime Tributário"
        lRet := .T.
    endif

End Sequence
RestArea(aAreaNCM)
Return lRet

/*
Função     : getNCMs
Objetivo   : Função para realizar a query, de acordo com os parametros (Pergunte - EICFL101)
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function getNCMs(cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, cNCMIni, lGeraNCM)
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry  := ""
Local oQuery     := nil

If lGeraNCM
    cAliasQry := getNextAlias()

    cQuery += " SELECT  "
    cQuery += "   COUNT(*),  "
    cQuery += "   YD_TEC,  "
    cQuery += "   YD_DESC_P  "
    cQuery += " FROM  "
    cQuery += "   ( "
    cQuery += "     SELECT  "
    cQuery += "       YD_TEC,  "
    cQuery += "       YD_DESC_P  "
    cQuery += "     FROM  "
    cQuery +=         RetSQLName("SYD") + " YD  "
    cQuery += "       INNER JOIN " + RetSQLName("EK9") + " EK9 ON ( "
    cQuery += "         EK9_FILIAL = ?  "
    cQuery += "         AND EK9_NCM = YD_TEC  "
    cQuery += "         AND EK9.D_E_L_E_T_ = ? "
    cQuery += "       )  "
    cQuery += "       INNER JOIN " + RetSQLName("SB1") + " B1 ON ( "
    cQuery += "         B1_FILIAL = ?  "
    cQuery += "         AND B1_POSIPI = YD_TEC  "
    cQuery += "         AND B1.D_E_L_E_T_ = ? "
    cQuery += "       )  "
    cQuery += "     WHERE  "
    cQuery += "       YD_FILIAL = ?  "
    cQuery += "       AND YD.D_E_L_E_T_ = ? "
    cQuery += "       AND B1.B1_IMPORT = ?  "
    cQuery += "   ) AS TOTAL_NCM "
    cQuery += " GROUP BY "
    cQuery += "   YD_TEC,  "
    cQuery += "   YD_DESC_P "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString( 1, xFilial("EK9")) //EK9_FILIAL
    oQuery:SetString( 2, " " ) //EK9.D_E_L_E_T_
    oQuery:SetString( 3, xFilial("SB1")) //B1_FILIAL
    oQuery:SetString( 4, " " ) //B1.D_E_L_E_T_
    oQuery:SetString( 5, xFilial("SYD")) //YD_FILIAL
    oQuery:SetString( 6, " " ) //YD.D_E_L_E_T_
    oQuery:SetString( 7, "S" ) //B1_IMPORT

    cQuery := oQuery:GetFixQuery()

    MPSysOpenQuery(cQuery, cAliasQry)
    clearTmp(cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, "NCM")

    if (cAliasQry)->(!eof())
        lRet     := .T.
        LoadNCM(cAliasQry, cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, cNCMIni)
    endif

    (cAliasNCM)->(dbSetOrder(1)) //YD_TEC
    If !Empty(cNCMIni) .And. (cAliasNCM)->(!dbSeek(cNCMIni))
        RecLock(cAliasNCM, .T.)
        (cAliasNCM)->&(cFieldMark):= cMarcaNCM
        (cAliasNCM)->(YD_TEC)     := cNCMIni
        (cAliasNCM)->(YD_DESC_P)  := Posicione("SYD", 1, xFilial("SYD") + cNCMIni, "YD_DESC_P")
        (cAliasNCM)->(MsUnlock())
        lRet     := .T.
    EndIf
    lGeraNCM := .F.
    (cAliasNCM)->(dbGoTop())

    if !empty(cAliasQry) .and. select(cAliasQry) > 0
        (cAliasQry)->(dbCloseArea())
    endif

    fwFreeObj(oQuery)
Else
    lRet := .T.
EndIf
Return lRet

/*
Função     : getPaises
Objetivo   : Função para realizar a query, de acordo com os parametros (Pergunte - EICFL101)
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function getPaises(cAliasPAIS, cFieldMark, cMarcaPAIS, cNCMIni, cNCMFim, nPaisUso, cPaisIni, cPaisFim, _aTabsPais, lGeraPais)
Local lRet       := .F.
Local cAliasQry  := ""
Local cQuery     := ""
Local oQuery     := nil
Local nI         := 1
Local lUnion     := .F.

If lGeraPais
    cAliasQry := getNextAlias()

    cQuery += " SELECT " 
    cQuery += "   COUNT(*), "
    cQuery += "   YA_CODGI, "
    cQuery += "   YA_DESCR "
    cQuery += " FROM "
    cQuery += "  ( "
    If nPaisUso == 1
        cQuery += "     SELECT "
        cQuery += "       YA_CODGI, "
        cQuery += "       YA_DESCR "
        cQuery += "     FROM "
        cQuery +=         RetSQLName("SB1") + " B1 " 
        cQuery += "       INNER JOIN " + RetSQLName("SA5") + " A5 ON ( "
        cQuery += "         A5_FILIAL = ? " 
        cQuery += "         AND A5_PRODUTO = B1_COD "
        cQuery += "         AND A5.D_E_L_E_T_ = ? "
        cQuery += "       ) "
        cQuery += "      INNER JOIN " + RetSQLName("SA2") +" A2 ON ( "
        cQuery += "        A2_FILIAL = ? " 
        cQuery += "        AND A2_COD = A5_FORNECE "
        cQuery += "        AND A2_LOJA = A5_LOJA "
        cQuery += "        AND A2.D_E_L_E_T_ = ? "
        cQuery += "      ) "
        cQuery += "      INNER JOIN " + RetSQLName("SYA") + " YA ON ( "
        cQuery += "        YA_FILIAL = ? "
        cQuery += "        AND YA_CODGI = A2_PAIS "
        cQuery += "        AND YA.D_E_L_E_T_ = ? "
        cQuery += "      ) "
        cQuery += "    WHERE "
        cQuery += "      B1_FILIAL = ? "
        If !Empty(cNCMIni)
            cQuery += "      AND B1_POSIPI >= ? "
        EndIf
        If !Empty(cNCMFim)
            cQuery += "      AND B1_POSIPI <= ? "
        EndIf 
        cQuery += "      AND A2_PAIS <> ? "
        cQuery += "      AND B1.D_E_L_E_T_ = ? "

        cQuery += "    UNION ALL "

        cQuery += "    SELECT "
        cQuery += "      YA_CODGI, "
        cQuery += "      YA_DESCR "
        cQuery += "    FROM "
        cQuery +=        RetSQLName("EKB") + " EKB "
        cQuery += "      INNER JOIN " + RetSQLName("SYA") + " YA ON ( "
        cQuery += "        EKB_FILIAL = ? " 
        cQuery += "        AND EKB_PAIS = YA_PAISDUE "
        cQuery += "		AND YA_PAISDUE <> ? "
        cQuery += "		AND EKB_PAIS <> ? "
        cQuery += "        AND EKB.D_E_L_E_T_ = ? "
        cQuery += "      ) "
        cQuery += "    WHERE "
        cQuery += "      YA_FILIAL = ? "
        cQuery += "      AND YA.D_E_L_E_T_ = ? "
        lUnion := .T.
    EndIf

    cQuery += "  ) AS TOTALPAIS "
    cQuery += " GROUP BY YA_CODGI, YA_DESCR "
    cQuery += " ORDER BY YA_CODGI "

    oQuery := FWPreparedStatement():New(cQuery)
    If nPaisUso == 1
        oQuery:SetString( nI++, xFilial("SA5") )
        oQuery:SetString( nI++, " " ) //A5.D_E_L_E_T_
        oQuery:SetString( nI++, xFilial("SA2") )
        oQuery:SetString( nI++, " " ) //A2.D_E_L_E_T_
        oQuery:SetString( nI++, xFilial("SYA") )
        oQuery:SetString( nI++, " " ) //YA.D_E_L_E_T_
        oQuery:SetString( nI++, xFilial("SB1") )
        If !Empty(cNCMIni)
            oQuery:SetString( nI++, cNCMIni )
        EndIf
        If !Empty(cNCMFim)
            oQuery:SetString( nI++, cNCMFim )
        EndIf
        oQuery:SetString( nI++, " " ) //A2_PAIS <> " "
        oQuery:SetString( nI++, " " ) //B1.D_E_L_E_T_
        oQuery:SetString( nI++, xFilial("EKB") )
        oQuery:SetString( nI++, " " ) //YA_PAISDUE <> " "
        oQuery:SetString( nI++, " " ) //EKB_PAIS <> " "
        oQuery:SetString( nI++, " " ) // EKB.D_E_L_E_T_
        oQuery:SetString( nI++, xFilial("SYA") )
        oQuery:SetString( nI++, " " ) //YA.D_E_L_E_T_
    EndIf

    cQuery := oQuery:GetFixQuery()

    MPSysOpenQuery(cQuery, cAliasQry)
    clearTmp(cAliasPAIS, cFieldMark, cMarcaPAIS, _aTabsPais)

    if (cAliasQry)->(!eof())
        lRet      := .T.
        LoadPais(cAliasQry, cAliasPAIS, cFieldMark, cMarcaPAIS, _aTabsPais)
    endif
    lGeraPais := .F.
    if !empty(cAliasQry) .and. select(cAliasQry) > 0
        (cAliasQry)->(dbCloseArea())
    endif

    fwFreeObj(oQuery)
Else
    lRet := .T.
EndIf
Return lRet

/*
Função     : LoadPais
Objetivo   : Função para carregar os países do resultado da query no arquivo temporario no banco
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function LoadPais(cAliasQry, cAliasPAIS, cFieldMark, cMarcaPAIS, _aTabsPais)
Local aStruct    := {}
Local nCpo

//clearTmp(cAliasPAIS, cFieldMark, cMarcaPAIS, _aTabsPais)
aStruct := (cAliasPAIS)->(dbStruct())

(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!EOF())

    RecLock(cAliasPAIS, .T.)
    For nCpo := 1 To Len(aStruct)
        If aStruct[nCpo][1] == cFieldMark
            (cAliasPAIS)->&(cFieldMark) := cMarcaPAIS
        Else
            (cAliasPAIS)->&(aStruct[nCpo][1]) := (cAliasQry)->&(aStruct[nCpo][1])
        EndIf
    Next
    (cAliasPAIS)->(MsUnlock())

    (cAliasQry)->(dbSkip())
End

(cAliasPAIS)->(dbGoTop())

Return

/*
Função     : LoadNCM
Objetivo   : Função para carregar as ncm do resultado da query no arquivo temporario no banco
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function LoadNCM(cAliasQry, cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, cNCMIni)
Local aStruct    := {}
Local nCpo

//clearTmp(cAliasNCM, cFieldMark, cMarcaNCM, _aTabsNCM, "NCM")
aStruct := (cAliasNCM)->(dbStruct())

(cAliasQry)->(dbGoTop())
While (cAliasQry)->(!EOF())

    RecLock(cAliasNCM, .T.)
    For nCpo := 1 To Len(aStruct)
        If aStruct[nCpo][1] <> cFieldMark
            (cAliasNCM)->&(aStruct[nCpo][1]) := (cAliasQry)->&(aStruct[nCpo][1])
        EndIf
    Next
    (cAliasNCM)->(MsUnlock())

    (cAliasQry)->(dbSkip())
End

Return

/*
Função     : createTmp
Objetivo   : Função para criação do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
Static Function createTmp(cAliasTmp, cFieldMark, cMarcaPAIS, _aTabsTmp, lResult, cTela)
Local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
Local aSemSX3    := {}
Local cArqTmp    := ""
Local cIndExt    := ""
Local cIndex1    := ""
Local cIndex2    := ""

Default lResult := .F.
Default cTela   := "PAIS"

If cTela == "PAIS"
    if Select(cAliasTmp) == 0
        aCampos := {}
        aSemSX3 := {}
        If lResult
            aAdd(aSemSX3, {"YD_TEC"     , getSX3Cache( "YD_TEC", "X3_TIPO"), getSX3Cache( "YD_TEC", "X3_TAMANHO"), getSX3Cache( "YD_TEC", "X3_DECIMAL") })
        EndIf
        aAdd(aSemSX3, {"YA_CODGI", getSX3Cache( "YA_CODGI", "X3_TIPO"), getSX3Cache( "YA_CODGI", "X3_TAMANHO"), getSX3Cache( "YA_CODGI", "X3_DECIMAL")  })
        aAdd(aSemSX3, {"YA_DESCR", getSX3Cache( "YA_DESCR", "X3_TIPO"), getSX3Cache( "YA_DESCR", "X3_TAMANHO"), getSX3Cache( "YA_DESCR", "X3_DECIMAL")  })
        aAdd(aSemSX3, {cFieldMark, "C"                                , 01                                    , 0                                       })
        If lResult
            aAdd(aSemSX3, {"EKU_FDTLGL" , getSX3Cache( "EKU_FDTLGL", "X3_TIPO") , getSX3Cache( "EKU_FDTLGL", "X3_TAMANHO")  , getSX3Cache( "EKU_FDTLGL", "X3_DECIMAL")  })
            aAdd(aSemSX3, {"EKV_TIPO"   , getSX3Cache( "EKV_TIPO", "X3_TIPO")   , 20                                        , 0                                         })
            aAdd(aSemSX3, {"EKV_TRIBUT" , getSX3Cache( "EKV_TRIBUT", "X3_TIPO") , 30                                        , 0                                         })
            aAdd(aSemSX3, {"RESULTADO"  , "C"                                   , 01                                        , 0                                         })
            aAdd(aSemSX3, {"RETORNO"    , "M"                                   , 250                                       , 0                                         })
        EndIf

        cArqTmp := e_criatrab(, aSemSX3, cAliasTmp )

        cIndExt := TEOrdBagExt()
        E_IndRegua( cAliasTmp , cArqTmp+cIndExt, "YA_CODGI")

        cIndex1 := e_create(,.F.)
        E_IndRegua( cAliasTmp , cIndex1+cIndExt, "YA_DESCR")

        cIndex2 := e_create(,.F.)
        E_IndRegua( cAliasTmp , cIndex2+cIndExt, cFieldMark)

        SET INDEX TO (cArqTmp+cIndExt),(cIndex1+cIndExt),(cIndex2+cIndExt)

        aAdd( _aTabsTmp, {cAliasTmp, cArqTmp, cIndex1, cIndex2 })
    EndIf
Else
    if Select(cAliasTmp) == 0
        aCampos := {}
        aSemSX3 := {}

        aAdd(aSemSX3, {"YD_TEC"     , getSX3Cache( "YD_TEC", "X3_TIPO")     , getSX3Cache( "YD_TEC", "X3_TAMANHO")      , getSX3Cache( "YD_TEC", "X3_DECIMAL")      })
        aAdd(aSemSX3, {"YD_DESC_P"  , getSX3Cache( "YD_DESC_P", "X3_TIPO")  , getSX3Cache( "YD_DESC_P", "X3_TAMANHO")   , getSX3Cache( "YD_DESC_P", "X3_DECIMAL")   })
        aAdd(aSemSX3, {cFieldMark   , "C"                                   , 01                                        , 0                                         })

        cArqTmp := e_criatrab(, aSemSX3, cAliasTmp )

        cIndExt := TEOrdBagExt()
        E_IndRegua( cAliasTmp , cArqTmp+cIndExt, "YD_TEC")

        cIndex1 := e_create(,.F.)
        E_IndRegua( cAliasTmp , cIndex1+cIndExt, "YD_DESC_P")

        cIndex2 := e_create(,.F.)
        E_IndRegua( cAliasTmp , cIndex2+cIndExt, cFieldMark)

        SET INDEX TO (cArqTmp+cIndExt),(cIndex1+cIndExt),(cIndex2+cIndExt)

        aAdd( _aTabsTmp, {cAliasTmp, cArqTmp, cIndex1, cIndex2 })
    EndIf
EndIf
// ------------------------------------------------------------------------

if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

return


/*
Função     : clearTmp
Objetivo   : Função limpeza do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
Static Function clearTmp(cAliasTmp, cFieldMark, cMarcaPAIS, _aTabsPais, cTela)
Default cAliasTmp := ""

If( !Empty(cAliasTmp), If( Select(cAliasTmp) > 0, (AvZap(cAliasTmp),(cAliasTmp)->(__dbZap())), createTmp(cAliasTmp, cFieldMark, cMarcaPAIS, _aTabsPais, ,cTela)), nil)

Return

/*
Função     : ViewNCM
Objetivo   : Função para apresentar o FwMarkBrowse com as NCM
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function ViewNCM(oPanel, cAliasNCM, cFieldMark, cMarcaNCM, oMrkBrNCM)
local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
local nCpo       := 0
local aStruct    := {}
local aColumns   := {}
Local aFieldFilter := {}
Local aSeek      := {}
local bMarcar    := { || MarcarPAIS( cAliasNCM, cFieldMark, cMarcaNCM,,oMrkBrNCM ), oMrkBrNCM:oBrowse:Refresh() }
local nOpc       := 0
local oLayer
local oPanel1
local oPanel2
local lRet       := .T.
If oMrkBrNCM == nil
    aRotina := {} 

    aStruct := (cAliasNCM)->(dbStruct())
    for nCpo := 1 To Len(aStruct)
        if !(aStruct[nCpo][1] $ (cFieldMark))
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
        endif
    next nCpo 

    oLayer := FWLayer():New()
    oLayer:Init(oPanel,.F.)

    oLayer:AddLine("L1",10,.F.)
    oLayer:AddLine("L2",90,.F.)
    oPanel1 := oLayer:getLinePanel("L1")
    oPanel2 := oLayer:getLinePanel("L2")

    oSayTitulo := TSay():New(5,5,{||STR0069},oPanel1,,TFont():New("Arial",,18,,.F.,,,,,.F.,.F.),,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10)//"Selecione as NCMs (Nomenclatura Comum do Mercosul) que deseja integrar. Esta escolha será a base para a criação de pares com os países selecionados na próxima etapa. Após selecionar, clique em 'Avançar' para continuar."

    // Defino os detalhes da busca do browse
    Aadd(aSeek,{getSX3Cache( "YD_TEC", "X3_TITULO"), {{"",getSX3Cache( "YD_TEC", "X3_TIPO"),getSX3Cache( "YD_TEC", "X3_TAMANHO"),0,"YD_TEC",getSX3Cache( "YD_TEC", "X3_PICTURE")}}, 1, .T.})
    Aadd(aSeek,{getSX3Cache( "YD_DESC_P", "X3_TITULO"), {{"",getSX3Cache( "YD_DESC_P", "X3_TIPO"),getSX3Cache( "YD_DESC_P", "X3_TAMANHO"),0,"YD_DESC_P",getSX3Cache( "YD_DESC_P", "X3_PICTURE")}}, 2, .T.})
    aEval((cAliasNCM)->(dbStruct()), {|x| Iif(x[1] <> cFieldMark, Aadd(aFieldFilter, {x[1], x[1], x[2], x[3], x[4], NIL}),)})

    fwFreeObj(oMrkBrNCM)
    oMrkBrNCM := FWMarkBrowse():New()
    oMrkBrNCM:SetFieldMark( cFieldMark )
    oMrkBrNCM:SetOwner( oPanel2 )
    oMrkBrNCM:SetDataTable(.T.)
    oMrkBrNCM:SetAlias( cAliasNCM )
    oMrkBrNCM:SetAllMark( bMarcar )
    oMrkBrNCM:SetMark( cMarcaNCM, cAliasNCM, cFieldMark )
    oMrkBrNCM:SetColumns( aColumns )
    oMrkBrNCM:SetMenuDef("")
    oMrkBrNCM:SetTemporary(.T.)
    oMrkBrNCM:SetWalkThru(.F.)
    oMrkBrNCM:DisableReport()
    oMrkBrNCM:DisableDetails()
    oMrkBrNCM:DisableConfig()
    oMrkBrNCM:oBrowse:SetDBFFilter(.T.)
    oMrkBrNCM:oBrowse:SetUseFilter() //Habilita a utilização do filtro no Browse
    oMrkBrNCM:oBrowse:SetFieldFilter(aFieldFilter)
    oMrkBrNCM:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
    oMrkBrNCM:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
    oMrkBrNCM:AddButton( OemTOAnsi(STR0070), { || addNewNCM( cAliasNCM, cFieldMark, cMarcaNCM, oMrkBrNCM)},, 2 ) // "Adicionar NCM"
    oMrkBrNCM:AddButton( OemTOAnsi(STR0022), { || MarcarPAIS( cAliasNCM, cFieldMark, cMarcaNCM, "M", oMrkBrNCM)},, 2 ) // "Marcar todos"
    oMrkBrNCM:AddButton( OemTOAnsi(STR0023), { || MarcarPAIS( cAliasNCM, cFieldMark, cMarcaNCM, "D", oMrkBrNCM)},, 2 ) // "Desmarcar todos"
    oMrkBrNCM:Activate()

    oMrkBrNCM:oBrowse:Refresh(.T.)
    oMrkBrNCM:oBrowse:SetFocus()

    lRet := nOpc == 1

    if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)
EndIf
Return lRet

/*
Função     : ViewPaises
Objetivo   : Função para apresentar o FwMarkBrowse com os Países
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function ViewPaises(oPanel, cAliasPAIS, cFieldMark, cMarcaPAIS, oMrkBrPAIS)
local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
local nCpo       := 0
local aStruct    := {}
local aColumns   := {}
Local aFieldFilter := {}
Local aSeek      := {}
local bMarcar    := { || MarcarPAIS( cAliasPAIS, cFieldMark, cMarcaPAIS, ,oMrkBrPAIS ), oMrkBrPAIS:oBrowse:Refresh() }
local nOpc       := 0
local oLayer
local oPanel1
local oPanel2
local lRet       := .T.

If oMrkBrPAIS == nil
    aRotina := {} 

    aStruct := (cAliasPAIS)->(dbStruct())
    for nCpo := 1 To Len(aStruct)
        if !(aStruct[nCpo][1] $ (cFieldMark))
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
        endif
    next nCpo 

    oLayer := FWLayer():New()
    oLayer:Init(oPanel,.F.)

    oLayer:AddLine("L1",10,.F.)
    oLayer:AddLine("L2",90,.F.)
    oPanel1 := oLayer:getLinePanel("L1")
    oPanel2 := oLayer:getLinePanel("L2")

    oSayTitulo := TSay():New(5,5,{||STR0021},oPanel1,,TFont():New("Arial",,18,,.F.,,,,,.F.,.F.),,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10)//"Selecione os países que deseja integrar com as NCMs selecionadas anteriormente. Esta seleção permitirá a criação de pares NCM x País, que serão processados através da API com o Portal Único. Após selecionar os países, clique em 'Avançar' para iniciar o processo de integração."

    // Defino os detalhes da busca do browse
    Aadd(aSeek,{getSX3Cache( "YA_CODGI", "X3_TITULO"), {{"",getSX3Cache( "YA_CODGI", "X3_TIPO"),getSX3Cache( "YA_CODGI", "X3_TAMANHO"),0,"YA_CODGI",getSX3Cache( "YA_CODGI", "X3_PICTURE")}}, 1, .T.})
    Aadd(aSeek,{getSX3Cache( "YA_DESCR", "X3_TITULO"), {{"",getSX3Cache( "YA_DESCR", "X3_TIPO"),getSX3Cache( "YA_DESCR", "X3_TAMANHO"),0,"YA_DESCR",getSX3Cache( "YA_CODGI", "X3_PICTURE")}}, 2, .T.})
    aEval((cAliasPAIS)->(dbStruct()), {|x| Iif(x[1] <> cFieldMark, Aadd(aFieldFilter, {x[1], x[1], x[2], x[3], x[4], NIL}),)})

    fwFreeObj(oMrkBrPAIS)
    oMrkBrPAIS := FWMarkBrowse():New()
    oMrkBrPAIS:SetFieldMark( cFieldMark )
    oMrkBrPAIS:SetOwner( oPanel2 )
    oMrkBrPAIS:SetDataTable(.T.)
    oMrkBrPAIS:SetAlias( cAliasPAIS )
    oMrkBrPAIS:SetAllMark( bMarcar )
    oMrkBrPAIS:SetMark( cMarcaPAIS, cAliasPAIS, cFieldMark )
    oMrkBrPAIS:SetColumns( aColumns )
    oMrkBrPAIS:SetMenuDef("")
    oMrkBrPAIS:SetTemporary(.T.)
    oMrkBrPAIS:SetWalkThru(.F.)
    oMrkBrPAIS:DisableReport()
    oMrkBrPAIS:DisableDetails()
    //oMrkBrPAIS:DisableFilter()
    oMrkBrPAIS:DisableConfig()
    oMrkBrPAIS:oBrowse:SetDBFFilter(.T.)
    oMrkBrPAIS:oBrowse:SetUseFilter() //Habilita a utilização do filtro no Browse
    oMrkBrPAIS:oBrowse:SetFieldFilter(aFieldFilter)
    oMrkBrPAIS:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
    oMrkBrPAIS:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
    oMrkBrPAIS:AddButton( OemTOAnsi(STR0051), { || addNewPais( cAliasPAIS, cFieldMark, cMarcaPAIS, oMrkBrPAIS)},, 2 ) // "Adicionar País"
    oMrkBrPAIS:AddButton( OemTOAnsi(STR0022), { || MarcarPAIS( cAliasPAIS, cFieldMark, cMarcaPAIS, "M", oMrkBrPAIS)},, 2 ) // "Marcar todos"
    oMrkBrPAIS:AddButton( OemTOAnsi(STR0023), { || MarcarPAIS( cAliasPAIS, cFieldMark, cMarcaPAIS, "D", oMrkBrPAIS)},, 2 ) // "Desmarcar todos"
    oMrkBrPAIS:Activate()

    oMrkBrPAIS:oBrowse:Refresh(.T.)
    oMrkBrPAIS:oBrowse:SetFocus()

    lRet := nOpc == 1

    if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)
EndIf
Return lRet

//NCM
Static Function addNewNCM( cAliasNCM, cFieldMark, cMarcaNCM, oMrkBrNCM)
Local oDlgNCM
Local oFWLayer
Local oPanelTxt
Local oPanelBtn
Local oPanelCheck
Local oBtnConfir
Local oBtnCancel
Local oText
Local oGet
Local oText1
Local oGet1
Local cGetNCM  := Space(getSX3Cache( "YD_TEC"   , "X3_TAMANHO"))
Local cGetDesc := Space(getSX3Cache( "YD_DESC_P", "X3_TAMANHO"))
Local nOpcA
Local lCheck := .T.
Local lRet   := .F.

DEFINE MSDIALOG oDlgNCM FROM 0,0 TO 200,450 TITLE OemToAnsi(STR0077) PIXEL //"Incluir NCM"

oDlgNCM:lMaximized := .F. 

oFWLayer := FWLayer():New()
oFWLayer:init(oDlgNCM)
oFWLayer:addLine("Lin01", 070, .T. )
oFWLayer:addLine("Lin03", 020, .T. )
oFWLayer:addLine("Lin04", 010, .T. )

oPanelTxt := oFWLayer:getLinePanel("Lin01")
oPanelBtn:= oFWLayer:getLinePanel("Lin03") 
oPanelCheck:= oFWLayer:getLinePanel("Lin04")

oText := TSay():New(10,05, {||STR0053}, oPanelTxt,,,,,,.T.,,,200,20) //"Código"
oGet  := TGet():New(18,05, {|u| If( PCount() == 0, cGetNCM, cGetNCM := u ) },oPanelTxt,060, 010, getSX3Cache( "YD_TEC", "X3_PICTURE"),{|| vldNCMGet(cAliasNCM, cGetNCM, @cGetDesc)},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,cGetNCM,,,,.T.)
oGet:cF3 := "SYD"

oText1 := TSay():New(35,05, {||STR0054}, oPanelTxt,,,,,,.T.,,,200,20) //"Descrição"
oGet1  := TGet():New(43,05, {|u| If( PCount() == 0, cGetDesc, cGetDesc := u ) },oPanelTxt,200, 010, getSX3Cache( "YD_DESC_P", "X3_PICTURE"),/*valid*/,,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F. ,,cGetDesc,,,,.T.)

oBtnConfir  := TButton():New(03, 05, STR0055 ,oPanelBtn,{|| If(btTdOKNCM(cGetNCM),(nOpcA := 1,oDlgNCM:End()),)}, 50 ,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
oBtnCancel  := TButton():New(03, 60, STR0056 ,oPanelBtn,{|| nOpcA := 2,oDlgNCM:End()}, 50 ,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

oCheck := TCheckBox():New(01, 05, STR0057,{|u| If(PCount()>0, lCheck:=u, lCheck) },oPanelCheck,90,5,,,,,,,,.T.,,,) //" Incluir marcado?"

ACTIVATE MSDIALOG oDlgNCM CENTERED
If nOpcA == 1 //Confirmar
    incNewNCM(cGetNCM, cGetDesc, cAliasNCM, cFieldMark, cMarcaNCM, oMrkBrNCM, lCheck)
    lRet := .T.
Else//Cancelar
    lRet := .F.
EndIf
fwFreeObj(oDlgNCM)
Return

Static Function btTdOKNCM(cNCM)
Local lRet := .T.
If !Empty(cNCM)
    lRet := .T.
Else
    EasyHelp(STR0071, STR0015, STR0072) // "Não é possível incluir uma NCM em branco."###"Atenção"###"Informe o código da NCM."
    lRet := .F.
EndIf
Return lRet

Static Function vldNCMGet(cAliasNCM, cNCM, cDesc)
Local lRet := .T.

If Vazio(cNCM) .Or. ExistCpo("SYD", cNCM, 1)
    lRet := .T.
    If !Empty(cNCM)
        cDesc := Posicione("SYD", 1, xFilial("SYD") + cNCM, "YD_DESC_P")
    Else
        cDesc := Space(getSX3Cache( "YD_DESC_P", "X3_TAMANHO"))
    EndIf
Else
    lRet := .F.
EndIf

(cAliasNCM)->(dbSetOrder(1))
If lRet .And. !Empty(cNCM) .And. (cAliasNCM)->(dbSeek(cNCM))
    lRet := .F.
    EasyHelp(STR0073, STR0015, STR0074) // "NCM informada já está na lista de NCMs."###"Atenção"###"Informe uma NCM que ainda não esteja na lista de NCMs."
EndIf

Return lRet

Static Function incNewNCM(cNCM, cDesc, cAliasNCM, cFieldMark, cMarcaNCM, oMrkBrNCM, lCheck)
RecLock(cAliasNCM,.T.)
(cAliasNCM)->YD_TEC     := cNCM
(cAliasNCM)->YD_DESC_P  := cDesc
If lCheck
    (cAliasNCM)->&(cFieldMark) := cMarcaNCM
Else
    (cAliasNCM)->&(cFieldMark) := " "
EndIf
(cAliasNCM)->(MsUnLock())

oMrkBrNCM:Refresh(.T.)
Return

//PAIS
Static Function addNewPais( cAliasPAIS, cFieldMark, cMarcaPAIS, oMrkBrPAIS)
Local oDlgPais
Local oFWLayer
Local oPanelTxt
Local oPanelBtn
Local oPanelCheck
Local oBtnConfir
Local oBtnCancel
Local oText
Local oGet
Local oText1
Local oGet1
Local cGetPais := Space(getSX3Cache( "YA_CODGI", "X3_TAMANHO"))
Local cGetDesc := Space(getSX3Cache( "YA_DESCR", "X3_TAMANHO"))
Local nOpcA
Local lCheck := .T.
Local lRet   := .F.

DEFINE MSDIALOG oDlgPais FROM 0,0 TO 200,450 TITLE OemToAnsi(STR0052) PIXEL //"Incluir País"

oDlgPais:lMaximized := .F. 

oFWLayer := FWLayer():New()
oFWLayer:init(oDlgPais)
oFWLayer:addLine("Lin01", 070, .T. )
oFWLayer:addLine("Lin03", 020, .T. )
oFWLayer:addLine("Lin04", 010, .T. )

oPanelTxt := oFWLayer:getLinePanel("Lin01")
oPanelBtn:= oFWLayer:getLinePanel("Lin03") 
oPanelCheck:= oFWLayer:getLinePanel("Lin04")

oText := TSay():New(10,05, {||STR0053}, oPanelTxt,,,,,,.T.,,,200,20) //"Código"
oGet  := TGet():New(18,05, {|u| If( PCount() == 0, cGetPais, cGetPais := u ) },oPanelTxt,060, 010, getSX3Cache( "YA_CODGI", "X3_PICTURE"),{|| vldPaisGet(cAliasPAIS, cGetPais, @cGetDesc)},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,cGetPais,,,,.T.)
oGet:cF3 := "SYA"

oText1 := TSay():New(35,05, {||STR0054}, oPanelTxt,,,,,,.T.,,,200,20) //"Descrição"
oGet1  := TGet():New(43,05, {|u| If( PCount() == 0, cGetDesc, cGetDesc := u ) },oPanelTxt,150, 010, getSX3Cache( "YA_DESCR", "X3_PICTURE"),/*valid*/,,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F. ,,cGetDesc,,,,.T.)

oBtnConfir  := TButton():New(03, 05, STR0055 ,oPanelBtn,{|| If(btTdOK(cGetPais),(nOpcA := 1,oDlgPais:End()),)}, 50 ,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
oBtnCancel  := TButton():New(03, 60, STR0056 ,oPanelBtn,{|| nOpcA := 2,oDlgPais:End()}, 50 ,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"

oCheck := TCheckBox():New(01, 05, STR0057,{|u| If(PCount()>0, lCheck:=u, lCheck) },oPanelCheck,90,5,,,,,,,,.T.,,,) //" Incluir marcado?"

ACTIVATE MSDIALOG oDlgPais CENTERED
If nOpcA == 1 //Confirmar
    incNewPais(cGetPais, cGetDesc, cAliasPAIS, cFieldMark, cMarcaPAIS, oMrkBrPAIS, lCheck)
    lRet := .T.
Else//Cancelar
    lRet := .F.
EndIf
fwFreeObj(oDlgPais)
Return

Static Function btTdOK(cPais)
Local lRet := .T.
If !Empty(cPais)
    lRet := .T.
Else
    EasyHelp(STR0058, STR0015, STR0059) // "Não é possível incluir um país em branco."###"Atenção"###"Informe o código do País."
    lRet := .F.
EndIf
Return lRet

Static Function vldPaisGet(cAliasPais, cPais, cDesc)
Local lRet := .T.

If Vazio(cPais) .Or. ExistCpo("SYA", cPais, 1)
    lRet := .T.
    If !Empty(cPais)
        cDesc := Posicione("SYA", 1, xFilial("SYA") + cPais, "YA_DESCR")
    Else
        cDesc := Space(getSX3Cache( "YA_DESCR", "X3_TAMANHO"))
    EndIf
Else
    lRet := .F.
EndIf

(cAliasPais)->(dbSetOrder(1))
If lRet .And. !Empty(cPais) .And. (cAliasPAIS)->(dbSeek(cPais))
    lRet := .F.
    EasyHelp(STR0060, STR0015, STR0061) // "País informado já está na lista de países."###"Atenção"###"Informe um país que ainda não esteja na lista de países."
EndIf

Return lRet

Static Function incNewPais(cPais, cDesc, cAliasPAIS, cFieldMark, cMarcaPAIS, oMrkBrPAIS, lCheck)
RecLock(cAliasPAIS,.T.)
(cAliasPAIS)->YA_CODGI      := cPais
(cAliasPAIS)->YA_DESCR      := cDesc
If lCheck
    (cAliasPAIS)->&(cFieldMark) := cMarcaPAIS
Else
    (cAliasPAIS)->&(cFieldMark) := " "
EndIf
(cAliasPAIS)->(MsUnLock())

oMrkBrPAIS:Refresh(.T.)
Return

/*
Função     : MarcarPAIS
Objetivo   : Função para marcar os Países
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function MarcarPAIS(cAliasPAIS, cFieldMark, cMarcaPAIS, cOpc, oMrkBrPAIS)
Local cMarca     := ""
Local lMarcados  := .T.
Local nPosPAIS   := 0

Default cOpc := ""

nPosPAIS := (cAliasPAIS)->(Recno())

If Empty(cOpc)
    (cAliasPAIS)->(dbGoTop())
    While (cAliasPAIS)->(!EOF())
        lMarcados := !Empty((cAliasPAIS)->&(cFieldMark))
        If !lMarcados
            Exit
        EndIf
        (cAliasPAIS)->(dbSkip())
    End
endif

cMarca := If( Empty(cOpc), If( lMarcados, " ", cMarcaPAIS), If(cOpc=="M", cMarcaPAIS, " "))

(cAliasPAIS)->(dbGoTop())
While (cAliasPAIS)->(!EOF())
    RecLock(cAliasPAIS,.F.)
    (cAliasPAIS)->&(cFieldMark) := cMarca
    (cAliasPAIS)->(MsUnLock())
    (cAliasPAIS)->(dbSkip())
End

(cAliasPAIS)->(dbGoTo(nPosPAIS))
oMrkBrPAIS:Refresh(.T.)

Return .T.


/*
Função     : ViewResul
Objetivo   : Função para o resultado final do processamento
Retorno    : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function ViewResul(oPanel, cAliasPAIS, cAliasNCM, cFieldMark, cNCMIni, cNCMFim, lOpcionais, cAliasTela, _aTabsRes)
Local oProc      := nil
Local cAliasExec := GetNextAlias()
Local oResult    := nil

(cAliasPAIS)->(dbGoTop())
FWMsgRun(, {|oSay| getRegInt(@cAliasExec, cAliasPAIS, cAliasNCM) }, STR0027, STR0028) //"Integração de Regime Tributário"###Separando os países selcionados

If (cAliasExec)->(!EOF())
    createTmp(cAliasTela, cFieldMark, , _aTabsRes, .T.)
    montaResult(oPanel, @oResult, cAliasTela, cFieldMark)
    oProc := MsNewProcess():New({|lEnd| PrcRegTrib(@lEnd, oResult, cAliasExec, cAliasTela, cFieldMark, @oProc, cNCMIni, cNCMFim, lOpcionais)}, STR0029,,.T.) //"Integrando Regimes Tributários...."
    oProc:Activate()
    (cAliasTela)->(dbGoTop())
EndIf

(cAliasPAIS)->(dbGoTop())

Return

Static Function montaResult(oPanel, oResult, cAliasTmp, cFieldMark)
local nCpo       := 0
local aStruct    := {}
local aColumns   := {}
Local aFieldFilter := {}
Local aSeek      := {}
local oLayer
local oPanel1
local oPanel2
local oSayTitulo
local oSayTitulo1
local lIntgProd  := EasyGParam("MV_EIC0074",.F.,"1") == "1"
local cTexto     := ""
Local cLib       := ""

aStruct := (cAliasTmp)->(dbStruct())
for nCpo := 1 To Len(aStruct)
    if !(aStruct[nCpo][1] $ (cFieldMark +"||RESULTADO"))
        aAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
        aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
        aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
        if aStruct[nCpo][1] == "RETORNO"
            aColumns[Len(aColumns)]:SetTitle(STR0078)//Mensagem
            aColumns[Len(aColumns)]:SetDoubleClick({|| EECView((cAliasTmp)->RETORNO, "Mensagem",,,,,.T.) })//Duplo clique na coluna de mensagem
        else            
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
        endif
    endif
next nCpo 

oLayer := FWLayer():New()
oLayer:Init(oPanel,.F.)

oLayer:AddLine("L1",10,.F.)
oLayer:AddLine("L2",90,.F.)
oPanel1 := oLayer:getLinePanel("L1")
oPanel2 := oLayer:getLinePanel("L2")

GetRemoteType(@cLib)
cTexto := STR0048 + if(lIntgProd, STR0049, STR0050) //Integração realizada no ambiente de: ###Produção###Validação
If 'HTML' $ cLib
    cTexto := "<!DOCTYPE html><html lang='pt-BR'><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'><title>Integração</title><style>body { font-family: Arial, sans-serif; font-size: 18px; } .bold { font-weight: bold; }</style></head><body><p>" + STR0048 + "<span class='bold'>"+if(lIntgProd, STR0049, STR0050)+"</span></p></body></html>" //'Integração realizada no ambiente de: '###Produção###Validação
EndIf
oSayTitulo  := TSay():New(10,5,{|| cTexto},oPanel1,,TFont():New("Arial",,18,,.F.,,,,,.F.,.F.,,,,,,,,,.T.),,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //"Integração realizada no ambiente de: "
oSayTitulo1 := TSay():New(5,5,{|| STR0033},oPanel1,,TFont():New("Arial",,18,,.F.,,,,,.F.,.F.),,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //"Resultado da integração"

// Defino os detalhes da busca do browse
Aadd(aSeek,{getSX3Cache( "YA_CODGI", "X3_TITULO"), {{"",getSX3Cache( "YA_CODGI", "X3_TIPO"),getSX3Cache( "YA_CODGI", "X3_TAMANHO"),0,"YA_CODGI",getSX3Cache( "YA_CODGI", "X3_PICTURE")}}, 1, .T.})
Aadd(aSeek,{getSX3Cache( "YA_DESCR", "X3_TITULO"), {{"",getSX3Cache( "YA_DESCR", "X3_TIPO"),getSX3Cache( "YA_DESCR", "X3_TAMANHO"),0,"YA_DESCR",getSX3Cache( "YA_CODGI", "X3_PICTURE")}}, 2, .T.})
aEval((cAliasTmp)->(dbStruct()), {|x| Iif(x[1] $ "YA_CODGI|YA_DESCR", Aadd(aFieldFilter, {x[1], x[1], x[2], x[3], x[4], NIL}),)})

fwFreeObj(oResult)
oResult := FWmBrowse():New()
oResult:SetProfileID( 'RESULTADO' )
oResult:SetDataTable()
oResult:SetOwner( oPanel2 )
oResult:SetAlias( cAliasTmp )
oResult:AddLegend("RESULTADO == '0' ","BR_AMARELO"  , STR0030) // "Integração em andamento"
oResult:AddLegend("RESULTADO == '1' ","ENABLE"      , STR0031) // "Inclusão realizada com sucesso"
oResult:AddLegend("RESULTADO == '2' ","DISABLE"     , STR0032) // "Falha na integração"
oResult:SetColumns( aColumns )
oResult:SetMenuDef( "" )
oResult:DisableConfig()
oResult:DisableReport()
oResult:DisableDetails()
oResult:Activate()

Return

/*
Função     : PrcRegTrib
Objetivo   : Separar os dados de ncm e pais para inicio da integração com o portal único
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
*/
static function PrcRegTrib(lEnd, oResult, cAliasExec, cAliasTela, cFieldMark, oProc, cNCMIni, cNCMFim, lOpcionais)
local cMsgError  := ""
Local cURLPortal := ""
Local lCancelou  := .F.
Local cURLTTCE   := "/ttce/api/ext/tratamentos-tributarios/importacao/"
Local cJson      := ""
Local oEasyJS    := nil
Local cErros     := ""
Local cMsg       := ""
Local cRetInteg  := ""
Local cRetIntOpc := ""
Local lRet       := .F.
Local oRegTrib   := JsonObject():New()
//Local oRegTribOp := JsonObject():New()
local oQuebraOpc
Local aOpcionais := {}
Local nI
Local nAcima
//Local nAbaixo
Local oModelo    := nil
Local cParseJson := ""
Local nRecResult := 0
local aListaOpc:= {}
local nTentativa:=0
local nLimite:= getLimite(nTentativa)
local cNcmPais:=""

If (cAliasExec)->(!EOF())
    nAcima := (cAliasExec)->(TotalRows)

    Begin Sequence
        cURLPortal := AVgetUrl(, , @lCancelou, "EIC")
        If lCancelou
            lRet := .F.
            break
        EndIf
        
        lRet:= ConnectPU(@oEasyJS, @cURLPortal)

        If lRet
			oProc:SetRegua1(nAcima)
			while (cAliasExec)->(!eof())

				/******
                **** tentar quebrar em funções específicas ****

                Primeiro processamento:
                Integração da lista de fundamentos legais
                *****/
                if ( lEnd .Or. !lRet, myExit(), nil )
				aListaOpc:= {}
                cNcmPais := Alltrim(TRANSFORM(((cAliasExec)->(YD_TEC)), GETSX3CACHE("YD_TEC","X3_PICTURE"))) + "/" + Alltrim((cAliasExec)->(YA_DESCR))
				oProc:IncRegua1(STR0036 + cNcmPais) //"Integrando NCM/PAÍS: "
				oModelo := FwLoadModel("EICFL100")

				cJson := getJsonRT(.F., (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), "I",, aListaOpc)
				cErros:= ""
				cRetInteg:= ""

				FWMsgRun(, {|oSay| cRetInteg := intRegimes(@oEasyJS, @cErros, (cURLPortal + cURLTTCE), cJson) }, STR0079 + " - " + cNcmPais, STR0086) //"Aguarde"###"Solicitando ao Portal Único os Fundamentos Legais"

				If Empty(cRetInteg) .Or. !Empty(cErros)
					If Empty(cRetInteg)
						If (!Empty(cErros), (cErros := STR0075 + " " + cErros),(cErros := STR0075)) //"Integração sem retorno."####//"Integração sem retorno."
					EndIf
				EndIf

                If Empty(cErros)

                    /******
                    **** tentar quebrar em funções específicas ****

                    Segundo processamento:
                    Integração da lista de fundamentos legais opcionais
                    *****/
					//objeto para agrupar os retornos e agregar os atrituvos dos fundamentos opcionais
					oRegTrib:= JsonObject():new()
                    cParseJson:= oRegTrib:FromJson(cRetInteg)

                    cErros := if( !valtype(cParseJson) == "U", STR0037 + ENTER + ENTER + cParseJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
                    If( Empty(cErros) .And. oRegTrib:hasProperty("message") .And. !Empty(oRegTrib["message"]), cErros := oRegTrib["message"], nil)
                    If Empty(cErros)
                        If lOpcionais //Verifica se deve integrar os opicionais
                            //Monta json com a lista de Arrays dos opcionais
                            //oRegTribOp := JsonObject():new()
                            oQuebraOpc := JsonObject():New()
                            oQuebraOpc["fundamentosSemAtributos"] := {}
                            oQuebraOpc["fundamentosOpcionaisDisponiveis"] := {}
                            If oRegTrib:hasProperty("fundamentosOpcionaisDisponiveis") .And. Len(oRegTrib["fundamentosOpcionaisDisponiveis"]) > 0
                                oProc:SetRegua2(Len(oRegTrib["fundamentosOpcionaisDisponiveis"]))
                                getRegimes(@oModelo, @oProc, @oEasyJS, oResult, @cAliasTela, nRecResult, @oRegTrib, @oQuebraOpc, cAliasExec, @cErros, cURLPortal+cURLTTCE, @aListaOpc, @cRetIntOpc, @cParseJson, @nLimite, nTentativa, cNcmPais)
                                If oQuebraOpc:hasProperty("fundamentosSemAtributos") .And. Len(oQuebraOpc["fundamentosSemAtributos"]) > 0
                                    oRegTribOp := jSonObject():New()
                                    oRegTribOp["tratamentosTributarios"] := oQuebraOpc["fundamentosSemAtributos"]
                                    aOpcionais := oRegTribOp["tratamentosTributarios"]
                                    //GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", cMsg, cErros, "0", @nRecResult)
                                    For nI := 1 To Len(aOpcionais)
                                        SetResult(oProc, oModelo, oResult, oRegTribOp, cAliasExec, cAliasTela, cMsg, cErros, @nRecResult, aOpcionais, nI)
                                    Next
                                    FreeObj(oRegTribOp)
                                EndIf
                            EndIf
                            If oRegTrib:hasProperty("tratamentosTributarios") .And. Len(oRegTrib["tratamentosTributarios"]) > 0
                                aOpcionais := oRegTrib["tratamentosTributarios"]
                                //GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", cMsg, cErros, "0", @nRecResult)
                                For nI := 1 To Len(aOpcionais)
                                    SetResult(oProc, oModelo, oResult, oRegTrib, cAliasExec, cAliasTela, cMsg, cErros, @nRecResult, aOpcionais, nI)
                                Next
                                FreeObj(oRegTribOp)
                            EndIf
                            FreeObj(oQuebraOpc)
                        EndIf
                    Else
                        cMsgError := STR0039 + Alltrim(TRANSFORM(((cAliasExec)->(YD_TEC)), GETSX3CACHE("YD_TEC","X3_PICTURE"))) + "/" + Alltrim((cAliasExec)->(YA_DESCR)) + ENTER + cErros //"Erro ao integrar NCM/PAÍS: "
                        GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "","", "", cMsg, cMsgError, , nRecResult)
                    EndIf
                Else
                    cMsgError := STR0039 + Alltrim(TRANSFORM(((cAliasExec)->(YD_TEC)), GETSX3CACHE("YD_TEC","X3_PICTURE"))) + "/" + Alltrim((cAliasExec)->(YA_DESCR)) + ENTER + cErros //"Erro ao integrar NCM/PAÍS: "
                    GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "","", "", cMsg, cMsgError, , nRecResult)
                EndIf
                cMsgError := ""
                cErros     := ""
                nRecResult:= 0
                (cAliasExec)->(dbSkip())
            end
        EndIf
    End Sequence
			
    (cAliasTela)->(dbGoTop())
    If oModelo <> nil
        FreeModel(oModelo, .T.)
    EndIf
EndIf

if oEasyJS <> nil
	oEasyJS:Destroy()
endif
return .T.

Static Function SetResult(oProc, oModelo, oResult, oRegTribOp, cAliasExec, cAliasTela, cMsg, cErros, nRecResult, aOpcionais, nI)
oProc:IncRegua2(STR0038 + Lower(aOpcionais[nI]['fundamentoLegal']['nome'])) //"Integrando fundamento opcional: "
GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), aOpcionais[nI]['fundamentoLegal']['codigo'], aOpcionais[nI]['tributo']['codigo'], aOpcionais[nI]['fundamentoLegal']['tipo'], cMsg, cErros, "0", @nRecResult)
If MygetModel(@oModelo, aOpcionais[nI]['fundamentoLegal']['codigo'], @cErros)
    If Empty(cErros)
        If oRegTribOp:hasProperty("tratamentosTributarios") .And. Len(oRegTribOp["tratamentosTributarios"]) > 0
            //Grava EKU/EKV - Fundamentos Opcionais
            GrvDados(@oModelo, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), oRegTribOp["tratamentosTributarios"][nI], @cErros)
        EndIf
    EndIf
    If Empty(cErros)
        GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "", "", STR0031, cErros, , nRecResult) //Integração realizada com sucesso
    Else
        GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", "", cErros, , nRecResult)
    EndIf
    (cAliasTela)->(dbGoTo(nRecResult))
    nRecResult  := 0
    cErros      := ""
    FreeModel(oModelo, .F.)
endIf
Return

Static Function getRegimes(oModelo, oProc, oEasyJS, oResult, cAliasTela, nRecResult, oRegTrib, oQuebraOpc, cAliasExec, cErros, cUrl, aListaOpc, cRetIntOpc, cParseJson, nLimite, nTentativa, cNcmPais)
local nCont
local lRet
local cPos
local oFLOpc
local cMsg := ""
local oRegTribOp
local oNextTent
local nI
local aOpcionais
local cRetJson
//local nQtsFLNoAt

aListaOpc:= {}
oQuebraOpc['listaOpcionais'] := jSonObject():new()
GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", cMsg, cErros, "0", @nRecResult)
FWMsgRun(, {|oSay| getJsonRT(.T., (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), "I", oRegTrib, aListaOpc, nLimite, @oQuebraOpc) }, STR0079, STR0080) //"Aguarde"###"Separando fundamentos opcionais"

for nCont:= 1 to len(aListaOpc)
    cJson:= aListaOpc[nCont]
    cErros:= ""
    lRet := .T.

    FWMsgRun(, {|oSay| cRetIntOpc := intRegimes(@oEasyJS, @cErros, cUrl, cJson) }, STR0079 + " - " + cNcmPais, STR0087) //"Aguarde"###"Solicitando ao Portal Único a lista de Atributos."

    If Empty(cRetIntOpc) .Or. !Empty(cErros)
        lRet := .F.
        If Empty(cRetIntOpc) .And. nTentativa < 2
            nTentativa++
            cPos := cValToChar(nCont)
            oFLOpc    := jSonObject():New()
            oNextTent := jSonObject():New()
            oFLOpc := oQuebraOpc['listaOpcionais'][cPos]
            oNextTent:FromJson(oQuebraOpc:ToJson())
            getRegimes(oModelo, @oProc, @oEasyJS, oResult, @cAliasTela, nRecResult, oFLOpc, oNextTent, cAliasExec, @cErros, cUrl, aClone(aListaOpc), cRetIntOpc, cParseJson, getLimite(nTentativa), nTentativa, cNcmPais)
            nTentativa--
            FreeObj(oFLOpc)
            FreeObj(oNextTent)
        Else
            If !Empty(cErros)
                cErros:= STR0075 + " " + cErros //"Integração sem retorno."
            Else
                cErros:= STR0075 //"Integração sem retorno."
            EndIf
            GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", "", cErros, , nRecResult)
        EndIf
    Else
        oRegTribOp := jSonObject():New()
        cRetJson := oRegTribOp:FromJson(cRetIntOpc)
        cErros := if( !valtype(cRetJson) == "U", STR0037 + ENTER + ENTER + cRetJson + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
        If Empty(cErros)									
            cErros := if( valtype(oRegTribOp) == "U", STR0037 + ENTER + ENTER + cRetIntOpc + ENTER, "" ) // "Não foi possível fazer o parse do JSON de retorno da integração."
            If Empty(cErros) .And.  oRegTribOp:hasProperty("message") .And. !Empty(oRegTribOp["message"])
                cErros := oRegTribOp["message"]
            EndIf
        EndIf
        If Empty(cErros)
            aOpcionais := oRegTribOp["tratamentosTributarios"]
            //GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", cMsg, cErros, "0", @nRecResult)
            For nI := 1 To Len(aOpcionais)
                SetResult(oProc, oModelo, oResult, oRegTribOp, cAliasExec, cAliasTela, cMsg, cErros, @nRecResult, aOpcionais, nI)
            Next
            FreeObj(oRegTribOp)
        Else
            GrvResult(oResult, @cAliasTela, (cAliasExec)->(YD_TEC), (cAliasExec)->(YA_CODGI), (cAliasExec)->(YA_DESCR), "", "" , "", "", cErros, , nRecResult)
        EndIf
    EndIf
next

Return lRet
/*
Função     : myExit
Objetivo   : 
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
static function myExit()
break; Return

/*
Função     : GrvDados
Objetivo   : Função para Efetuar as gravações no banco do retorno da integração
Autor      : THTS - Tiago Tudisco
Data/Hora  : Outubro 2024
Obs.       :
*/
Static Function GrvDados(oModelo, cNcm, cPais, jDados, cErro)
Local lRet      := .T.
Local oModEKU
Local oModEKV
Local jAtributos
Local cAtributos
Local cDecode
Local aSeek    := {}
Local cTributo := ""
Local cTipo    := ""
Local cRegime  := ""

oModEKU := oModelo:getModel("EKU_MASTER")
//O regime pode ter mais de 1 caracter conforme tabela do portal único, desta forma vamos converter sempre para 1 caracter, pois o campo regime tem tamanho 1 no protheus
//Desta forma, quando o código do regime for maior que 9, será convertido para letras. Ex: 10=A, 11=B, 12=C, 13=D
cRegime := retAsc(jDados['regime']['codigo'], 1, .T.)
lRet := oModEKU:setValue("EKU_REGIME", cRegime)

If lRet
    oModEKV := oModelo:getModel("EKVDETAIL")
    cTributo:= getTribFL(jDados['tributo']['codigo'])
    cTipo   := getTipoFL(jDados['fundamentoLegal']['tipo'], .F.)
    
    //EKV_NCM+EKV_FDTLGL+EKV_TRIBUT+EKV_PAIS
    aSeek := {{"EKV_NCM", cNcm},{"EKV_FDTLGL", jDados['fundamentoLegal']['codigo']},{"EKV_TRIBUT", cTributo},{"EKV_PAIS", cPais}}
    If !oModEKV:SeekLine(aSeek) .And. (oModEKV:GetLine() != 1 .Or. (oModEKV:GetLine() == 1 .And. !Empty(oModEKV:getValue("EKV_FDTLGL"))))
        oModEKV:AddLine()
    EndIf
    lRet := lRet .And. oModEKV:setValue("EKV_NCM"       , cNcm)
    lRet := lRet .And. oModEKV:setValue("EKV_FDTLGL"    , jDados['fundamentoLegal']['codigo'])
    lRet := lRet .And. oModEKV:setValue("EKV_TIPO"      , cTipo)
    lRet := lRet .And. oModEKV:setValue("EKV_TRIBUT"    , cTributo)
    lRet := lRet .And. oModEKV:setValue("EKV_PAIS"      , cPais)

    If jDados:hasProperty("mercadorias")
        jAtributos := JsonObject():New()
        jAtributos['mercadorias'] := jDados['mercadorias']
        cAtributos := jAtributos:toJson()
        FreeObj(jAtributos)
        cDecode    := DecodeUTF8(cAtributos)
        lRet := lRet .And. oModEKV:setValue("EKV_ATRIBU"    , IIF(Empty(cDecode), cAtributos, cDecode))
    Else
        lRet := lRet .And. oModEKV:setValue("EKV_ATRIBU"    , "")
    EndIf

    lRet := lRet .and. oModelo:VldData()
    lRet := lRet .and. oModelo:CommitData()
EndIf

If !lRet
    cErro := if( !lRet , (xError := oModelo:GetErrorMessage(),if( valtype(xError) == "C", alltrim(xError), if( valtype(xError) == "A" .and. len(xError) >= 7 ,;
            STR0040 + ": " + ENTER + alltrim(allToChar( xError[4])) +ENTER+ alltrim(allToChar( xError[5])) +ENTER+ENTER+  alltrim(allToChar( xError[6])) + " - " + if( !empty(xError[7]) , STR0041 + ": " + alltrim(allToChar( xError[7] )), "") , "") )),"") // "Problema" ### "Solução"
EndIf

Return lRet

Static Function MygetModel(oModelo, cFundLegal, cErro)
Local lRet := .F.
Default cErro := ""

EKU->(dbSetOrder(1)) //EKU_FILIAL+EKU_FDTLGL                                                                                                                                           
If EKU->(dbSeek(xFilial("EKU") + cFundLegal))
    //oModelo := FwLoadModel("EICFL100")
    oModelo:SetOperation(MODEL_OPERATION_UPDATE)
    lRet := oModelo:Activate()
Else
    cErro := STR0042 //"Fundamento Legal não cadastrado no sistema."
EndIf

Return lRet

Static Function FreeModel(oModelo, lTotal)
Default lTotal := .T.
If lTotal
    oModelo:DeActivate()
    oModelo:Destroy()
    FwFreeObj(oModelo)
Else
    oModelo:DeActivate()
EndIf
Return

Static Function GrvResult(oResult, cAliasTmp, cNcm, cPais, cDescPais, cFundLegal, cTributo, cTipoFL, cMsg, cErro, cStatus, nRecResult)
Default cStatus := ""

If nRecResult > 0
    (cAliasTmp)->(dbGoTo(nRecResult))
    RecLock(cAliasTmp, .F.)
Else
    RecLock(cAliasTmp, .T.)
EndIf

(cAliasTmp)->(YD_TEC)       := cNcm
(cAliasTmp)->(YA_CODGI)     := cPais
(cAliasTmp)->(YA_DESCR)     := cDescPais
If !Empty(cFundLegal)
    (cAliasTmp)->(EKU_FDTLGL) := cFundLegal
EndIf
If !Empty(cTributo)
    (cAliasTmp)->(EKV_TRIBUT) := getTribFL(cTributo, .T.)
EndIf
If !Empty(cTipoFL)
    (cAliasTmp)->(EKV_TIPO)   := cTipoFL
EndIf
If !Empty(cStatus)
    (cAliasTmp)->(RESULTADO):= cStatus
    (cAliasTmp)->(RETORNO)  := STR0030 //"Integração em andamento"
ElseIf Empty(cErro)
    (cAliasTmp)->(RESULTADO):= "1" //OK
    (cAliasTmp)->(RETORNO)  := cMsg
Else
    (cAliasTmp)->(RESULTADO):= "2" //Erro
    (cAliasTmp)->(RETORNO)  := cErro
EndIf

(cAliasTmp)->(MsUnlock())
nRecResult := (cAliasTmp)->(Recno())

//(cAliasTmp)->(dbGoTop())
oResult:Refresh(.T.)

Return

Static Function vldPaises(cTela, cAliasPAIS, cFieldMark, cMarcaPAIS)
Local lRet := .T.
Local aArea:= (cAliasPAIS)->(getArea())

(cAliasPAIS)->(dbSetOrder(3)) //REG_MARCA
If (cAliasPAIS)->(dbSeek(cMarcaPAIS))
    lRet := MsgYesNo(STR0043, STR0017)//Deseja iniciar o processo de integração dos Regimes Tributários?###"Integração de Regime Tributário"
Else
    lRet := .F.
    EasyHelp(STR0044, STR0015, STR0045) // "Não é possível prosseguir com a integração, pois nenhum País foi selecionado."###"Atenção"###"Marque ao menos um país para prosseguir."
EndIf

RestArea(aArea)
Return lRet

Static Function getRegInt(cAliasExec, cAliasPAIS, cAliasNCM)
Local cQuery := ""
Local oQuery

cQuery += " SELECT  "
cQuery += "     YD.YD_TEC,  "
cQuery += "     PAIS.YA_CODGI, "
cQuery += "     PAIS.YA_DESCR, "
cQuery += "     (SELECT COUNT(*) "

    cQuery += " FROM " + TETempName(cAliasNCM) + " YD1  "
    cQuery += " CROSS JOIN " + TETempName(cAliasPAIS) + " PAIS1 "
    cQuery += " WHERE YD1.REG_MARCA      <> ? "
    cQuery += "   AND PAIS1.REG_MARCA    <> ? "
    cQuery += "   AND YD1.D_E_L_E_T_     =  ? "
    cQuery += "   AND PAIS1.D_E_L_E_T_   =  ? ) AS TotalRows "

cQuery += " FROM " + TETempName(cAliasNCM) + " YD  "
cQuery += " CROSS JOIN " + TETempName(cAliasPAIS) + " PAIS "
cQuery += " WHERE YD.REG_MARCA      <>  ? "
cQuery += "   AND PAIS.REG_MARCA    <> ? "
cQuery += "   AND YD.D_E_L_E_T_     =  ? "
cQuery += "   AND PAIS.D_E_L_E_T_   =  ? "

oQuery := FWPreparedStatement():New(cQuery)

//SubQuery
oQuery:SetString(1, " ") //YD1.REG_MARCA
oQuery:SetString(2, " ") //PAIS.REG_MARCA
oQuery:SetString(3, " ") //YD1.D_E_L_E_T_
oQuery:SetString(4, " ") //PAIS1.D_E_L_E_T_

//Query
oQuery:SetString(5, " ") //YD.REG_MARCA
oQuery:SetString(6, " ") //PAIS.REG_MARCA
oQuery:SetString(7, " ") //YD.D_E_L_E_T_
oQuery:SetString(8, " ") //PAIS.D_E_L_E_T_

cQuery := oQuery:GetFixQuery()

MPSysOpenQuery(cQuery, cAliasExec)

fwFreeObj(oQuery)
Return

/*
Função     : eraseTmp
Objetivo   : Função para exclusão do arquivo temporario no banco
Retorno    : 
Autor      : Bruno Kubagawa
Data/Hora  : Março/2023
Obs.       :
*/
static function eraseTmp(_aTabsTmp)
local cAliasTmp  := ""
local cTabArq    := ""
local cIndex1    := ""
local cIndex2    := ""

//{cAliasTmp, cArqTmp, cIndex1, cIndex2 }
cAliasTmp   := _aTabsTmp[1][1]
cTabArq     := _aTabsTmp[1][2]
cIndex1     := if(empty(_aTabsTmp[1][3]),nil,_aTabsTmp[1][3])
cIndex2     := if(empty(_aTabsTmp[1][4]),nil,_aTabsTmp[1][4])
if select(cAliasTmp) > 0
    (cAliasTmp)->(E_EraseArq(cTabArq, cIndex1, cIndex2))
endif

aSize(_aTabsTmp, 0)
_aTabsTmp := {}

return

/*/{Protheus.doc} FL101Auth
   Função que realiza a autenticação com o siscomex
   @author THTS - Tiago Tudisco
   @since 07/10/2024
   /*/
Function FL101Auth(oEasyJS, cURLPortal)
Local lRet := .T.
Local cURLAuth   := ""


cURLAuth    := "/portal/api/autenticar"

oEasyJS:cUrl := cURLPortal+cURLAuth
oEasyJS:setTimeOut(120)
oEasyJS:AddLib( EasyAppFetch(cURLPortal+cURLAuth) )
oEasyJS:AddLib( FL101Script() )
lRet := oEasyJS:Activate(.T.)

If !lRet
    EasyHelp(STR0046, STR0015, STR0047 ) //Não foi possível realizar a autenticação com o portal único.###Atenção###Revise a conexão com o portal único.
EndIf

Return lRet

/*/{Protheus.doc} intRegimes
    Gera o script consumir o serviço do portal unico através do easyjs 
    @author THTS - Tiago Tudisco
    @since 07/10/2024
   /*/
Static Function intRegimes(oEasyJS, cErros, cUrl, cJson)
Local cRet    := ""
Local cScript := ""
local lRetornou := .T.
local nTotal    := 0
local aRetorno  := {}

begincontent var cScript

    intRegimes('%Exp:cUrl%', %Exp:cJson%, retAdvplError, retAdvplChunk)

endcontent

oEasyJS:runJS( cScript , {|x| TrataRet(x, @lRetornou, @nTotal, @aRetorno) } , {|x| cErros := x } )
oEasyJS:Wait({|| !lRetornou .or. (nTotal > 0 .and. Len(aRetorno) >= nTotal) }) 
cRet := ""
AEVAL(aRetorno,{ |x| cRet += x} )

return cRet

static function TrataRet(cRetorno, lRetornou, nTotal, aRet)
local cRet := cRetorno
local oJsonRet := nil
lRetornou := "isChunked" $ cRet
if "isChunked" $ cRet
    oJsonRet := jSonObject():New()
    oJsonRet:FromJson(cRet)
    nTotal := oJsonRet["totalChunks"]
    aAdd( aRet, oJsonRet["data"] )
endif

return 

/*/{Protheus.doc} FL101Script
   Gera o script consumir o serviço do portal unico através do easyjs 
   @author THTS - Tiago Tudisco
   @since 07/10/2024
   @version 1
   /*/
static function FL101Script()
   Local cVar

   begincontent var cVar
   
      function intRegimes(cUrl, sBody, retAdvplError, retAdvplChunk) {
         EasyFetch( retAdvplError, cUrl, 'POST', sBody)
         .then( (res) => res.text() )
         .then( (res) => {
            //const maxChunkSize = 500 * 1024; // 500 KB
            const maxChunkSize = 50 * 1024; // 50 KB
                const chunks = [];
                for (let i = 0; i < res.length; i += maxChunkSize) {
                    chunks.push(res.substring(i, i + maxChunkSize));
                }
                
                // Retorna o primeiro chunk com metadados
                const response = {
                    isChunked: true,
                    totalChunks: chunks.length,
                    currentChunk: 1,
                    data: chunks[0]
                };
                retAdvplChunk(JSON.stringify(response));
                
                // Envia os chunks restantes
                for (let i = 1; i < chunks.length; i++) {
                    setTimeout(() => {
                        const chunkResponse = {
                            isChunked: true,
                            totalChunks: chunks.length,
                            currentChunk: i + 1,
                            data: chunks[i]
                        };
                        retAdvplChunk(JSON.stringify(chunkResponse));

                    }, i * 100); // Delay de 100ms entre chunks
                }
          })
         .catch((e) => { retAdvplError(e) });
      }
   endcontent

Return cVar

/*/{Protheus.doc} getJsonRT
   Monta o Json de integracao
   @author THTS - Tiago Tudisco
   @since 07/10/2024
   @version 1
   /*/
Static Function getJsonRT(lOpcionais, cNcm, cPais, cTpOperaca, oRegTrib, aListaOpc, nLimite, oQuebraOpc)
Local cJson := ""
Local nI
Local cJsonCapa:= ""
Local nCont
Local lFecharJson:= .F.
Local lPossuiOpcionais:= .F.
Local oFundOpc
Local lQuebra := .F.

Default lOpcionais := .F.
Default cTpOperaca := "I"
Default oRegTrib   := nil
Default nLimite:= 10000
/* Exemplo de Json para Integração de Regime Tributário 
{
"ncm": "30031012",
"codigoPais": 23,
"dataFatoGerador": "2020-12-20",
"tipoOperacao": "I",
"fundamentosOpcionais": [
	{
	"codigoTributo": 1,
	"codigoRegime": 1,
	"codigoFundamentoLegal": 15,
	"codigoNomenclaturaAlternativa": "38151210"
	}
]
}
*/
cJson := '{'
cJson += ' "ncm": "'            + Alltrim(cNcm)     + '" ,'
cJson += ' "codigoPais": '      + Str(Val(cPais))   + ' ,'
cJson += ' "tipoOperacao": "'   + cTpOperaca        + '" '
cJsonCapa:= cJson


If lOpcionais .And. oRegTrib <> nil .And. oRegTrib:hasProperty("fundamentosOpcionaisDisponiveis") .And. Len(oRegTrib["fundamentosOpcionaisDisponiveis"]) > 0

	lPossuiOpcionais:= .T.

	nCont:= 1
    oFundOpc := jSonObject():New()
    oFundOpc['fundamentosOpcionaisDisponiveis'] := {}
	For nI := 1 To Len(oRegTrib["fundamentosOpcionaisDisponiveis"])
        If !oRegTrib["fundamentosOpcionaisDisponiveis"][nI]:hasProperty('possuiAtributosAdicionais') .Or. oRegTrib["fundamentosOpcionaisDisponiveis"][nI]["possuiAtributosAdicionais"] == "S"
            If lFecharJson
                cJson += ','
            EndIf

            //se passou ao menos uma vez para adicionar fundamentos opcionais, deve fechar o json ao sair do laço, a menos que tenha fechado no limite de fundamentos opcionais
            If !lFecharJson
                lFecharJson:= .T.
                cJson += ' ,'
                cJson += ' "fundamentosOpcionais": ['
            EndIf

            cJson += '{'
            cJson += ' "codigoTributo": '          + oRegTrib["fundamentosOpcionaisDisponiveis"][nI]["tributo"]["codigo"]           + ' ,'
            cJson += ' "codigoRegime": '           + oRegTrib["fundamentosOpcionaisDisponiveis"][nI]["regime"]["codigo"]            + ' ,'
            cJson += ' "codigoFundamentoLegal": '  + Str(Val(oRegTrib["fundamentosOpcionaisDisponiveis"][nI]["fundamentoLegal"]["codigo"]))
            cJson += '}'


            //quando atingir o limite, fecha um ciclo de requisições e abre outro
            //a variável lFecharJson é setada como falso, caso o número de fundamentos legais seja o mesmo que o limite estabelecido
            aAdd(oFundOpc['fundamentosOpcionaisDisponiveis'], oRegTrib["fundamentosOpcionaisDisponiveis"][nI])
            if nCont >= nLimite

                nCont := 1
                cJson += ']'
                cJson += '}'
                AAdd(aListaOpc, cJson)
                cJson:= cJsonCapa
                oQuebraOpc['listaOpcionais'][cValTocHar(Len(aListaOpc))] := oFundOpc
                FreeObj(oFundOpc)
                oFundOpc := jSonObject():New()
                oFundOpc['fundamentosOpcionaisDisponiveis'] := {}
                lFecharJson:= .F.
            Else
                nCont++
            endIf
        Else
            aAdd(oQuebraOpc['fundamentosSemAtributos'], oRegTrib["fundamentosOpcionaisDisponiveis"][nI])
        EndIf
	Next
	if lFecharJson
		cJson += ']'
        lQuebra := .T.
	endIf
EndIf

//se não for a montagem do json para opcionais ou não tiver opcionais para montagem ou estiver com a flag para fechar o json
if !lOpcionais .Or. !lPossuiOpcionais .Or. lFecharJson
	cJson += '}'

	//ao menos um json no array
	AAdd(aListaOpc, cJson)
    If lQuebra
        oQuebraOpc['listaOpcionais'][cValTocHar(Len(aListaOpc))] := oFundOpc
        FreeObj(oFundOpc)
    EndIf
endIf

Return cJson

/*/{Protheus.doc} getTribFL
Faz o de/para das despesas retornadas pela integração com as despesas que temos no sistema
@author THTS - Tiago Tudisco
@since 11/10/2024
/*/
Static Function getTribFL(cCodTrib, lNome)
Local cRet := ""
Default lNome := .F.
/* Codigos retornados pelo Portal Único
Use as informações abaixo para preencher o campo "codigoTributo".
Código  Descrição
1	    IMPOSTO DE IMPORTAÇÃO
2	    IPI
3	    ANTIDUMPING
4	    CIDE COMBUSTÍVEIS
5	    MEDIDA COMPENSATÓRIA
6	    PIS IMPORTAÇÃO
7	    COFINS IMPORTAÇÃO
8	    MULTAS REGULAMENTARES
9	    SALVAGUARDA
10	    TAXA SISCOMEX
11	    IMPOSTO DE EXPORTAÇÃO
*/

Do case
    Case cCodTrib == "1"
        cRet := IIF(!lNome,"1","IMPOSTO DE IMPORTAÇÃO")
    Case cCodTrib == "2"
        cRet := IIF(!lNome,"2","IPI")
    Case cCodTrib == "3"
        cRet := IIF(!lNome,"5","ANTIDUMPING")
    Case cCodTrib == "4"
        cRet := IIF(!lNome,"0","") //CIDE COMBUSTÍVEIS
    Case cCodTrib == "5"
        cRet := IIF(!lNome,"0","")//"MEDIDA COMPENSATÓRIA"
    Case cCodTrib == "6"
        cRet := IIF(!lNome,"3","PIS IMPORTAÇÃO")
    Case cCodTrib == "7"
        cRet := IIF(!lNome,"4","COFINS IMPORTAÇÃO")
    Case cCodTrib == "8"
        cRet := IIF(!lNome,"0","")//"MULTAS REGULAMENTARES"
    Case cCodTrib == "9"
        cRet := IIF(!lNome,"0","")//"SALVAGUARDA"
    Case cCodTrib == "10"
        cRet := IIF(!lNome,"0","")//"TAXA SISCOMEX"
    Case cCodTrib == "11"
        cRet := IIF(!lNome,"0","")//"IMPOSTO DE EXPORTAÇÃO"
    OtherWise
        cRet := IIF(!lNome,"0","")
Endcase

Return cRet

/*/{Protheus.doc} getTipoFL
   Retorna a descrição ou o código do tipo de tributo
   @author THTS - Tiago Tudisco
   @since 11/10/2024
   /*/
Static Function getTipoFL(cCodTipo, lNome)
Local cRet := ""
Default lNome := .F.
/* Codigos retornados pelo Portal Único
    1=Normal, 2=Teto, 3=Opcional
*/
If lNome
    // Do case
    //     Case cCodTipo == "1"
    //         cRet := "Normal"
    //     Case cCodTipo == "2"
    //         cRet := "Teto"
    //     Case cCodTipo == "3"
    //         cRet := "Opcional"
    //     OtherWise
    //         cRet := ""
    // Endcase    
Else
    Do case
        Case Upper(cCodTipo) == "NORMAL"
            cRet := "1"
        Case Upper(cCodTipo) == "TETO"
            cRet := "2"
        Case Upper(cCodTipo) == "OPCIONAL"
            cRet := "3"
        OtherWise
            cRet := ""
    Endcase
EndIf
Return cRet


/*
Função     : geraExcel
Objetivo   : Função para gerar arquivo excel do resultado da integracao
Obs.       :
*/
Static Function geraExcel(cAliasTela)
If (cAliasTela)->(eof()) .And. (cAliasTela)->(bof())
    MsgInfo(STR0081, STR0015) //"Não é possível exportar os resultados da integração, pois não existem registros."###Atenção.
Else
    FWMsgRun(,{|| ExpExcel(cAliasTela)}, STR0033 ,STR0082) // "Resultado da integração"###"Gerando o arquivo excel."
EndIf
Return .F.
Static Function ExpExcel(cAliasTela)
Local oExcel      := FwMsExcelXlsx():New()
Local cWorksheet  := STR0083//"Log da Integração"
Local cTable      := STR0084//"Log da Integração de Regime Tributário"
Local cArquivo    := CriaTrab(Nil, .F.) + ".xlsx"
Local cTitulo     := ""
Local aStruct     := {}
Local i           := 0

// Cria a planilha e a tabela que será utilizada
oExcel:AddworkSheet(cWorksheet)
oExcel:AddTable(cWorksheet, cTable)

// Adiciona as colunas na tabela
(cAliasTela)->(dbGoTop())
aStruct := (cAliasTela)->(dbStruct())
For i := 1 To Len(aStruct)
   If !(aStruct[i][1] $ "REG_MARCA")
         cTitulo  := IIF(aStruct[i][1] == "RETORNO", STR0078, IIF(aStruct[i][1] == "RESULTADO", STR0085, RetTitle(aStruct[i][1])))//"Mensagem"###"Resultado"
         oExcel:AddColumn(cWorksheet, cTable, cTitulo)
   EndIf
Next i

// Adiciona as linhas na tabela
While (cAliasTela)->(!EoF())
    cResultado := IIF((cAliasTela)->RESULTADO == "0", STR0030, IIF((cAliasTela)->RESULTADO == "1", STR0031, STR0032)) // "Integração em andamento" // "Inclusão realizada com sucesso" // "Falha na integração"
    oExcel:Addrow(cWorksheet    , cTable, { ;
        Transform((cAliasTela)->YD_TEC, GetSx3Cache("YD_TEC", "X3_PICTURE")), ;
        (cAliasTela)->YA_CODGI  , ;
        (cAliasTela)->YA_DESCR  , ;
        (cAliasTela)->EKU_FDTLGL, ;
        (cAliasTela)->EKV_TIPO  , ;
        (cAliasTela)->EKV_TRIBUT, ;
        cResultado,               ;
        (cAliasTela)->RETORNO     ;
    })
   (cAliasTela)->(dbSkip())
EndDo

// Salva o arquivo
oExcel:Activate()
oExcel:GetXMLFile(cArquivo)
oExcel:DeActivate()
FwFreeObj(oExcel)

comex.generics.TEOpenExcel(cArquivo)

Return .F. // Retorna falso para não realizar mudanças na página


/*/{Protheus.doc} getLimite
Estabelecer o limite de fundamentos legais que serão processados por integração
@type function
@version 1.0.0
@author wilsimar
@since 1/17/2025
@param nTry, numeric, determina qual a tentativa de processamento em execução
@return variant, retorna o limite de fundamentos legais para esta tentativa de processamento
/*/
static function getLimite(nTry)
	local nLimite as numeric

	Do Case
		case nTry == 0
            nLimite:= 50
        case nTry == 1
            nLimite:= 10
        case nTry == 2
            nLimite:= 1
	Endcase

return nLimite

/*/{Protheus.doc} ConnectPU
Efetua a abertura da conexão com o Portal Único via webchannel - easyjs
@type function
@version 1.0.0
@author wilsimar
@since 1/20/2025
@param oEasyJS, object, objeto para manipulação do easyjs
@param cURLPortal, character, url de conexão com o portal único
@return logical, retorna verdadeiro se a conexão foi estabelecida com sucesso
/*/
Static Function ConnectPU(oEasyJS, cURLPortal)
	Local lRet as logical
	oEasyJS := EasyJS():New()
	FWMsgRun(, {|oSay| lRet := FL101Auth(@oEasyJS, cURLPortal) }, STR0034, STR0035) //"Conectando ao Portal Único"###"Autenticando..."
Return lRet
