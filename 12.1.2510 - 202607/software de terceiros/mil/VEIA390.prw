#include "protheus.ch"
#include "totvs.ch"
#include "VEIA390.CH"

/*/{Protheus.doc} VEIA390
	@description Schedule para processamento e envio de Estoque via email de Veiculos das Concessionarias JD

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Function VEIA390(aParam As Array)
    Local lSchedule := FwGetRunSchedule() As Logical
    Local oTProcess As Object
    Local bProcess

    if lSchedule
        VEIA390B007_ProcessaJson(aParam)
    Else
        bProcess := { || VEIA390B007_ProcessaJson(aParam)}

        oTProcess := tNewProcess():New(;
            STR0004,;				// 01 - Nome da função que está chamando o objeto.	// VEIA390
            STR0005,;				// 02 - Título da árvore de opções.	// Geração e Envio Estoque Mensal John Deere
            bProcess,;				// 03 - Bloco de execução que será executado ao confirmar a tela.
            STR0006,;				// 04 - Descrição da rotina.	// Esta rotina realiza a geração de um arquivo Json com os status de Estoque Atual e Vendas do Periodo do Mes Anterior e faz o envio por email.
            "",;					// 05 - Nome do Pergunte (SX1) a ser utilizado na rotina.
            /* aInfoCustom */ ,;	// 06 - Informações adicionais carregada na árvore de opções.
            .T.,;			        // 07 - Se .T. cria uma novo painel auxiliar ao executar a rotina.
            /* nSizePanelAux */ ,;	// 08 - Tamanho do painel auxiliar, utilizado quando lPainelAux = .T.
            /* cDescriAux */ ,;		// 09 - Descrição a ser exibida no painel auxiliar.
            .T.,;			        // 10 - Se .T. exibe o painel de execução. Se .f., apenas executa a função sem exibir a régua de processamento.
            .T.;				    // 11 - Se .T. cria apenas uma regua de processamento.
        )
    Endif
Return

