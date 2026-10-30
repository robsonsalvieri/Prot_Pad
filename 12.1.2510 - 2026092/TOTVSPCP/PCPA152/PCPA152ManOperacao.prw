#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

/*/{Protheus.doc} PCPA152MANDIS
API Para manipulação dos dados das operações (SMF e HZ7)

@type  WSCLASS
@author Lucas Fagundes
@since 09/09/2026
@version P12
/*/
WSRESTFUL PCPA152MANOPERACAO DESCRIPTION "PCPA152ManOperacao" FORMAT APPLICATION_JSON
    WSDATA programacao   AS STRING  OPTIONAL
    WSDATA ordemProducao AS STRING  OPTIONAL
    WSDATA operacao      AS STRING  OPTIONAL
    WSDATA id            AS STRING  OPTIONAL

    WSMETHOD GET OPERACAO;
		DESCRIPTION STR0723; //"Retorna as informações de uma operação para edição"
		WSSYNTAX "/api/pcp/v1/PCPA152ManOperacao/{programacao}/operacoes/{ordemProducao}/{operacao}" ;
		PATH "/api/pcp/v1/PCPA152ManOperacao/{programacao}/operacoes/{ordemProducao}/{operacao}" ;
		TTALK "v1"

    WSMETHOD POST OPERACAO;
		DESCRIPTION STR0724; // "Salva as alterações de uma operação"
		WSSYNTAX "/api/pcp/v1/PCPA152ManOperacao/{programacao}/operacoes/{id}" ;
		PATH "/api/pcp/v1/PCPA152ManOperacao/{programacao}/operacoes/{id}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} CRPManutencaoOperacao
Classe para processamento da manutenção de operações.

@author Lucas Fagundes
@since 09/09/2026
@version P12
/*/
Class CRPManutencaoOperacao from LongNameClass
    Private Data cIdOper  as Character
    Private Data cProg    as Character
    Private Data nIdSVY   as Numeric
    Private Data nTamVYID as Numeric

    Public Method new(cProg, cIdOper) Constructor
    Public Method destroy()

    Public Method processSaveOperacao(oBody)
    Private Method gravaSMF(oBody)
    Private Method gravaRecursos(aRecursos)
    Private Method atualizaDatasOperacoes(cOrdem, dDataIni, dDataEnt)
    Private Method geraOcorrenciaOperacaoAlterada(cIdOper, cOrdem, cOperac)
    Private Method getSequenciaSVY()

    Static Method processGetOperacao(cProg, cOrdem, cOperac)
    Static Method getRecursosOperacao(cProg, cIdOper)
    Static Method getFerramentasOperacao(cProg, cIdOper)

EndClass

/*/{Protheus.doc} new
Método construtor da classe CRPManutencaoOperacao.

@author Lucas Fagundes
@since 15/09/2026
@version P12
@param cProg, Character, Código da programação da operação.
@param cIdOper, Character, Identificador (MF_ID) da operação.
@return Self, Object, Nova instância da classe de manutenção de operações.
/*/
Method new(cProg, cIdOper) Class CRPManutencaoOperacao

    Self:cProg    := cProg
    Self:cIdOper  := cIdOper
    Self:nTamVYID := GetSX3Cache("VY_ID", "X3_TAMANHO")

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe CRPManutencaoOperacao.

@author Lucas Fagundes
@since 15/09/2026
@version P12
@return Nil
/*/
Method destroy() Class CRPManutencaoOperacao

    Self:cProg    := Nil
    Self:cIdOper  := Nil
    Self:nTamVYID := Nil
    Self:nIdSVY   := Nil

Return Nil

/*/{Protheus.doc} GET OPERACAO /api/pcp/v1/PCPA152ManOperacao/{programacao}/operacoes/{ordemProducao}/{operacao}
Retorna as informações de uma operação para edição.

@type  WSMETHOD
@author Lucas Fagundes
@since 09/09/2026
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados.
/*/
WSMETHOD GET OPERACAO PATHPARAM programacao, ordemProducao, operacao WSSERVICE PCPA152MANOPERACAO
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManOperacao"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := CRPManutencaoOperacao():processGetOperacao(Self:programacao, Self:ordemProducao, Self:operacao)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} processGetOperacao
Processa a busca das informações de uma operação.