/*/{Protheus.doc} VEIA390B007_ProcessaJson
	@description Faz a consulta dos veiculos em estoque e veiculos que foram vendidos no mes
    Gera o arquivo em Json e executa o envio por email

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VEIA390B007_ProcessaJson(aParam As Array)
    Local nCntFor := 0 As Numeric
    Local nCntFor2 := 0 As Numeric
    Local nTamResult := 0 As Numeric
    Local nHandle As Numeric
    Local nTamSM0 := 0 As Numeric
    Local nPos := 0 As Numeric
    Local aSM0Arr As Array
    Local aSM0Proc := {} As Array
    Local aJson := {} As Array
    Local aResProc := {} As Array
    Local dDate := (dDataBase - 1) As Date // Mes Anterior
    Local cArqFile As Charactere
    Local cMensagem As Charactere
    Local cTitEmail := "" As Charactere
    Local cEmail := GetNewPar('MV_MIL0215', 'tecnologia@assodeere.com.br') As Charactere
    Local cMonth := cValToChar(Month(dDate)) As Character
    Local cYear := cValToChar(Year(dDate)) As Charactere
    Local cFilBkp As Charactere
    Local oJson := JsonObject():New() As Object
    Local oMail As Object
    Local lSchedule := FwGetRunSchedule() As Logical

    Default aParam := {}

    cTitEmail := STR0001 //"Estoque de Veículos"

    if !lSchedule
        cGrpBkp := FwCompany()
        cFilBkp := FwxFilial()
        aadd(aParam, FwCompany())
        aadd(aParam, FwxFilial())
    Endif

    cMonth := Replicate('0', 2 - Len(cMonth)) + cMonth
    cArqFile := '\est_assod_' + cMonth + '_' + cYear + '.txt'
    
    aSM0Arr := FwLoadSM0()
    nTamSM0 := Len(aSM0Arr)

    For nCntFor := 1 to nTamSM0
        if aSM0Arr[nCntFor][1] == cEmpAnt .And. aSM0Arr[nCntFor][3] == FwCompany()
            aadd(aSM0Proc, aSM0Arr[nCntFor])
        Endif
    Next

    // Estoque executa apenas uma vez, pois VV1 é compartilhada
    aResProc := VA390B006_ProcessaEstoque(dDate)
    nTamResult := Len(aResProc[1])
    if nTamResult > 0 // houve processamento
        For nCntFor2 := 1 to nTamResult
            aadd(aJson, aResProc[1][nCntFor2])
        Next
    Endif
    aResProc := {}

    // Processa Vendas por Filial
    nTamFil := Len(aSM0Proc)
    For nCntFor := 1 to nTamFil
        cFilAnt := aSM0Proc[nCntFor][2]
        aResProc := VA390B001_ProcessaVendasPorFilial(dDate)
        nTamResult := Len(aResProc[2][1])
        if aResProc[1] .And. nTamResult > 0 // houve processamento
            For nCntFor2 := 1 to nTamResult
                aadd(aJson, aResProc[2][1][nCntFor2])
            Next
        Endif
        aResProc := {}
    Next
    
    oJson:Set(aJson)

    if Len(oJson) > 1 // se houver ao menos uma venda
        nHandle := FCreate(cArqFile, , , .F.)

        if nHandle == -1
            FWLogMsg('INFO',, 'VEIA390',,,, ' - ' + I18N("#1 #2", {STR0003, Str(FError())})) //"Erro ao criar arquivo:"
        else
            FWrite(nHandle, oJson:toJson() + CHR(13) + CHR(10))
            FClose(nHandle)

            oMail := DMS_EmailHelper():New()

            cMensagem := STR0002 + cMonth + '/' + cYear + '.' // "Estoque de Veículos referente ao mês "

            oMail:Send({;
	    		{'destino' , cEmail},;
	    		{'assunto' , cTitEmail},;
	    		{'mensagem', cMensagem},;
                {'arquivo' , cArqFile};
	    	})
        endif

        if !lSchedule
            MsgInfo(I18N(STR0007, {cEmail}), STR0008) // Json gerado e enviado para o email #1. // Arquivo Gerado!
        Endif
    Else
        if !lSchedule
            MsgInfo(STR0009, STR0010) // Não há veículos em estoque, nem houve qualquer venda. // Arquivo não foi gerado!
        Endif
    Endif

    cFilAnt := cFilBkp

    FreeObj(oJson)
    FreeObj(oMail)
    FwFreeArray(aSM0Arr)
Return

/*/{Protheus.doc} VA390B001_ProcessaVendasPorFilial
	@description Processamento por filiais, consultando os dados.

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VA390B001_ProcessaVendasPorFilial(dDate As Date) As Array
    Local cDealer As Charactere
    Local cMonth := cValToChar(Month(dDate)) As Character
    Local cYear := cValToChar(Year(dDate)) As Charactere
    Local aReturn := {} As Array

    cMonth := Replicate('0', 2 - Len(cMonth)) + cMonth
    aadd(aReturn, .F.)
    aadd(aReturn, {})
    
    cDealer := GetNewPar("MV_MIL0005", "")

    if cDealer <> "" // se nao ha dealer configurado
        FWLogMsg('INFO',, 'VA390B001',,,, 'VEIA390 - ' + I18N("Dealer #1 Mes #2 Ano #3", {cDealer, cMonth, cYear}))
        aReturn[1] := .T.
        aReturn[2] := VA390B002_LevantaDados(dDate)
    Else
        aadd(aReturn[2], {})
        aadd(aReturn[2], {})
    Endif    
Return aReturn