@author Lucas Fagundes
@since 09/09/2026
@version P12
@param cProg, Character, Código da programação que irá buscar a operação.
@param cOrdem, Character, Código da ordem que irá buscar a operação.
@param cOperac, Character, Código da operação que irá buscar.
@return aReturn, Character, Array com as informações de retorno da API.
/*/
Method processGetOperacao(cProg, cOrdem, cOperac) Class CRPManutencaoOperacao
    Local aReturn    := Array(3)
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local nPosParam  := 1
    Local oReturn    := JsonObject():New()
    Local oStatement := Nil

    cQuery += " SELECT SMF.MF_PROG, "
    cQuery +=        " SMF.MF_ID, "
    cQuery +=        " SMF.MF_OP, "
    cQuery +=        " SMF.MF_OPER, "
    cQuery +=        " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) descricao, "
    cQuery +=        " SC2.C2_PRODUTO, "
    cQuery +=        " SB1.B1_DESC, "
    cQuery +=        " SMF.MF_SALDO, "
    cQuery +=        " SMF.MF_TEMPO, "
    cQuery +=        " SMF.MF_SETUP, "
    cQuery +=        " SMF.MF_TMPFINA, "
    cQuery +=        " SMF.MF_REMOCAO, "
    cQuery +=        " SMF.MF_TPDESDO, "
    cQuery +=        " SMF.MF_DESDOBR, "
    cQuery +=        " SMF.MF_TPSOBRE, "
    cQuery +=        " SMF.MF_TEMPSOB, "
    cQuery +=        " SMF.MF_DTINI, "
    cQuery +=        " SMF.MF_DTENT, "
    cQuery +=        " SMF.MF_SEQPAI "
    cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  =  ? "
	cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
    cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
    cQuery +=     " ON SB1.B1_FILIAL  =  ? "
    cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
    cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery +=     " ON SHY.HY_FILIAL  =  ? "
	cQuery +=    " AND SHY.HY_OP      = SMF.MF_OP "
	cQuery +=    " AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
	cQuery +=    " AND SHY.HY_OPERAC  = SMF.MF_OPER  "
	cQuery +=    " AND SHY.HY_TEMPAD  <> 0 "
	cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery +=     " ON SG2.G2_FILIAL  =  ? "
	cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery +=    " AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
	cQuery +=    " AND SG2.G2_OPERAC  = SMF.MF_OPER "
	cQuery +=    " AND SHY.HY_OP IS NULL "
	cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
    cQuery += "  WHERE SMF.MF_FILIAL  =  ? "
    cQuery +=    " AND SMF.MF_PROG    =  ? "
    cQuery +=    " AND SMF.MF_OP      =  ? "
    cQuery +=    " AND SMF.MF_OPER    =  ? "
    cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:setString(nPosParam++, xFilial("SC2")) // SC2.C2_FILIAL
    oStatement:setString(nPosParam++, xFilial("SB1")) // SB1.B1_FILIAL
    oStatement:setString(nPosParam++, xFilial("SHY")) // SHY.HY_FILIAL
    oStatement:setString(nPosParam++, xFilial("SG2")) // SG2.G2_FILIAL
    oStatement:setString(nPosParam++, xFilial("SMF")) // SMF.MF_FILIAL
    oStatement:setString(nPosParam++, cProg)          // SMF.MF_PROG
    oStatement:setString(nPosParam++, cOrdem)         // SMF.MF_OP
    oStatement:setString(nPosParam++, cOperac)        // SMF.MF_OPER

    cAlias := oStatement:openAlias()

    If (cAlias)->(!EoF())

        oReturn['programacao'      ] := (cAlias)->MF_PROG
        oReturn['id'               ] := (cAlias)->MF_ID
        oReturn['ordemProducao'    ] := (cAlias)->MF_OP
        oReturn['operacao'         ] := (cAlias)->MF_OPER
        oReturn['descricaoOperacao'] := RTrim((cAlias)->descricao)
        oReturn['produto'          ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
        oReturn['saldo'            ] := (cAlias)->MF_SALDO
        oReturn['tempo'            ] := __Min2Hrs((cAlias)->MF_TEMPO, .T.)
        oReturn['setup'            ] := __Min2Hrs((cAlias)->MF_SETUP, .T.)
        oReturn['finalizacao'      ] := __Min2Hrs((cAlias)->MF_TMPFINA, .T.)
        oReturn['remocao'          ] := __Min2Hrs((cAlias)->MF_REMOCAO, .T.)
        oReturn['tipoDesdobramento'] := (cAlias)->MF_TPDESDO
        oReturn['desdobramento'    ] := (cAlias)->MF_DESDOBR
        oReturn['tipoSobreposicao' ] := (cAlias)->MF_TPSOBRE
        oReturn['sobreposicao'     ] := (cAlias)->MF_TEMPSOB
        oReturn['dataInicio'       ] := PCPConvDat((cAlias)->MF_DTINI, 5)
        oReturn['dataEntrega'      ] := PCPConvDat((cAlias)->MF_DTENT, 5)
        oReturn['ordemPai'         ] := Empty((cAlias)->MF_SEQPAI)

        oReturn['recursos'   ] := CRPManutencaoOperacao():getRecursosOperacao(cProg, oReturn['id'])
        oReturn['ferramentas'] := CRPManutencaoOperacao():getFerramentasOperacao(cProg, oReturn['id'])

    EndIf
    (cAlias)->(dbCloseArea())

    aReturn[1] := .T.
    aReturn[2] := 200
    aReturn[3] := oReturn:toJson()

    oStatement:Destroy()
    oStatement := Nil
    FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getRecursosOperacao
Retorna os recursos de uma operação.

@author Lucas Fagundes
@since 10/09/2026
@version P12
@param cProg, Character, Código da programação que será buscado os recursos.
@param cIdOper, Character, Identificador da operação que irá buscar os recursos.
@return aRecursos, Array, Array com os recursos da operação.
/*/
Method getRecursosOperacao(cProg, cIdOper) Class CRPManutencaoOperacao
    Local aRecursos  := {}
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local nPosParam  := 1
    Local oRecurso   := Nil
    Local oStatement := Nil

    cQuery += " SELECT HZ7.HZ7_SEQ, "
    cQuery +=        " HZ7.HZ7_RECURS, "
    cQuery +=        " HZ7.HZ7_CTRAB, "
    cQuery +=        " HZ7.HZ7_MAOOBR, "
    cQuery +=        " HZ7.HZ7_TEMPOR, "
    cQuery +=        " HZ7.HZ7_TEMPRE, "
    cQuery +=        " HZ7.HZ7_TIPO, "
    cQuery +=        " SH1.H1_ILIMITA, "
    cQuery +=        " CASE "
    cQuery +=            " WHEN EXISTS (SELECT 1 "
    cQuery +=                           " FROM " + RetSqlName("SVM") + " SVM "
    cQuery +=                          " WHERE SVM.VM_FILIAL  =  ? "
    cQuery +=                            " AND SVM.VM_PROG    = HZ7.HZ7_PROG "
    cQuery +=                            " AND SVM.VM_ID      = HZ7.HZ7_ID "
    cQuery +=                            " AND SVM.VM_SEQRECU = HZ7.HZ7_SEQ "
    cQuery +=                            " AND SVM.D_E_L_E_T_ = ' ') THEN 'S' "
    cQuery +=            " ELSE 'N' "
    cQuery +=         " END alocado "
    cQuery +=   " FROM " + RetSqlName("HZ7") + " HZ7 "
    cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
    cQuery +=     " ON SH1.H1_FILIAL  =  ? "
    cQuery +=    " AND SH1.H1_CODIGO  = HZ7.HZ7_RECURS "
    cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
    cQuery += "  WHERE HZ7.HZ7_FILIAL =  ? "
    cQuery +=    " AND HZ7.HZ7_PROG   =  ? "
    cQuery +=    " AND HZ7.HZ7_ID     =  ? "
    cQuery +=    " AND HZ7.D_E_L_E_T_ = ' ' "
    cQuery +=  " ORDER BY HZ7.HZ7_SEQ "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:setString(nPosParam++, xFilial("SVM")) // SVM.VM_FILIAL
    oStatement:setString(nPosParam++, xFilial("SH1")) // SH1.H1_FILIAL
    oStatement:setString(nPosParam++, xFilial("HZ7")) // HZ7.HZ7_FILIAL
    oStatement:setString(nPosParam++, cProg)          // HZ7.HZ7_PROG
    oStatement:setString(nPosParam++, cIdOper)        // HZ7.HZ7_ID

    cAlias := oStatement:openAlias()

    While (cAlias)->(!EoF())
        oRecurso := JsonObject():New()

        oRecurso['recurso'       ] := (cAlias)->HZ7_RECURS
        oRecurso['sequencia'     ] := (cAlias)->HZ7_SEQ
        oRecurso['centroTrabalho'] := (cAlias)->HZ7_CTRAB
        oRecurso['maoObra'       ] := (cAlias)->HZ7_MAOOBR
        oRecurso['tempoOriginal' ] := __Min2Hrs((cAlias)->HZ7_TEMPOR, .T.)
        oRecurso['tempoRecurso'  ] := __Min2Hrs((cAlias)->HZ7_TEMPRE, .T.)
        oRecurso['tipo'          ] := (cAlias)->HZ7_TIPO
        oRecurso['ilimitado'     ] := (cAlias)->H1_ILIMITA == "S"
        oRecurso['alocado'       ] := (cAlias)->alocado == "S"

        aAdd(aRecursos, oRecurso)

        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

    oStatement:Destroy()
    oStatement := Nil
Return aRecursos

/*/{Protheus.doc} getFerramentasOperacao
Retorna as ferramentas de uma operação.

@author Lucas Fagundes
@since 10/09/2026
@version P12
@param cProg, Character, Código da programação que será buscado as ferramentas.
@param cIdOper, Character, Identificador da operação que irá buscar as ferramentas.
@return aFerramentas, Array, Array com as ferramentas da operação.
/*/
Method getFerramentasOperacao(cProg, cIdOper) Class CRPManutencaoOperacao
    Local aFerramentas := {}
    Local cAlias       := GetNextAlias()
    Local cQuery       := ""
    Local nPosParam    := 1
    Local oFerramenta  := Nil
    Local oStatement   := Nil

    cQuery += " SELECT HZJ.HZJ_ID, "
    cQuery +=        " HZJ.HZJ_FERRAM, "
    cQuery +=        " HZJ.HZJ_QUANT, "
    cQuery +=        " HZJ.HZJ_ALTERN, "
    cQuery +=        " HZJ.HZJ_SEQUSO "
    cQuery +=   " FROM " + RetSqlName("HZJ") + " HZJ "
    cQuery += "  WHERE HZJ.HZJ_FILIAL =  ? "
    cQuery +=    " AND HZJ.HZJ_PROG   =  ? "
    cQuery +=    " AND HZJ.HZJ_OPER   =  ? "
    cQuery +=    " AND HZJ.D_E_L_E_T_ = ' ' "
    cQuery +=  " ORDER BY HZJ.HZJ_SEQUSO "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:setString(nPosParam++, xFilial("HZJ")) // HZJ.HZJ_FILIAL
    oStatement:setString(nPosParam++, cProg)          // HZJ.HZJ_PROG
    oStatement:setString(nPosParam++, cIdOper)        // HZJ.HZJ_OPER

    cAlias := oStatement:openAlias()

    While (cAlias)->(!EoF())
        oFerramenta := JsonObject():New()

        oFerramenta['id'          ] := (cAlias)->HZJ_ID
        oFerramenta['ferramenta'  ] := (cAlias)->HZJ_FERRAM
        oFerramenta['quantidade'  ] := (cAlias)->HZJ_QUANT
        oFerramenta['alternativa' ] := (cAlias)->HZJ_ALTERN == EH_ALTERNATIVA
        oFerramenta['sequenciaUso'] := (cAlias)->HZJ_SEQUSO

        aAdd(aFerramentas, oFerramenta)

        (cAlias)->(dbSkip())
    End
    (cAlias)->(dbCloseArea())

    oStatement:Destroy()
    oStatement := Nil