/*/{Protheus.doc} VA390B002_LevantaDados
	@description Faz a consulta dos veiculos em estoque e veiculos que foram vendidos no mes

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VA390B002_LevantaDados(dDate As Date) as Array
    Local cQry := "" As Charactere
    Local cQryClass := "" As Charactere
    Local cAliasRtr := "" As Charactere
    Local cMonth := cValToChar(Month(dDate)) As Charactere
    Local cYear := cValToChar(Year(dDate)) As Charactere
    Local cEstVei := "" As Charactere
    Local cNomeCom := "" As Charactere
    Local cCampos := "" As Charactere
    Local cCamposRet := "" As Charactere
    Local cCpoUltCom := "" As Charactere
    Local cQryFilter := "" As Charactere
    Local nPos := 0 As Numeric
    Local nPos2 := 0 As Numeric
    Local nTamFilCpn := 0 As Numeric
    Local nVlrVenda := 0 As Numeric
    Local nCntFor := 0 As Numeric
    Local aJson := {} As Array
    Local aRet := {} As Array
    Local aChIntFil := {} As Array
    Local lVV1UltCom := .F. As Logical
    Local cCNPJ := "" As Charactere
    Local oObjCnsVei As Object 
    Local oStatement As Object

    cMonth := Replicate('0', 2 - Len(cMonth)) + cMonth

    cCNPJ := Alltrim(FWSM0Util():GetSM0Data(,, {"M0_CGC"})[1][2])
    cNomeCom := Alltrim(FWSM0Util():GetSM0Data(,, {"M0_NOMECOM"})[1][2])    

    aFilCpny := FWLoadSM0()
    nTamFilCpn := Len(aFilCpny)

    DBSelectArea("VV1")
    lVV1UltCom := VV1->(FieldPos("VV1_ULTCOM")) > 0
    if lVV1UltCom
        cCpoUltCom := "VV1_ULTCOM,"
    Endif

    cCampos := "VV1_FILIAL,VV2_CATVEI,VE1_DESMAR,VV1_MODVEI,VV2_DESMOD,VV1_CHASSI,VV1_SITVEI,VV1_CHAINT,VV1_FABMOD,VQ0_DATPED,VV1_DTPCOM,VV1_FILENT,"+;
               cCpoUltCom + "VV1_ESTVEI,VVG_ESTVEI,VQ0_DATVEN,VVF_DATMOV,VVF_DATEMI,VV0_DATMOV,VV0_NUMNFI,VV0_SERNFI,VV0_CODCLI,VV0_LOJA,VV0_DATAPR"

    cCamposRet := "VV1_FILIAL,VV2_CATVEI,VE1_DESMAR,VV1_MODVEI,VV2_DESMOD,VV1_CHASSI,VV1_SITVEI,VV1_CHAINT,VV1_FABMOD,COALESCE(VQ0_DATPED, '') VQ0_DATPED,VV1_DTPCOM,"+;
               cCpoUltCom + "VV1_FILENT,VV1_ESTVEI,VVG_ESTVEI,COALESCE(VQ0_DATVEN, '') VQ0_DATVEN,VVF_DATMOV,VVF_DATEMI,VV0_DATMOV,VV0_NUMNFI,VV0_SERNFI,VV0_CODCLI,VV0_LOJA,VV0_DATAPR"

    oObjCnsVei := VEConsultaVeiculo():New()


    /* Movimentos de Saída - Sitvei == 1 */
    oObjCnsVei:SetCamposQuery(cCampos)
    oObjCnsVei:SetCamposRet(cCampos)

    oObjCnsVei:SetSoEstoque(.F.)
    oObjCnsVei:SetMovEntrada(.T.)
    oObjCnsVei:SetPedCompra(.T.)
    oObjCnsVei:SetMovSaida(.T.)
    oObjCnsVei:SetVendidoSitVei(.T.)
    oObjCnsVei:SetVazioSitVei(.F.)
    
    cQryFilter := ""
    cQryFilter += "   VV0_DATMOV LIKE '" + cYear + cMonth + "%' "
    cQryFilter += "   AND VV1_SITVEI = '1' "
    cQryFilter += "   AND VV0_DATMOV IS NOT NULL "
    cQryFilter += "   AND VV0_OPEMOV = 0 " // Venda
    cQryFilter += "   AND VV0_SITNFI = 1 " // Valida

    oObjCnsVei:SetFilter(cQryFilter)

    cQryClass := oObjCnsVei:GetQuery()

    cQry := " SELECT "
    cQry += "   DISTINCT VENDIDOS.*, "
    cQry += "   COALESCE(VVB_DESCRI, '') VVB_DESCRI, "
    cQry += "   COALESCE(F2_EMISSAO, '') F2_EMISSAO, "
    cQry += "   COALESCE(F2_VALBRUT, 0) F2_VALBRUT "
    cQry += " FROM "
    cQry += "   (" + cQryClass + ") AS VENDIDOS "
    cQry += " 	JOIN " + RetSqlName("SF2") + " SF2 "
    cQry += " 	ON "
    cQry += " 		SF2.F2_FILIAL = '" + FwxFilial("SF2") + "' "
    cQry += " 		AND SF2.F2_DOC = VV0_NUMNFI "
    cQry += " 		AND SF2.F2_SERIE = VV0_SERNFI "
    cQry += " 		AND SF2.F2_CLIENTE = VV0_CODCLI "
    cQry += " 		AND SF2.F2_LOJA = VV0_LOJA "
    cQry += " 		AND SF2.D_E_L_E_T_ = ' ' "
    cQry += "   LEFT JOIN " + RetSqlName("VVB") + " VVB "
    cQry += "   ON "
    cQry += "       VVB_FILIAL = '" + FwxFilial("VVB") + "' "
    cQry += "       AND VENDIDOS.VV2_CATVEI = VVB_CATVEI "
    cQry += "       AND VVB.D_E_L_E_T_ = ' ' "
    

    cAliasRtr := MpSysOpenQuery(cQry)

    (cAliasRtr)->(DbGoTop())
    While !(cAliasRtr)->(EOF())
        cCNPJ := Alltrim(FWSM0Util():GetSM0Data(,, {"M0_CGC"})[1][2])
        cNomeCom := Alltrim(FWSM0Util():GetSM0Data(,, {"M0_NOMECOM"})[1][2])

        If !Empty((cAliasRtr)->VV1_FILENT)
            nPos2 := aScan(aFilCpny, {|x| x[2] == (cAliasRtr)->VV1_FILENT})
        Endif

        aadd(aChIntFil, {(cAliasRtr)->VV1_FILIAL, (cAliasRtr)->VV1_CHAINT, (cAliasRtr)->VV1_CHASSI})

        Aadd(aJson, JsonObject():New())

        if !Empty((cAliasRtr)->VVG_ESTVEI)
            cEstVei := Alltrim((cAliasRtr)->VVG_ESTVEI)
        Else
            cEstVei := Alltrim((cAliasRtr)->VV1_ESTVEI)
        Endif

        nVlrVenda := (cAliasRtr)->F2_VALBRUT

        nPos := Len(aJson)
        if nPos2 > 0 // Caso VV1_FILENT estejam em branco, insiro informacoes da empresa principal
            aJson[nPos]['cCNPJ'] := aFilCpny[nPos2][18] //https://tdn.totvs.com/display/public/framework/FWLoadSM0
            aJson[nPos]['cNomeCom'] := aFilCpny[nPos2][17]
        Else
            aJson[nPos]['cCNPJ'] := cCNPJ
            aJson[nPos]['cNomeCom'] := cNomeCom
        Endif
        aJson[nPos]['marca'] := Alltrim((cAliasRtr)->VE1_DESMAR)
        aJson[nPos]['categoria'] := Alltrim((cAliasRtr)->VVB_DESCRI)
        aJson[nPos]['modelo'] := Alltrim((cAliasRtr)->VV2_DESMOD)

        if !Empty((cAliasRtr)->VV1_CHASSI)
            aJson[nPos]['chassiEquipamento'] := Alltrim((cAliasRtr)->VV1_CHASSI)
        Else
            aJson[nPos]['chassiEquipamento'] := Nil
        Endif

        aJson[nPos]['ID_unico'] := (cAliasRtr)->VV1_CHAINT
        aJson[nPos]['anoFabricacao'] := LEFT((cAliasRtr)->VV1_FABMOD, 4)
        aJson[nPos]['anoModelo'] := RIGHT((cAliasRtr)->VV1_FABMOD, 4)
        if !Empty((cAliasRtr)->VQ0_DATPED)
            aJson[nPos]['dataPedido'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VQ0_DATPED)
        Else
            aJson[nPos]['dataPedido'] := Nil
        Endif

        If !Empty((cAliasRtr)->VV1_DTPCOM)
            aJson[nPos]['dataPrimeiraCompra'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VV1_DTPCOM)
        Else
            aJson[nPos]['dataPrimeiraCompra'] := Nil
        Endif

        if lVV1UltCom .and. !Empty((cAliasRtr)->VV1_ULTCOM)
            aJson[nPos]['dataUltimaMovimentacaoCompra'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VV1_ULTCOM)
        else
            aJson[nPos]['dataUltimaMovimentacaoCompra'] := Nil
        endif

        aJson[nPos]['StatusEquipamento'] := VA390B004_RetornaEstVei(cEstVei)
        aJson[nPos]['EstadoEquipamento'] := VA390B005_RetornaSitVei((cAliasRtr)->VV1_SITVEI)

        if !Empty((cAliasRtr)->VV0_DATAPR)
            aJson[nPos]['dataVendidoNaoFaturado'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VV0_DATAPR)
        Else
            aJson[nPos]['dataVendidoNaoFaturado'] := Nil
        Endif

        aJson[nPos]['dataFaturamento'] := VA390B003_TransformaDataPadrao((cAliasRtr)->F2_EMISSAO)
        aJson[nPos]['valorVendaEquipamento'] := nVlrVenda
        aJson[nPos]['periodoInformacao'] := cYear + '/' + cMonth

        (cAliasRtr)->(DbSkip())
    EndDo

    aRet := {aJson, aChIntFil}

    FreeObj(oStatement)
    FreeObj(oObjCnsVei)