Return aFerramentas

/*/{Protheus.doc} POST OPERACAO /api/pcp/v1/PCPA152ManOperacao/{programacao}/operacoes/{id}
Salva as alterações de uma operação (cabeçalho SMF e recursos HZ7).

@type  WSMETHOD
@author Lucas Fagundes
@since 15/09/2026
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados.
/*/
WSMETHOD POST OPERACAO PATHPARAM programacao, id WSSERVICE PCPA152MANOPERACAO
	Local aReturn      := {}
	Local bErrorBlk    := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152ManOperacao"), Break(oError)})
	Local cBody        := ""
	Local lReturn      := .T.
	Local oBody        := JsonObject():New()
	Local oManOperacao := Nil

	Self:SetContentType("application/json")

	cBody := DecodeUTF8(Self:getContent())
	oBody:fromJson(cBody)

    oBody["dataInicio" ] := PCPConvDat(oBody["dataInicio" ], 1)
    oBody["dataEntrega"] := PCPConvDat(oBody["dataEntrega"], 1)

	oManOperacao := CRPManutencaoOperacao():New(Self:programacao, Self:id)

	BEGIN SEQUENCE
		aReturn := oManOperacao:processSaveOperacao(oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	oManOperacao:Destroy()
	oManOperacao := Nil
	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} processSaveOperacao
Processa o salvamento das alterações de uma operação.

@author Lucas Fagundes
@since 15/09/2026
@version P12
@param oBody, Json, Objeto com as informações da operação enviadas pelo front.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Method processSaveOperacao(oBody) Class CRPManutencaoOperacao
    Local aReturn  := Array(3)
    Local oReturn  := JsonObject():New()

    BEGIN TRANSACTION

        If Self:gravaSMF(oBody)
            Self:gravaRecursos(oBody['recursos'])
        EndIf

        PCPA152Process():atualizaPendenciaDeReprocessamento(Self:cProg, REPROCESSAMENTO_PENDENTE)

    END TRANSACTION

    aReturn[1] := .T.
    aReturn[2] := 200
    aReturn[3] := oReturn:toJson()

    FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} gravaSMF
Atualiza o cabeçalho da operação (SMF) com os dados informados, localizando o registro
pela programação e pelo identificador (id) da instância.

@author Lucas Fagundes
@since 15/09/2026
@version P12
@param oBody, Json, Objeto com as informações da operação enviadas pelo front.
@param cErro, Character, Retorna por referência a mensagem de erro.
@return lSucesso, Logic, Indica se atualizou o registro com sucesso.
/*/
Method gravaSMF(oBody) Class CRPManutencaoOperacao
    Local aRecursos := oBody['recursos']
    Local lAtuDatas := .F.
    Local lSucesso  := .T.

    SMF->(dbSetOrder(2)) // MF_FILIAL + MF_PROG + MF_ID

    If SMF->(dbSeek(xFilial("SMF") + Self:cProg + Self:cIdOper))

        lAtuDatas := Empty(SMF->MF_SEQPAI) .And. (SMF->MF_DTINI != oBody["dataInicio"] .Or. SMF->MF_DTENT != oBody["dataEntrega"])

        aSort(aRecursos,,, {|x, z| x['sequencia'] < z['sequencia']})

        RecLock("SMF", .F.)
            SMF->MF_TEMPO   := __Hrs2Min(oBody['tempo'      ])
            SMF->MF_SETUP   := __Hrs2Min(oBody['setup'      ])
            SMF->MF_TMPFINA := __Hrs2Min(oBody['finalizacao'])
            SMF->MF_REMOCAO := __Hrs2Min(oBody['remocao'    ])
            SMF->MF_TPDESDO := oBody['tipoDesdobramento']
            SMF->MF_DESDOBR := oBody['desdobramento'    ]
            SMF->MF_TPSOBRE := oBody['tipoSobreposicao' ]
            SMF->MF_TEMPSOB := oBody['sobreposicao'     ]
            SMF->MF_RECURSO := oBody['recursos'][1]['recurso'       ]
            SMF->MF_CTRAB   := oBody['recursos'][1]['centroTrabalho']
        SMF->(MsUnLock())

        Self:geraOcorrenciaOperacaoAlterada(SMF->MF_ID, SMF->MF_OP, SMF->MF_OPER)

        If lAtuDatas
            Self:atualizaDatasOperacoes(SMF->MF_OP, oBody["dataInicio"], oBody["dataEntrega"])
        EndIf
    EndIf

Return lSucesso

/*/{Protheus.doc} atualizaDatasOperacoes
Atualiza a data de início e a data de entrega de todas as operações (SMF) da ordem de produção que está tendo uma operação alterada, mantendo as datas coerentes entre todas as operações da mesma ordem.