Return aRet

/*/{Protheus.doc} VA390B003_TransformaDataPadrao
	@description Insere '-' entre os meses e anos dos campos de data, retorna no padrao americano

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VA390B003_TransformaDataPadrao(cDate As Charactere) As Charactere
    Local cResult := "" As Charactere
    Default cDate := Space(8)
    if Len(cDate) == 8
        cResult := Left(cDate, 4) + '-' + Substring(cDate, 5, 2) + '-' + Right(cDate, 2)
    Else
        cDate := Space(8)
        cResult := Left(cDate, 4) + '-' + Substring(cDate, 5, 2) + '-' + Right(cDate, 2)
    Endif
Return cResult

/*/{Protheus.doc} VA390B004_RetornaEstVei
	@description Retorna Descricao do Estado do Veiculo de acordo com X3_CBOX do campo VV1_ESTVEI

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VA390B004_RetornaEstVei(cEstVei As Charactere) As Charactere
    Local cRetEstVei := "" As Charactere
    Local cBox := GetSX3Cache("VV1_ESTVEI", "X3_CBOX") As Charactere
    Local aBox := {} As Array
    Local nOpt := 0 As Numeric

    if cEstVei $ '0|1'

        aBox := StrTokArr(cBox, ';')
        nOpt := aScan(aBox, {|x| Left(x, 1) == cEstVei})

        if nOpt > 0
            nTamStr := Len(aBox[nOpt]) - 2
            cRetEstVei := Alltrim(Substring(aBox[nOpt], 3, nTamStr))
        Endif
    Endif
Return cRetEstVei

/*/{Protheus.doc} VA390B005_RetornaSitVei
	@description Retorna Descricao da Situacao do Veiculo de acordo com X3_CBOX do campo VV1_SITVEI

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VA390B005_RetornaSitVei(cSitVei As Charactere) As Charactere
    Local cRetSitVei := "" As Charactere
    Local cBox := GetSX3Cache("VV1_SITVEI", "X3_CBOX") As Charactere
    Local aBox := {} As Array
    Local nOpt := 0 As Numeric
    Local nTamStr := 0 As Numeric

    if cSitVei $ '0|1|2|8'
        aBox := StrTokArr(cBox, ';')
        nOpt := aScan(aBox, {|x| Left(x, 1) == cSitVei})

        if nOpt > 0
            nTamStr := Len(aBox[nOpt]) - 2
            cRetSitVei := Alltrim(Substring(aBox[nOpt], 3, nTamStr))
        Endif
    Endif
Return cRetSitVei

/*
    @description Funcao Padrao Schedule

    @type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
*/
Static Function SchedDef()
    Local aParam := {"P", "ParamDef", "", {}, "", ""}
Return aParam

/*/{Protheus.doc} VA390B006_ProcessaEstoque
	@description Faz a consulta dos veiculos em estoque e veiculos que foram vendidos no mes

	@type Function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 08/01/2026
/*/
Static Function VA390B006_ProcessaEstoque(dDate As Date) as Array
    Local cQry := "" As Character
    Local cQryClass := "" As Character
    Local cAliasRtr := "" As Character
    Local cMonth := cValToChar(Month(dDate)) As Character
    Local cYear := cValToChar(Year(dDate)) As Charactere
    Local cEstVei := "" As Charactere
    Local cNomeCom := "" As Charactere
    Local cCampos := "" As Charactere
    Local cCamposRet := "" As Charactere
    Local cCpoUltCom := "" As Charactere
    Local cQryFilter := "" As Charactere
    Local nPos := 0 As Numeric
    Local nPos2 := 0 As Numeric
    Local nCntFor := 0 As Numeric
    Local nVlrVenda := 0 As Numeric
    Local nTamFilCpn := 0 As Numeric
    Local aJson := {} As Array
    Local aRet := {} As Array
    Local aChIntFil := {} As Array
    Local aFilCpny := {} As Array
    Local lVV1UltCom := .F. As Logical
    Local cCNPJ := "" As Charactere
    Local oObjCnsVei As Object 
    Local oStatement As Object

    cMonth := Replicate('0', 2 - Len(cMonth)) + cMonth
    cCNPJ := Alltrim(FWSM0Util():GetSM0Data(,, {"M0_CGC"})[1][2])
    cNomeCom := Alltrim(FWSM0Util():GetSM0Data(,, {"M0_NOMECOM"})[1][2])    

    aFilCpny := FWLoadSM0()
    nTamFilCpn := Len(aFilCpny)

    DBSelectArea("VV1")
    lVV1UltCom := VV1->(FieldPos("VV1_ULTCOM")) > 0
    if lVV1UltCom
        cCpoUltCom := "VV1_ULTCOM,"
    Endif
    cCampos := "VV1_FILIAL,VV2_CATVEI,VE1_DESMAR,VV1_MODVEI,VV2_DESMOD,VV1_CHASSI,VV1_SITVEI,VV1_CHAINT,VV1_FABMOD,VQ0_DATPED,VV1_DTPCOM,VV1_FILENT,"+;
               cCpoUltCom + "VV1_ESTVEI,VVG_ESTVEI,VQ0_DATVEN,VVF_DATMOV,VVF_DATEMI,VVF_NUMNFI,VVF_SERNFI,VVF_CODFOR,VVF_LOJA "

    cCamposRet := "VV1_FILIAL,VV2_CATVEI,VE1_DESMAR,VV1_MODVEI,VV2_DESMOD,VV1_CHASSI,VV1_SITVEI,VV1_CHAINT,VV1_FABMOD,COALESCE(VQ0_DATPED, '') VQ0_DATPED,VV1_DTPCOM,"+;
               cCpoUltCom + "VV1_FILENT,VV1_ESTVEI,VVG_ESTVEI,COALESCE(VQ0_DATVEN, '') VQ0_DATVEN,VVF_DATMOV,VVF_DATEMI,VVF_NUMNFI,VVF_SERNFI,VVF_CODFOR,VVF_LOJA"

    oObjCnsVei := VEConsultaVeiculo():New()

    oObjCnsVei:SetCamposQuery(cCampos)
    oObjCnsVei:SetCamposRet(cCamposRet)

    oObjCnsVei:SetSoEstoque(.T.)
    oObjCnsVei:SetMovEntrada(.T.)
    oObjCnsVei:SetPedCompra(.T.)
    oObjCnsVei:SetVendidoSitVei(.F.)
    oObjCnsVei:SetVazioSitVei(.F.)
    cQryFilter := ""

    cQryFilter += " VVF_DATMOV IS NOT NULL "
    oObjCnsVei:SetFilter(cQryFilter)

    cQryClass := oObjCnsVei:GetQuery()

    // Estoque
    cQry := " SELECT "
    cQry += "   DISTINCT ESTQ.*, "
    cQry += "   COALESCE(VVB_DESCRI, '') VVB_DESCRI "
    cQry += " FROM "
    cQry += "   (SELECT "
    cQry += "       ROW_NUMBER() OVER ( PARTITION BY VV1_CHAINT ORDER BY VVF_DATMOV DESC, VVF_DATEMI DESC) CNT_CHASSI, "
    cQry += "       * "
    cQry += "   FROM "
    cQry += "       (" + cQryClass + ") AS DIST_CHASSI "
    cQry += "   ) AS ESTQ LEFT JOIN " + RetSqlName("VVB") + " VVB "
    cQry += "   ON "
    cQry += "       VVB_FILIAL = '" + FwxFilial("VVB") + "' "
    cQry += "       AND ESTQ.VV2_CATVEI = VVB_CATVEI "
    cQry += "       AND VVB.D_E_L_E_T_ = ' ' "
    cQry += " WHERE "
    cQry += "   CNT_CHASSI = 1 "
    

	cAliasRtr := MpSysOpenQuery(cQry)

    (cAliasRtr)->(DbGoTop())
    While !(cAliasRtr)->(EOF())
        Aadd(aJson, JsonObject():New())

        If !Empty((cAliasRtr)->VV1_FILENT)
            nPos2 := aScan(aFilCpny, {|x| x[2] == (cAliasRtr)->VV1_FILENT})
        Endif

        aadd(aChIntFil, {(cAliasRtr)->VV1_FILIAL, (cAliasRtr)->VV1_CHAINT, (cAliasRtr)->VV1_CHASSI})

        if !Empty((cAliasRtr)->VVG_ESTVEI)
            cEstVei := Alltrim((cAliasRtr)->VVG_ESTVEI)
        Else
            cEstVei := Alltrim((cAliasRtr)->VV1_ESTVEI)
        Endif

        nVlrVenda := FGX_VLRSUGV((cAliasRtr)->VV1_CHAINT)

        nPos := Len(aJson)
        if nPos2 > 0 // Caso VV1_FILENT estejam em branco, insiro informacoes da empresa principal
            aJson[nPos]['cCNPJ'] := aFilCpny[nPos2][18] //https://tdn.totvs.com/display/public/framework/FWLoadSM0
            aJson[nPos]['cNomeCom'] := aFilCpny[nPos2][17]
        Else
            aJson[nPos]['cCNPJ'] := cCNPJ
            aJson[nPos]['cNomeCom'] := cNomeCom
        Endif
        aJson[nPos]['marca'] := Alltrim((cAliasRtr)->VE1_DESMAR)
        aJson[nPos]['categoria'] := Alltrim((cAliasRtr)->VVB_DESCRI)
        aJson[nPos]['modelo'] := Alltrim((cAliasRtr)->VV2_DESMOD)
        if !Empty((cAliasRtr)->VV1_CHASSI)
            aJson[nPos]['chassiEquipamento'] := Alltrim((cAliasRtr)->VV1_CHASSI)
        Else
            aJson[nPos]['chassiEquipamento'] := Nil
        Endif
        aJson[nPos]['ID_unico'] := Alltrim((cAliasRtr)->VV1_CHAINT)
        aJson[nPos]['anoFabricacao'] := LEFT((cAliasRtr)->VV1_FABMOD, 4)
        aJson[nPos]['anoModelo'] := RIGHT((cAliasRtr)->VV1_FABMOD, 4)
        if !Empty((cAliasRtr)->VQ0_DATPED)
            aJson[nPos]['dataPedido'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VQ0_DATPED)
        Else
            aJson[nPos]['dataPedido'] := Nil
        Endif
        if !Empty((cAliasRtr)->VV1_DTPCOM)
            aJson[nPos]['dataPrimeiraCompra'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VV1_DTPCOM)
        Else
            aJson[nPos]['dataPrimeiraCompra'] := Nil
        Endif

        aJson[nPos]['dataUltimaMovimentacaoCompra'] := Nil
        if lVV1UltCom .and. !Empty((cAliasRtr)->VV1_ULTCOM)
            aJson[nPos]['dataUltimaMovimentacaoCompra'] := VA390B003_TransformaDataPadrao((cAliasRtr)->VV1_ULTCOM)
        Endif

        aJson[nPos]['StatusEquipamento'] := VA390B004_RetornaEstVei(cEstVei)
        aJson[nPos]['EstadoEquipamento'] := VA390B005_RetornaSitVei((cAliasRtr)->VV1_SITVEI)

        // no estoque nao envio esta informação, somente nas vendas
        aJson[nPos]['dataVendidoNaoFaturado'] := Nil
        aJson[nPos]['dataFaturamento'] := Nil

        if nVlrVenda > 0
            aJson[nPos]['valorVendaEquipamento'] := nVlrVenda
        Else
            aJson[nPos]['valorVendaEquipamento'] := Nil
        Endif
        aJson[nPos]['periodoInformacao'] := cYear + '/' + cMonth

        (cAliasRtr)->(DbSkip())
    EndDo
    
    aRet := {aJson, aChIntFil}

    FreeObj(oStatement)
    FreeObj(oObjCnsVei)
Return aRet