@author Lucas Fagundes
@since 16/09/2026
@version P12
@param cOrdem, Character, Código da ordem de produção que terá as datas atualizadas.
@param dDataIni, Date, Nova data de início a ser gravada nas operações da ordem.
@param dDataEnt, Date, Nova data de entrega a ser gravada nas operações da ordem.
@return Nil
/*/
Method atualizaDatasOperacoes(cOrdem, dDataIni, dDataEnt) Class CRPManutencaoOperacao
    Local aAreaSMF := SMF->(GetArea())
    Local cFilSMF  := xFilial("SMF")

    SMF->(dbSetOrder(1)) // MF_FILIAL + MF_PROG + MF_OP + MF_ROTEIRO + MF_OPER

    If SMF->(dbSeek(cFilSMF + Self:cProg + cOrdem))
        While SMF->(!EoF()) .And. SMF->MF_FILIAL == cFilSMF .And. ;
              SMF->MF_PROG == Self:cProg .And. SMF->MF_OP == cOrdem

            RecLock("SMF", .F.)
                SMF->MF_DTINI := dDataIni
                SMF->MF_DTENT := dDataEnt
            SMF->(MsUnLock())

            Self:geraOcorrenciaOperacaoAlterada(SMF->MF_ID, SMF->MF_OP, SMF->MF_OPER)

            SMF->(dbSkip())
        End
    EndIf

    RestArea(aAreaSMF)
Return Nil

/*/{Protheus.doc} gravaRecursos
Sincroniza os recursos (HZ7) da operação: exclui todos os recursos gravados da operação e inclui novamente com base nas informações recebidas do front.

@author Lucas Fagundes
@since 15/09/2026
@version P12
@param aRecursos, Array, Array com os recursos da operação.
@return Nil
/*/
Method gravaRecursos(aRecursos) Class CRPManutencaoOperacao
    Local cFilHZ7  := xFilial("HZ7")
    Local nIndex   := 0
    Local nTotal   := Len(aRecursos)
    Local oRecurso := Nil

    HZ7->(dbSetOrder(1)) // HZ7_FILIAL + HZ7_PROG + HZ7_ID + HZ7_SEQ

    If HZ7->(dbSeek(cFilHZ7 + Self:cProg + Self:cIdOper))
        While HZ7->(!EoF()) .And. HZ7->HZ7_FILIAL == cFilHZ7 .And. ;
              HZ7->HZ7_PROG == Self:cProg .And. HZ7->HZ7_ID == Self:cIdOper

            RecLock("HZ7", .F.)
                HZ7->(dbDelete())
            HZ7->(MsUnLock())

            HZ7->(dbSkip())
        End
    EndIf

    For nIndex := 1 To nTotal
        oRecurso := aRecursos[nIndex]

        RecLock("HZ7", .T.)
            HZ7->HZ7_FILIAL := cFilHZ7
            HZ7->HZ7_PROG   := Self:cProg
            HZ7->HZ7_ID     := Self:cIdOper
            HZ7->HZ7_SEQ    := oRecurso['sequencia'     ]
            HZ7->HZ7_RECURS := oRecurso['recurso'       ]
            HZ7->HZ7_CTRAB  := oRecurso['centroTrabalho']
            HZ7->HZ7_MAOOBR := oRecurso['maoObra'       ]
            HZ7->HZ7_TEMPOR := __Hrs2Min(oRecurso['tempoOriginal'])
            HZ7->HZ7_TEMPRE := __Hrs2Min(oRecurso['tempoRecurso' ])
            HZ7->HZ7_TIPO   := oRecurso['tipo'          ]
        HZ7->(MsUnLock())
    Next nIndex

Return Nil

/*/{Protheus.doc} geraOcorrenciaOperacaoAlterada
Gera ocorrência de alteração da programação.

@author Lucas Fagundes
@since 18/09/2026
@version P12
@param cIdOper, Character, Id da operação que esta sendo alterada.
@param cOrdem, Character, Código da ordem que esta tendo a operação alterada.
@param cOperac, Character, Código da operação que esta sendo alterada.
@return Nil
/*/
Method geraOcorrenciaOperacaoAlterada(cIdOper, cOrdem, cOperac) Class CRPManutencaoOperacao
    Local cAlias     := ""
    Local cData      := DToC(dDatabase)
    Local cQuery     := ""
    Local cUsuario   := RetCodUsr()
    Local lInclui    := .T.
    Local nPosParam  := 1
    Local oStatement := Nil

    cQuery := " SELECT SVY.R_E_C_N_O_ recno "
    cQuery +=   " FROM " + RetSqlName("SVY") + " SVY "
    cQuery +=  " WHERE SVY.VY_FILIAL  =  ?  "
    cQuery +=    " AND SVY.VY_PROG    =  ?  "
    cQuery +=    " AND SVY.VY_TIPO    =  ?  "
    cQuery +=    " AND SVY.VY_OP      =  ?  "
    cQuery +=    " AND SVY.VY_OPER    =  ?  "
    cQuery +=    " AND SVY.D_E_L_E_T_ = ' ' "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:setString(nPosParam++, xFilial("SVY"))        // VY_FILIAL
    oStatement:setString(nPosParam++, Self:cProg)            // VY_PROG
    oStatement:setString(nPosParam++, LOG_OPERACAO_ALTERADA) // VY_TIPO
    oStatement:setString(nPosParam++, cOrdem)                // VY_OP
    oStatement:setString(nPosParam++, cOperac)               // VY_OPER

    cAlias := oStatement:openAlias()

    If (cAlias)->(!EoF())
        lInclui := .F.
        SVY->(dbGoTo((cAlias)->recno))
    Else
        lInclui := .T.

        If Self:nIdSVY == Nil
            Self:nIdSVY := Self:getSequenciaSVY()
        EndIf

        Self:nIdSVY++
    EndIf

    RecLock("SVY", lInclui)
        If lInclui
            SVY->VY_FILIAL  := xFilial("SVY")
            SVY->VY_PROG    := Self:cProg
            SVY->VY_ID      := StrZero(Self:nIdSVY, Self:nTamVYID)
            SVY->VY_TIPO    := LOG_OPERACAO_ALTERADA
            SVY->VY_OP      := cOrdem
            SVY->VY_OPER    := cOperac
            SVY->VY_IDREG   := cIdOper
        EndIf
        SVY->VY_OCORREN := i18n(STR0725, {cData, cUsuario}) // "Dados da operação alterados em #1[changeDate]# pelo usuário #2[userCode]#."
    SVY->(MsUnLock())

    oStatement:destroy()
    oStatement := Nil

Return Nil

/*/{Protheus.doc} getSequenciaSVY
Retorna o ultimo id utilizado na gravação das ocorrências.

@author Lucas Fagundes
@since 18/09/2026
@version P12
@return nId, Numeric, Ultimo id utilizado na gravação das ocorrências.
/*/
Method getSequenciaSVY() Class CRPManutencaoOperacao
    Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local nId        := 0
    Local nPosParam  := 1
    Local oStatement := Nil

	cQuery := " SELECT MAX(SVY.VY_ID) maxId "
	cQuery +=   " FROM " + RetSqlName("SVY") + " SVY "
	cQuery +=  " WHERE SVY.VY_FILIAL  =  ?  "
	cQuery +=    " AND SVY.VY_PROG    =  ?  "
	cQuery +=    " AND SVY.D_E_L_E_T_ = ' ' "

    oStatement := FwExecStatement():New(cQuery)

    oStatement:setString(nPosParam++, xFilial("SVY")) // VY_FILIAL
    oStatement:setString(nPosParam++, Self:cProg)     // VY_PROG

	cAlias := oStatement:openAlias()

	If (cAlias)->(!EoF())
		nId := Val((cAlias)->maxId)
	EndIf
	(cAlias)->(dbCloseArea())

    oStatement:destroy()
    oStatement := Nil

Return nId
