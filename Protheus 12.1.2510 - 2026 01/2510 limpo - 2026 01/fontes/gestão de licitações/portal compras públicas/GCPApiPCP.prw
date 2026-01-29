#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#include "RESTFUL.ch"
#include "GCPAPIPCP.ch"

/*/{Protheus.doc} GCPApiPCP
    (Classe para integração com portal de contas publicas)
    @author Thiago Rodrigues
    @since 06/03/2024
    @version version
/*/
Class GCPApiPCP

    Data aHeaderPCP                     as array
    Data cURLApiPCP                     as character
    Data cResourceApi                   as character
    Data cDescUserPCP                   as character
    Data cPathProcesso                  as character
    Data cPathProcessos                 as character
    Data cPathUsuario                   as character
    Data cPathComprador                 as character
    Data nApiModalidade                 as numeric
    Data nAmbientePCP                   as numeric
    Data lCodeHttp5xx                   as logical

    Protected Data cPublicKey           as character
    Protected Data cIdentAutoridade     as character
    Protected Data cIdentLeiloeiro      as character
    Protected Data cIdentCompraDireta   as character
    Protected Data cIdentPregoeiro      as character
    Protected Data cIdentResponsavel    as character
    Protected Data cIdentModPCP         as character

    Method New() Constructor

    Method PostPortal()
    Method GetListaProcessos()
    Method GetObterProcesso()
    Method GetHeader()
    Method RetJson()
    Method GetNatureza()
    Method GetDocuments()
    Method GetNextItem()
    Method TipoDeJulgamento()
    Method IdentPermis()
    Method GravaIntegracao()
    Method GravaProcessosPCP()
    Method GerarDocProcesso()
    Method LogMessage()
    Method StatusInteg()
    Method legislacaoAplicavel()

EndClass

/*/{Protheus.doc} New
    (Metodo Construtor)
    @author Thiago Rodrigues
    @since 06/03/2024
    @version version
/*/
Method New() Class GCPApiPCP

    Self:nAmbientePCP       := SuperGetMV("MV_AMBPCP", .F., 2) // Ambiente de Integração PCP

    if Self:nAmbientePCP == 1
        Self:cURLApiPCP     := SuperGetMv("MV_URLPCP1", .F., "https://apipcp.portaldecompraspublicas.com.br") // Url de Produção
    else
        Self:cURLApiPCP     := SuperGetMv("MV_URLPCP2", .F., "https://apipcp.wcompras.com.br") // Url de Teste
    endif
    
    Self:cDescUserPCP       := STR0017    // "Pregoeiro"
    Self:cPublicKey         := GetSafeExt("cPublicKeyPCP")
    Self:cIdentAutoridade   := GetSafeExt("cCFPAutoResPCP")
    Self:cIdentLeiloeiro    := GetSafeExt("cCFPLeiloeiPCP")
    Self:cIdentPregoeiro    := GetSafeExt("cCFPPregoeiPCP")
    Self:cIdentCompraDireta := GetSafeExt("cCFPOpComDiPCP")
    Self:cIdentResponsavel  := GetSafeExt("cCFPResponsPCP")
    Self:aHeaderPCP         := Self:GetHeader()
    Self:cIdentModPCP       := Self:cIdentPregoeiro
    Self:lCodeHttp5xx       := .F.
    Self:cPathProcesso      := SuperGetMv("MV_PTHPCP1", .F., "/processo/")  //EndPoint utilizado no PostPortal (Envia o processo)
    Self:cPathProcessos     := SuperGetMv("MV_PTHPCP2", .F., "/processos/") //EndPoint utilizado no GetListaProcessos (Lista Processos)
    Self:cPathUsuario       := SuperGetMv("MV_PTHPCP3", .F., "/usuarios")   //EndPoint utilizado no StatusInteg (Valida dados para integração) 
    Self:cPathComprador     := SuperGetMv("MV_PTHPCP4", .F., "/comprador/") //EndPoint do Objeto de Envio 
    Self:cResourceApi       := Self:cPathComprador + Self:cPublicKey
    
Return nil

/*/{Protheus.doc} PostPortal
    (Envia o processo das modalidades)
    @author Thiago Rodrigues
    @since 06/03/2024
/*/
Method PostPortal(oModel) Class GCPApiPCP

    Local oRest         := nil
    Local oJsonResp     := Nil
    Local oCabEdt       := Nil

    Local cResource     := ""
    Local cModalJson    := ""
    Local cRetJson      := ""
    Local cResposta     := ""

    Local nPos          := 0

    Local lRet          := .F.

    Local aModsPCP      := {    {'PG',1,   'pregao',            'Pregoeiro',              Self:cIdentPregoeiro      },;
                                {'RP',2,   'registroDePreco',   'Pregoeiro',              Self:cIdentPregoeiro      },;
                                {'DL',3,   'dispensa',          'Operador Compra Direta', Self:cIdentCompraDireta   },;
                                {'RD',5,   'rdc',               'Pregoeiro',              Self:cIdentPregoeiro      },;
                                {'CC',6,   'concorrencia',      'Pregoeiro',              Self:cIdentPregoeiro      },;
                                {'LL',7,   'leilaoEletronico',  'Leiloeiro',              Self:cIdentLeiloeiro      },;
                                {'IN',8,   'inexigibilidade',   'Operador Compra Direta', Self:cIdentCompraDireta   },;
                                {'CS',9,   'concurso',          'Responsável',            Self:cIdentResponsavel    },;
                                {'CR',10,  'credenciamento',    'Responsável',            Self:cIdentResponsavel    } }

    oCabEdt := oModel:GetModel('CO1MASTER')

    //Realiza busca da modalidade
    If (nPos := aScan(aModsPCP, {|x| x[01] = oCabEdt:GetValue("CO1_MODALI")})) > 0

        Self:nApiModalidade := aModsPCP[nPos][2]
        Self:cDescUserPCP   := aModsPCP[nPos][4]
        Self:cIdentModPCP   := aModsPCP[nPos][5]

        //Chama tela com informações de usuários autorizados no Portal de Compras Públicas
        Self:IdentPermis()

        cResource   := Self:cResourceApi + Self:cPathProcesso + aModsPCP[nPos][3]

        cModalJson  := Self:RetJson(Self:nApiModalidade, oModel)

        //Construtor do objeto de envio
        oRest := FwRest():New(Self:cURLApiPCP) 
        oRest:SetPath(cResource)
        oRest:SetPostParams(cModalJson)

        //Objeto Json que receberá a resposta
        oJsonResp := JsonObject():New()

        //Faz o post
        If oRest:Post(Self:aHeaderPCP)
            cRetJson := oRest:GetResult() 
            oJsonResp:FromJson(cRetJson)

            If oJsonResp:GetJsonObject("success")
                cResposta := oJsonResp:GetJsonObject("message")
                lRet := .T.

                //Chama a gravação da tabela do monitor
                Self:GravaIntegracao(oModel, cModalJson, cRetJson, lRet, cResposta)

                Help(nil, nil , STR0001  , nil, DecodeUTF8(cResposta) , 1, 0, nil, nil, nil, nil, nil, { ""} ) // "Atenção XXXXXXX"
            EndIf
        Else
            cRetJson := oRest:GetResult()
            oJsonResp:FromJson(cRetJson)

            If !oJsonResp:GetJsonObject("success")
                If (Self:lCodeHttp5xx := (Substr(oRest:GetHTTPCode(), 1, 1) == "5"))
                    cResposta := STR0002 //"Não foi possível enviar edital para o portal de compras públicas, ocorreu o seguinte erro de conexão: "
                    cResposta += iif(!Self:lCodeHttp5xx,DecodeUTF8(oJsonResp:GetJsonObject("message")), STR0019 ) + CRLF  //-- "Serviço Temporariamente Indisponível"

                    cResposta += STR0003 //"O edital será gravado com status de erro, para fazer o reenvio utilize no botão outras/Ações a opção 'Reenviar Processo / PCP'."

                    lRet := .T.
                    Help(nil, nil , STR0001  , nil, cResposta , 1, 0, nil, nil, nil, nil, nil, { ""} ) // "Atenção XXXXXXX"
                Else
                    If oJsonResp:HasProperty('message')
                        cResposta := DecodeUTF8(oJsonResp:GetJsonObject("message"))
                    Else
                        cResposta := STR0018 //-- Não foi possível se conectar ao servidor.
                    EndIf
                    oModel:SetErrorMessage( oModel:GetId(), "POST", "", "", STR0004, STR0005 + cResposta) //Não foi possível enviar o edital para o portal de compras públicas, ocorreu o seguinte erro:
                EndIf
            EndIf
        EndIf
    EndIf

    //-- Limpa objetos da memória
    FreeObj(oRest)
    FreeObj(oJsonResp)
    oCabEdt := Nil // não colocar no FreeObj, senão limpa o model.
    FwFreeArray(aModsPCP)

Return lRet

/*/{Protheus.doc} IdentPermis
    (Tela para informar CPFs autorizados no portal de compras públicas para montagem das informações de integração.)
    @author Leonardo Kichitaro
    @since 21/03/2024
    @version version
/*/
Method IdentPermis() Class GCPApiPCP

    Local oDlg
    Local oGroup1
    Local oGroup2
    Local oFont
    Local oFntBld
    Local oGet1
    Local oGet2
    Local oTBitmap

    Local cAmbient  := Iif(Self:nAmbientePCP == 1, STR0014, STR0015) //"Produção"#"Teste"
    Local cCPF1     := Self:cIdentModPCP
    Local cCPF2     := Self:cIdentAutoridade

    Define Font oFont   Name "Consolas" Size 07,17	//"Consolas"
    DEFINE FONT oFntBld NAME "Consolas" SIZE 07,17 BOLD	//"Consolas"

    Define MsDialog oDlg Title STR0006 From 0,0 To 270,400 Of oDlg STYLE DS_MODALFRAME Pixel //"Usuários Autorizados - Portal de Compras Públicas"

    oGroup1:= TGroup():New(012,5,050,197,Self:cDescUserPCP,oDlg,,,.T.)	//'Dados Pregoeiro '
    oGroup2:= TGroup():New(051,5,103,197,STR0007,oDlg,,,.T.)	//'Autoridade competente'

    @ 03,068 SAY I18N(STR0008 + cAmbient) SIZE 200,20 PIXEL OF oDlg FONT oFntBld //'Ambiente:'//"Loginad do usuário*"//"Login do usuário"

    @ 028,022 SAY I18N(STR0009) SIZE 050,009 PIXEL OF oDlg FONT oFntBld //'CPF:'
    @ 028,047 GET oGet1 VAR cCPF1 SIZE 120,009 PIXEL OF oDlg PICTURE "@R 999.999.999-99"

    @ 074,022 SAY I18N(STR0009) SIZE 050,009 PIXEL OF oDlg FONT oFntBld //'CPF:'
    @ 074,047 GET oGet2 VAR cCPF2 SIZE 120,009 PIXEL OF oDlg PICTURE "@R 999.999.999-99"

    @ 112,005 BUTTON STR0010 SIZE 050, 015 PIXEL OF oDlg ACTION (oDlg:End()) //"Enviar"

    oTBitmap := TBitmap():New(107,115,82,22,,"\portal\pcp\portal_compras_publicas.jpg",.T.,oDlg,{||},,.F.,.F.,,,.F.,,.T.,,.F.)

    oTBitmap:lStretch:= .T.

    oDlg:lEscClose := .F.

    ACTIVATE MSDIALOG oDlg CENTER

    Self:cIdentModPCP       := cCPF1
    Self:cIdentAutoridade   := cCPF2

    //-- Limpa objetos da memória
    FreeObj(oDlg)
    FreeObj(oGroup1)
    FreeObj(oGroup2)
    FreeObj(oFont)
    FreeObj(oFntBld)
    FreeObj(oGet1)
    FreeObj(oGet2)
    FreeObj(oTBitmap)

Return nil 

/*/{Protheus.doc} GravaIntegracao
    (Realiza gravação das tabelas de controle da integração.)
    @author Leonardo Kichitaro
    @since 06/03/2024
    @version version
/*/
Method GravaIntegracao(oModel, cModalJson, cRetJson, lRet, cResposta) Class GCPApiPCP

    Local oEdt      := oModel:GetModel('CO1MASTER')
    Local lNewReg   := .T.

    //Busca se já existe registro na DKF
    DKF->(DbSetOrder(1))
    If DKF->(dbSeek(FWxFilial("DKF")+oEdt:GetValue("CO1_CODEDT")+oEdt:GetValue("CO1_NUMPRO")+oEdt:GetValue("CO1_REVISA")))
        lNewReg := .F.
    Endif

    Begin Transaction
        IF RecLock("DKF",lNewReg)
            If lNewReg
                DKF->DKF_FILIAL := FWxFilial("DKF")
                DKF->DKF_CODEDT := oEdt:GetValue("CO1_CODEDT")
                DKF->DKF_NUMPRO := oEdt:GetValue("CO1_NUMPRO")
                DKF->DKF_VERSAO := oEdt:GetValue("CO1_VERSAO")
                DKF->DKF_REVISA := oEdt:GetValue("CO1_REVISA")
                DKF->DKF_MODALI := oEdt:GetValue("CO1_MODALI")
                DKF->DKF_DESMOD := AllTrim(Posicione("SX5",1,xFilial("SX5")+"LF"+oEdt:GetValue("CO1_MODALI"),"X5_DESCRI"))
                DKF->DKF_OBJETO := oEdt:GetValue("CO1_OBJETO")
                DKF->DKF_ANOAB  := oEdt:GetValue("CO1_ANOAB")
            EndIf
            DKF->DKF_STATUS := Iif(lRet, "0", "9")
            DKF->DKF_DSCSTS := DecodeUTF8(cResposta)
            DKF->DKF_TPINTG := "1"
            DKF->DKF_DTINTE := Date()
            DKF->DKF_HRINTE := Time()
            DKF->DKF_MSGENV := DecodeUTF8(cModalJson)
            DKF->DKF_MSGRET := DecodeUTF8(cRetJson)

            DKF->(MsUnlock())
        EndIf
    End Transaction

    oEdt := Nil // não colocar no FreeObj, senão limpa o model.

Return nil

/*/{Protheus.doc} GetListaProcessos
    (Obtém uma lista de processos com base no ano e número de referência.)
    @author Leonardo Kichitaro
    @since 06/03/2024
    @version version
/*/
Method GetListaProcessos() Class GCPApiPCP

    Local oRest         := nil
    Local oJsonResp     := Nil

    Local cResource     := ""
    Local cRetJson      := ""
    Local cRetObter     := ""
    Local cResProc      := Self:cPathProcessos
    local cStatusAnt    := ""
    Local nX            := 0
    Local lNextPag      := .T.
    Local nPg           := 1
    local cAno          := cValToChar(Year(dDataBase))

    cResProc += cAno

    While lNextPag

        cResource  := Self:cResourceApi + cResProc + "?pagina=" + AllTrim(Str(nPg))

        oRest := FwRest():New(Self:cURLApiPCP)
        oRest:SetPath(cResource)

        oJsonResp := JsonObject():New() 

        If oRest:Get(Self:aHeaderPCP)
            cRetJson := oRest:GetResult()
            oJsonResp:FromJson(cRetJson)

            If oJsonResp['paginaAtual'] <> nPg
                lNextPag := .F.
                Loop
            EndIf

            If ValType(oJsonResp['dadosLicitacoes']) == 'A'
                For nX := 1 To Len(oJsonResp['dadosLicitacoes'])
                    cStatusAnt := ""

                    If !DKF->(DbSeek(FWxFilial("DKF") + Padr(oJsonResp["dadosLicitacoes"][nX]['_id'],Len(DKF->DKF_CODEDT)) + Padr(oJsonResp["dadosLicitacoes"][nX]['NR_PROCESSO'],Len(DKF->DKF_NUMPRO)))) .And.; 
                       !DKF->(DbSeek(FWxFilial("DKF") + "PCP" + StrZero(oJsonResp["dadosLicitacoes"][nX]['idLicitacao'], 12) + Padr(oJsonResp["dadosLicitacoes"][nX]['NR_PROCESSO'],Len(DKF->DKF_NUMPRO)))) //Edital cadastrado direto no PCP
                        Self:GravaProcessosPCP(oJsonResp["dadosLicitacoes"][nX])
                    EndIf

                    If DKF->DKF_STATUS <> AllTrim(Str(oJsonResp["dadosLicitacoes"][nX]['cdSituacao'])) .AND. DKF->DKF_STATUS <> "7"
                        Begin Transaction
                            If Self:GetObterProcesso(oJsonResp["dadosLicitacoes"][nX], @cRetObter)
                                cStatusAnt := DKF->DKF_STATUS
                                IF RecLock("DKF", .F.)
                                    DKF->DKF_IDLICT := Alltrim(cValToChar(oJsonResp["dadosLicitacoes"][nX]['idLicitacao']))
                                    DKF->DKF_NRLICT := oJsonResp["dadosLicitacoes"][nX]['NR_LICITACAO']
                                    DKF->DKF_STATUS := AllTrim(Str(oJsonResp["dadosLicitacoes"][nX]['cdSituacao']))
                                    DKF->DKF_DSCSTS := AllTrim(DecodeUTF8(oJsonResp["dadosLicitacoes"][nX]['situacao']))
                                    DKF->DKF_DTATUA := Date()
                                    DKF->DKF_HRATUA := Time()
                                    DKF->DKF_URLPRO := AllTrim(oJsonResp["dadosLicitacoes"][nX]['urlProcesso'])
                                    DKF->DKF_MSGATU := cRetObter
                                    DKF->(MsUnlock())

                                    If DKF->DKF_TPINTG == "1" 
                                        //Posiciona na tabela CO1 para atualizar o Status para publicado
                                        CO1->(DbSetOrder(1))
                                        If CO1->(dbSeek(FWxFilial("CO1") + DKF->DKF_CODEDT + DKF->DKF_NUMPRO + DKF->DKF_REVISA)) .And. CO1->CO1_STATUS == "D"
                                            IF RecLock("CO1", .F.)
                                                CO1->CO1_STATUS := "F"
                                                CO1->(MsUnlock())
                                            EndIf    
                                        EndIf   

                                        //Atualiza o edital (GCPA200)
                                        If  DKF->DKF_STATUS == "6"
                                            if !GCPPCPProc(DKF->DKF_CODEDT,DKF->DKF_NUMPRO,DKF->DKF_REVISA,cRetObter)
                                                DKF->(RecLock("DKF", .F.))
                                                    DKF->DKF_STATUS := cStatusAnt
                                                DKF->(MsUnlock())
                                            endif
                                        endif

                                    EndIf

                                EndIf

                            EndIf


                        End Transaction
                    EndIf
                Next nX
            EndIf

            nPg++
        Else
            cRetJson := oRest:GetResult()

            Self:LogMessage(cRetJson, oRest:GetLastError())
            lNextPag := .F.
        EndIf

        oRest       := Nil
        oJsonResp   := Nil
    endDo
    //-- Limpa objetos da memória
    FreeObj(oJsonResp)
    FreeObj(oRest)

Return nil 

/*/{Protheus.doc} GravaProcessosPCP
    (Grava processos que foram incluídos apenas no PCP)
    @author Leonardo Kichitaro
    @since 01/04/2024
    @version version
/*/
Method GravaProcessosPCP(oDadosLict) Class GCPApiPCP

    Local cCodEdt   := ""

    If ValType(oDadosLict['_id']) <> "U"
        cCodEdt := oDadosLict['_id']
    Else
        cCodEdt := "PCP" + StrZero(oDadosLict['idLicitacao'], 12)
    EndIf

    Begin Transaction
        IF RecLock("DKF", .T.)
            DKF->DKF_FILIAL := FWxFilial("DKF")
            DKF->DKF_CODEDT := cCodEdt
            DKF->DKF_NUMPRO := oDadosLict['NR_PROCESSO']
            DKF->DKF_VERSAO := "1"
            DKF->DKF_REVISA := ""
            DKF->DKF_MODALI := ""
            DKF->DKF_DESMOD := DecodeUTF8(oDadosLict['tipoLicitacao'])
            DKF->DKF_OBJETO := DecodeUTF8(oDadosLict['DS_OBJETO'])
            DKF->DKF_ANOAB  := cValToChar(oDadosLict['ANO_LICITACAO'])
            DKF->DKF_STATUS := "0"
            DKF->DKF_DSCSTS := STR0016 //"Processo incluído pelo portal de compras públicas, sem edital no SIGAGCP"
            DKF->DKF_TPINTG := "2"
            DKF->DKF_DTINTE := Date()
            DKF->DKF_HRINTE := Time()

            DKF->(MsUnlock())
        EndIf
    End Transaction

Return

/*/{Protheus.doc} GetObterProcesso
    (Obtém o processo)
    @author Leonardo Kichitaro
    @since 06/03/2024
    @version version
/*/
Method GetObterProcesso(oDadosLict, cRetObter) Class GCPApiPCP

    Local oRestObtP     := nil

    Local cResource     := ""
    Local cRetJson      := ""
    Local cResProc      := "/processo/"
    local lRet          := .T.
    local oRetEnc       := nil 

    cResource   := Self:cResourceApi + cResProc + cValToChar(oDadosLict['idLicitacao'])

    oRestObtP := FwRest():New(Self:cURLApiPCP)
    oRestObtP:SetPath(cResource)

    If oRestObtP:Get(Self:aHeaderPCP)
        cRetJson := oRestObtP:GetResult()
        cRetObter := cRetJson


        //Verifica se o status esta realmente encerrado
        IF AllTrim(Str(oDadosLict['cdSituacao'])) == "6" 
            oRetEnc:= JsonObject():New() 
            oRetEnc:FromJson(cRetJson)
        
            if Valtype(oRetEnc["Encerramento"]) =="A" .And. len(oRetEnc["Encerramento"]) == 0 
                if oRetEnc['TIPO_LICITACAO'] != "Inexigibilidade"
                    lRet := .F.
                endif
            endif
            FreeObj(oRetEnc)
        endif


        IF lRet
            IF RecLock("DKG", .T.)
                DKG->DKG_FILIAL := FWxFilial("DKG")
                DKG->DKG_IDLICT := Alltrim(cValToChar(oDadosLict['idLicitacao']))
                DKG->DKG_ITEM   := Self:GetNextItem(oDadosLict['idLicitacao'])
                DKG->DKG_NRLICT := oDadosLict['NR_LICITACAO']
                DKG->DKG_ANOAB  := DKF->DKF_ANOAB
                DKG->DKG_CODEDT := DKF->DKF_CODEDT
                DKG->DKG_NUMPRO := DKF->DKF_NUMPRO
                DKG->DKG_VERSAO := DKF->DKF_VERSAO
                DKG->DKG_REVISA := DKF->DKF_REVISA
                DKG->DKG_DESMOD := AllTrim(DecodeUTF8(oDadosLict['tipoLicitacao']))
                DKG->DKG_STATUS := AllTrim(Str(oDadosLict['cdSituacao']))
                DKG->DKG_DSCSTS := AllTrim(DecodeUTF8(oDadosLict['situacao']))
                DKG->DKG_DTSTAT := Date()
                DKG->DKG_HRSTAT := Time()
                DKG->DKG_MSGRET := cRetJson
                DKG->(MsUnlock())
            EndIf
        endif
    Else
		cRetJson := oRestObtP:GetResult()

		Self:LogMessage(cRetJson, oRestObtP:GetLastError())
        lRet := .F.
	EndIf

    //-- Limpa objetos da memória
    FreeObj(oRestObtP)

Return lRet

/*/{Protheus.doc} GetHeader
    (Monta o Header)
    @author Thiago Rodrigues
    @since 06/03/2024
    @version version
/*/
Method GetHeader() Class GCPApiPCP

    Local aHeader := {}

    AAdd(aHeader, "cache-control: no-cache")
    AAdd(aHeader, "content-type: application/json; charset=UTF-8")
    Aadd(aHeader, 'Content-Length: <calculated when request is sent>')
    Aadd(aHeader, 'Host:'+ Substr(Self:cURLApiPCP,9,len(Self:cURLApiPCP)))

Return aHeader

/*/{Protheus.doc} GetObterProcesso
    (Retorna o Json)
    @author Thiago Rodrigues
    @since 06/03/2024
    @version version
    @Param Modalidade, Model
/*/
Method RetJson(nMetodo,oModel) Class GCPApiPCP

    local oCo1       := Nil
    local oCo2       := Nil
    local oCp3       := Nil
    local cParamJson := ""
    Local lLote 	 := Nil
    local nI         := 1
    local nX         := 1 
    local aSaveLines := {}
    local nTamCo2    := 0
    local cTpJulg    := ""

    oCo1 := oModel:GetModel('CO1MASTER')
    oCo2 := oModel:GetModel("CO2DETAIL")
    oCp3 := oModel:GetModel("CP3DETAIL")
    nTamCo2 := oCo2:Length()
    lLote:= oModel:GetId() == 'GCPA201'
 
    if nMetodo == 1 //Pregao
        cParamJson := '{'
        cParamJson += '"id":"' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto":"' + oCo1:GetValue("CO1_OBJETO") + '",'
        cParamJson += '"tipoRealizacao":' + iif(Empty(oCo1:GetValue("CO1_FORMRL")),"1",oCo1:GetValue("CO1_FORMRL")) + ","
        cParamJson += '"tipoJulgamento":' + self:TipoDeJulgamento(1,oCo1:GetValue("CO1_TIPO"))  + ","
        cParamJson += '"numeroProcessoInterno":"' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso":' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ","
        cParamJson += '"anoProcesso":'   + oCo1:GetValue("CO1_ANOAB") + ","
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"),"00:00:00") + '",'
        cParamJson += '"dataFinalPropostas":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"dataLimiteImpugnacao":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLINP"),"00:00:00") + '",'
        cParamJson += '"dataAberturaPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTABPR"),"00:00:00") + '",'
        cParamJson += '"dataLimiteEsclarecimento":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLIES"),"00:00:00") + '",'
        cParamJson += '"orcamentoSigiloso":' + iif(oCo1:GetValue("CO1_ORCSIG") =="1","true","false")   + ","
        cParamJson += '"exclusivoMPE":' + iif(oCo1:GetValue("CO1_MEEPP") =="1","true","false")  + ","
        cParamJson += '"aplicar147":'   + iif(oCo1:GetValue("CO1_APL147") =="1","true","false") + ","
        cParamJson += '"beneficioLocal":' + iif(oCo1:GetValue("CO1_BENELO") =="1","true","false") + ","
        cParamJson += '"exigeGarantia":' + iif(oCo1:GetValue("CO1_EXIGEG") =="1","true","false") + ","
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'
        cParamJson += '"legislacaoAplicavel":' + self:legislacaoAplicavel(oCo1:GetValue("CO1_LEI")) + ","
        cParamJson += '"tratamentoFaseLance":' + oCo1:GetValue("CO1_FASELA") + ","
        
        if  oCo1:GetValue("CO1_FASELA") == "1"
            cParamJson += '"tipoIntervaloLance":' + oCo1:GetValue("CO1_INTERL") + ","
            cParamJson += '"valorIntervaloLance":' + cValToChar(oCo1:GetValue("CO1_VLINTL")) + ","
        endif

        if !lLote //Se for por item
            cParamJson += '"separarPorLotes":' + iif(nTamCo2 > 1,"true","false") + ','

            cParamJson += '"lotes": ['
            cParamJson += '{'
            cParamJson += '"numero": 1,' //Precisa ser enviado um lote mesmo sendo por item, por isso esse valor.
            cParamJson += '"descricao": "Lote 1",'
            cParamJson += '"exclusivoMPE":' + iif(oCo1:GetValue("CO1_MEEPP") =="1","true","false")  + ","
            cParamJson += '"cotaReservada":' + iif(oCo1:GetValue("CO1_COTARE") =="1","true","false")  + ","
            cParamJson += '"justificativa": "",'
            cParamJson += '"itens": ['
        
            aSaveLines := FWSaveRows()
            for nI := 1 to nTamCo2
                oCo2:GoLine(nI)

                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                cParamJson += '"numero":' + cValtoChar(nI) + ","
                cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                
                cParamJson += '"natureza": ' +self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade": "' + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT") + oCo2:GetValue("CO2_QTDRSV"))

                If oCo1:GetValue("CO1_APL147") =="1" .And. oCo1:GetValue("CO1_COTARE") =="1" 
                    cParamJson += '"quantidadeCota":' + cValToChar(oCo2:GetValue("CO2_QTDRSV"))
                endif
                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )

            cParamJson += ' ]'
            cParamJson += '}'
            cParamJson += ' ],'

        else //por Lote
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"operacaoLote":' +oCo1:GetValue("CO1_OPERLO") + ','

            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero": ' + cValToChar(nX) + ','
                cParamJson += '"descricao": "' + oCp3:GetValue("CP3_LOTE") + '",'
                cParamJson += '"exclusivoMPE":'  + iif(oCp3:GetValue("CP3_LOTMPE")== "1","true","false")  + ","
                cParamJson += '"cotaReservada":' + iif(oCp3:GetValue("CP3_COTARE")== "1","true","false") + ","
                if oCo1:GetValue("CO1_APL147") =="1"
                    cParamJson += '"justificativa": "' + oCp3:GetValue("CP3_JUSTIF") + '",'
                endif    
                cParamJson += '"itens": ['

                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    cParamJson += '"numero":' + cValtoChar(nI) + ","
                    cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                    cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                    cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT") + oCo2:GetValue("CO2_QTDRSV"))
                    
                    If oCo1:GetValue("CO1_APL147") =="1" .And. oCp3:GetValue("CP3_COTARE")== "1"
                        cParamJson += '"quantidadeCota":' + cValToChar(oCo2:GetValue("CO2_QTDRSV"))
                    endif
                   
                    cParamJson += '}'
                next nI
                cParamJson += ' ]'

                cParamJson += '}'
            next nX
            FWRestRows( aSaveLines )
            cParamJson += ' ],'
        endif

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"pregoeiro": "' + Self:cIdentModPCP + '"'
        cParamJson += '}'

    elseif nMetodo == 2 //Registro de preço
        cParamJson := '{'
        cParamJson += '"id":"' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto":"' + oCo1:GetValue("CO1_OBJETO") + '",'
        cParamJson += '"tipoRealizacao":' + iif(Empty(oCo1:GetValue("CO1_FORMRL")),"1",oCo1:GetValue("CO1_FORMRL")) + ","
        cParamJson += '"numeroProcessoInterno":"' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso":' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ","
        cParamJson += '"anoProcesso":'   + oCo1:GetValue("CO1_ANOAB") + "," 
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"),"00:00:00") + '",'
        cParamJson += '"dataFinalPropostas":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"dataLimiteImpugnacao":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLINP"),"00:00:00") + '",'
        cParamJson += '"dataAberturaPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTABPR"),"00:00:00") + '",'
        cParamJson += '"dataLimiteEsclarecimento":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLIES"),"00:00:00") + '",'
        cParamJson += '"orcamentoSigiloso":' + iif(oCo1:GetValue("CO1_ORCSIG") =="1","true","false")   + "," 
        cParamJson += '"prazoValidade":"' + cValToChar(oCo1:GetValue("CO1_PRAZO")) + '",'

        cParamJson += '"exclusivoMPE":' + iif(oCo1:GetValue("CO1_MEEPP") =="1","true","false")  + ","
        cParamJson += '"aplicar147":'   + iif(oCo1:GetValue("CO1_APL147") =="1","true","false") + ","
        cParamJson += '"beneficioLocal":' + iif(oCo1:GetValue("CO1_BENELO") =="1","true","false") + ","
        cParamJson += '"exigeGarantia":' + iif(oCo1:GetValue("CO1_EXIGEG") =="1","true","false") + "," 

        cParamJson += '"tratamentoFaseLance":' + oCo1:GetValue("CO1_FASELA") + ","
        if  oCo1:GetValue("CO1_FASELA") == "1"
            cParamJson += '"tipoIntervaloLance":' + oCo1:GetValue("CO1_INTERL") + ","
            cParamJson += '"valorIntervaloLance":' + cValToChar(oCo1:GetValue("CO1_VLINTL")) + ","
        endif

        if !lLote //Se for por item
            cParamJson += '"separarPorLotes":' + iif(nTamCo2 > 1,"true","false") + ','

            cParamJson += '"lotes": ['
            cParamJson += '{'
            cParamJson += '"numero": 1,' 
            if nTamCo2 > 1 //Se  separarPorLotes == true tem q enviar descrição
                 cParamJson += '"descricao": "Lote 1",'
            endif

            cParamJson += '"itens": ['
        
            aSaveLines := FWSaveRows()
            for nI := 1 to nTamCo2
                oCo2:GoLine(nI)

                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                cParamJson += '"numero":' + cValtoChar(nI) + "," 
                cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                cParamJson += '"natureza": '   +  self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )

            cParamJson += ' ]'
            cParamJson += '}'
            cParamJson += ' ],'

        else //por Lote
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"operacaoLote":' +oCo1:GetValue("CO1_OPERLO") + ','

            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero":  ' + cValToChar(nX) + ','
                cParamJson += '"descricao": "' + oCp3:GetValue("CP3_LOTE") + '",' 

                cParamJson += '"itens": ['

                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    cParamJson += '"numero":' + cValtoChar(nI) + ","
                    cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                    cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                    cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                    cParamJson += '}'
                next nI
                cParamJson += ' ]'

                cParamJson += '}'
            next nX
            FWRestRows( aSaveLines )
            cParamJson += ' ],'
        endif    

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"pregoeiro": "' + Self:cIdentModPCP + '",'
        cParamJson += '"autoridadeCompetente": "' + Self:cIdentAutoridade + '"'
        cParamJson += '}'

    elseif nMetodo == 3 //Dispensa
        cParamJson := '{'
        cParamJson += '"id":"' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto":"' + oCo1:GetValue("CO1_OBJETO") + '",'
        cParamJson += '"tipoJulgamento":' + self:TipoDeJulgamento(3,oCo1:GetValue("CO1_TIPO"))  + ","
        cParamJson += '"numeroProcessoInterno":"' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso":' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ","
        cParamJson += '"anoProcesso":'   + oCo1:GetValue("CO1_ANOAB") + "," 
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"), "00:00:00" ) + '",' 
        cParamJson += '"dataFinalLances":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"orcamentoSigiloso":' + iif(oCo1:GetValue("CO1_ORCSIG") =="1","true","false")   + "," 
        cParamJson += '"aceitaPropostaSuperior":' + iif(oCo1:GetValue("CO1_ACPROS") =="1","true","false") + ","
        cParamJson += '"possuiTempoAleatorio":' + iif(oCo1:GetValue("CO1_TEMPAL") =="1","true","false") + ","
        if lLote
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"operacaoLote": 1,'
        else 
            if nTamCo2 > 1 
                cParamJson += '"separarPorLotes": true,'
                cParamJson += '"operacaoLote": 1,'
            else 
                cParamJson += '"separarPorLotes": false,'
            endif
        endif
        cParamJson += '"codigoEnquadramentoJuridico":' + oCo1:GetValue("CO1_ENQJUR") + ","
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'
        
        if !lLote
            cParamJson += '"lotes": ['
            cParamJson += '{'
            cParamJson += '"numero": 1,' 
            if nTamCo2 > 1 
                cParamJson += '"descricao": "Lote 1",'
            endif
            cParamJson += '"itens": ['
        
            aSaveLines := FWSaveRows()
            for nI := 1 to nTamCo2
                oCo2:GoLine(nI)

                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                cParamJson += '"numero":' + cValtoChar(nI) + ","
                cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ',' 
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                
                cParamJson += '"natureza": '   +  self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )

            cParamJson += ' ]'
            cParamJson += '}'
            cParamJson += ' ],'
        else 
            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero": ' + cValToChar(nX) + ','
                cParamJson += '"descricao": "' + oCp3:GetValue("CP3_LOTE") + '",'
                cParamJson += '"itens": ['

                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    cParamJson += '"numero":' + cValtoChar(nI) + "," 
                    cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ',' 
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ',' 
                    cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                    cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                    cParamJson += '}'
                next nI
                cParamJson += ' ]'
                cParamJson += '}'
            next nX
            FWRestRows( aSaveLines )
            cParamJson += ' ],'
        endif    

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"pregoeiro": "' + Self:cIdentModPCP + '"'
        cParamJson += '}'

    elseif nMetodo == 5 //RDC
        cParamJson := '{'
        cParamJson += '"id":"' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto":"' + oCo1:GetValue("CO1_OBJETO") + '",'
        cParamJson += '"numeroProcessoInterno":"' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso":' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ","
        cParamJson += '"anoProcesso":'   + oCo1:GetValue("CO1_ANOAB") + ","
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"),"00:00:00") + '",'
        cParamJson += '"dataFinalPropostas":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"dataLimiteImpugnacao":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLINP"),"00:00:00") + '",'
        cParamJson += '"dataAberturaPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTABPR"),"00:00:00") + '",'
        cParamJson += '"dataLimiteEsclarecimento":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLIES"),"00:00:00") + '",'
        cParamJson += '"orcamentoSigiloso":' + iif(oCo1:GetValue("CO1_ORCSIG") =="1","true","false")   + ","

        cParamJson += '"exclusivoMPE":' + iif(oCo1:GetValue("CO1_MEEPP") =="1","true","false")  + ","
        cParamJson += '"aplicar147":'   + iif(oCo1:GetValue("CO1_APL147") =="1","true","false") + ","
        cParamJson += '"beneficioLocal":' + iif(oCo1:GetValue("CO1_BENELO") =="1","true","false") + ","
        cParamJson += '"exigeGarantia":' + iif(oCo1:GetValue("CO1_EXIGEG") =="1","true","false") + "," 

        cParamJson += '"permiteCadastroReserva":' + iif(oCo1:GetValue("CO1_CADRES") =="1","true","false") + "," 

        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'

        cParamJson += '"tratamentoFaseLance":' + oCo1:GetValue("CO1_FASELA") + ","
        if  oCo1:GetValue("CO1_FASELA") == "1"
            cParamJson += '"tipoIntervaloLance":' + oCo1:GetValue("CO1_INTERL") + ","
            cParamJson += '"valorIntervaloLance":' + cValToChar(oCo1:GetValue("CO1_VLINTL")) + ","
        endif

        if lLote 
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"operacaoLote":' +oCo1:GetValue("CO1_OPERLO") + ','
        else
            if nTamCo2 > 1
                cParamJson += '"separarPorLotes": true,'
                cParamJson += '"operacaoLote": 2,' //Disputa por item
            else 
                cParamJson += '"separarPorLotes": false,'
            endif
        endif

        cTpJulg := self:TipoDeJulgamento(5,oCo1:GetValue("CO1_TIPO")) // Tipo de julgamento

        if !lLote //Se for por item
            cParamJson += '"lotes": ['
            cParamJson += '{'
            cParamJson += '"numero": 1,' 
            if nTamCo2 > 1
                cParamJson += '"descricao": "Lote 1",'
            endif

            if oCo1:GetValue("CO1_MEEPP") =="1" .and. oCo1:GetValue("CO1_COTARE") <> "1"
                cParamJson += '"exclusivoMPE": true,'
            endif

            if oCo1:GetValue("CO1_COTARE") =="1" .and. oCo1:GetValue("CO1_MEEPP") <> "1" .and.; 
               oCo1:GetValue("CO1_APL147") =="1"
                cParamJson += '"cotaReservada": true,' 
            endif

            if oCo1:GetValue("CO1_APL147") =="1"
                cParamJson += '"justificativa": "",'
            endif

            if nTamCo2 > 1
                cParamJson += '"tipoJulgamento":' + cTpJulg  + ","
            endif
            cParamJson += '"itens": ['
        
            aSaveLines := FWSaveRows()
            for nI := 1 to nTamCo2
                oCo2:GoLine(nI)

                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                cParamJson += '"numero":' + cValtoChar(nI) + "," 
                cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
               
                cParamJson += '"natureza": '   +  self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                
                if oCo1:GetValue("CO1_APL147") =="1" .and. oCo1:GetValue("CO1_COTARE") =="1"
                    cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT")+oCo2:GetValue("CO2_QTDRSV")) + "," 
                    cParamJson += '"quantidadeCota":' + cValToChar(oCo2:GetValue("CO2_QTDRSV")) + ","
                else 
                    cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT")) + ","
                endif

               cParamJson += '"tipoJulgamento":' + cTpJulg
                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )

            cParamJson += ' ]'
            cParamJson += '}'
            cParamJson += ' ],'
        else //por Lote
            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero": ' + cValToChar(nX) + ',' 
                cParamJson += '"descricao": "' + oCp3:GetValue("CP3_LOTE") + '",'
              
                if oCp3:GetValue("CP3_LOTMPE") =="1" 
                    cParamJson += '"exclusivoMPE": true,'
                endif

                if oCp3:GetValue("CP3_COTARE") =="1" .and. oCo1:GetValue("CO1_APL147") =="1"
                    cParamJson += '"cotaReservada": true,' 
                endif

                if oCo1:GetValue("CO1_APL147") =="1"
                    cParamJson += '"justificativa": "",'
                endif

                cParamJson += '"tipoJulgamento":' + cTpJulg + ","

                cParamJson += '"itens": ['
                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    cParamJson += '"numero":' + cValtoChar(nI) + "," 
                    cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '   +  self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                    cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                
                    if oCo1:GetValue("CO1_APL147") =="1" .and. oCp3:GetValue("CP3_COTARE") =="1"
                        cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT")+oCo2:GetValue("CO2_QTDRSV")) + "," 
                        cParamJson += '"quantidadeCota":' + cValToChar(oCo2:GetValue("CO2_QTDRSV")) + ","
                    else 
                        cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT")) + ","
                    endif

                    cParamJson += '"tipoJulgamento":' + cTpJulg
                    cParamJson += '}'
                next nI
                cParamJson += ' ]'

                cParamJson += '}'
            next nX
            FWRestRows( aSaveLines )
            cParamJson += ' ],'
        endif    

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"pregoeiro": "' + Self:cIdentModPCP + '"'
        cParamJson += '}'

    elseif nMetodo == 6 //Concorrência
        cParamJson := '{'
        cParamJson += '"id":"' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto":"' + oCo1:GetValue("CO1_OBJETO") + '",' 
        cParamJson += '"tipoJulgamento":' + self:TipoDeJulgamento(6,oCo1:GetValue("CO1_TIPO"))  + ","
        cParamJson += '"numeroProcessoInterno":"' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso":' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ","
        cParamJson += '"anoProcesso":'   + oCo1:GetValue("CO1_ANOAB") + "," 
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"),"00:00:00") + '",'
        cParamJson += '"dataFinalPropostas":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"dataLimiteImpugnacao":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLINP"),"00:00:00") + '",'
        cParamJson += '"dataAberturaPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTABPR"),"00:00:00") + '",'
        cParamJson += '"dataLimiteEsclarecimento":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLIES"),"00:00:00") + '",'
        cParamJson += '"orcamentoSigiloso":' + iif(oCo1:GetValue("CO1_ORCSIG") =="1","true","false")   + "," 
        cParamJson += '"exclusivoMPE":' + iif(oCo1:GetValue("CO1_MEEPP") =="1","true","false")  + ","
        cParamJson += '"aplicar147":'   + iif(oCo1:GetValue("CO1_APL147") =="1","true","false") + ","
        
        if oCo1:GetValue("CO1_APL147") =="1" //aplicar147 ==1
            cParamJson += '"benef":' + iif(oCo1:GetValue("CO1_BENELO") =="1","true","false") + ","
        endif
        cParamJson += '"exigeGarantia":' + iif(oCo1:GetValue("CO1_EXIGEG") =="1","true","false") + "," 
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'
        cParamJson += '"tratamentoFaseLance":' + oCo1:GetValue("CO1_FASELA") + ","

        if  oCo1:GetValue("CO1_FASELA") == "1"
            cParamJson += '"tipoIntervaloLance":' + oCo1:GetValue("CO1_INTERL") + ","
            cParamJson += '"valorIntervaloLance":' + cValToChar(oCo1:GetValue("CO1_VLINTL")) + ","
        endif
     
        if lLote
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"operacaoLote": 1,'
        else 
            if nTamCo2 > 1 
                cParamJson += '"separarPorLotes": true,'
                cParamJson += '"operacaoLote": 1,'
            else 
                cParamJson += '"separarPorLotes": false,'
            endif
        endif
        
        if !lLote
            cParamJson += '"lotes": ['
            cParamJson += '{'
            cParamJson += '"numero": 1,' 
            if nTamCo2 > 1 
                cParamJson += '"descricao": "Lote 1",'
            endif
        
            if oCo1:GetValue("CO1_MEEPP") =="1" .and. oCo1:GetValue("CO1_COTARE") <> "1"
                cParamJson += '"exclusivoMPE": true,'
            endif

            if oCo1:GetValue("CO1_COTARE") =="1" .and. oCo1:GetValue("CO1_MEEPP") <> "1" .and.; 
            oCo1:GetValue("CO1_APL147") =="1"
                cParamJson += '"cotaReservada": true,' 
            endif

            if oCo1:GetValue("CO1_APL147") =="1"
                cParamJson += '"justificativa": "",'
            endif
            cParamJson += '"itens": ['
        
            aSaveLines := FWSaveRows()
            for nI := 1 to oCo2:Length()
                oCo2:GoLine(nI)

                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                cParamJson += '"numero":' + cValtoChar(nI) + "," 
                cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
               
                cParamJson += '"natureza": '   +  self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                
                if oCo1:GetValue("CO1_APL147") =="1" .and. oCo1:GetValue("CO1_COTARE") =="1"
                    cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT")+oCo2:GetValue("CO2_QTDRSV")) + "," 
                    cParamJson += '"quantidadeCota":' + cValToChar(oCo2:GetValue("CO2_QTDRSV"))
                else 
                    cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                endif
                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )

            cParamJson += ' ]'
            cParamJson += '}'
            cParamJson += ' ],'
        else 
            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero": ' + cValToChar(nX) + ',' 
                cParamJson += '"descricao": "' + oCp3:GetValue("CP3_LOTE") + '",'
              
                if oCp3:GetValue("CP3_LOTMPE") =="1"
                    cParamJson += '"exclusivoMPE": true,'
                endif

                if oCp3:GetValue("CP3_COTARE") =="1" .and. oCo1:GetValue("CO1_APL147") =="1"
                    cParamJson += '"cotaReservada": true,' 
                endif

                if oCo1:GetValue("CO1_APL147") =="1"
                    cParamJson += '"justificativa": "",'
                endif

                cParamJson += '"itens": ['
                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    cParamJson += '"numero":' + cValtoChar(nI) + "," 
                    cParamJson += '"numeroInterno":' + cValToChar(val(oCo2:GetValue("CO2_ITEM"))) + ','
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '   +  self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                    cParamJson += '"siglaUnidade":"' + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia":' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                
                    if oCo1:GetValue("CO1_APL147") =="1" .and. oCp3:GetValue("CP3_COTARE") =="1"
                        cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT")+oCo2:GetValue("CO2_QTDRSV")) + "," 
                        cParamJson += '"quantidadeCota":' + cValToChar(oCo2:GetValue("CO2_QTDRSV")) 
                    else 
                        cParamJson += '"quantidadeTotal":' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                    endif
                    cParamJson += '}'
                next nI
                cParamJson += ' ]'
                cParamJson += '}'
            next nX
            FWRestRows( aSaveLines )
            cParamJson += ' ],'
        endif    

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"pregoeiro": "' + Self:cIdentModPCP + '"'
        cParamJson += '}'

    elseif nMetodo == 7 //Leilão Eletrônico

        cParamJson := '{'
        cParamJson += '"id": "' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto": "' + oCo1:GetValue("CO1_OBJETO")   + '",'
        cParamJson += '"numeroProcessoInterno": "' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso": ' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ','
        cParamJson += '"anoProcesso": '   + oCo1:GetValue("CO1_ANOAB") + ","
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"),"00:00:00") + '",'
        cParamJson += '"dataFinalPropostas":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"dataLimiteImpugnacao":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLINP"),"00:00:00") + '",'
        cParamJson += '"dataAberturaPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTABPR"),"00:00:00") + '",'
        cParamJson += '"dataLimiteEsclarecimento":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLIES"),"00:00:00") + '",'
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'
        cParamJson += '"tratamentoFaseLance": ' + oCo1:GetValue("CO1_FASELA") + ','

        if  oCo1:GetValue("CO1_FASELA") == "1"
            cParamJson += '"tipoIntervaloLance": ' + oCo1:GetValue("CO1_INTERL") + ','
            cParamJson += '"valorIntervaloLance": ' + cValToChar(oCo1:GetValue("CO1_VLINTL")) + ','
        endif

        cParamJson += '"itens": ['
        aSaveLines := FWSaveRows()
        for nI := 1 to oCo2:Length()
            oCo2:GoLine(nI)
            If nI > 1
                cParamJson += ','
            EndIf
            cParamJson += '{'
            cParamJson += '"numero": ' + cValToChar(nI) + ','
            cParamJson += '"numeroInterno": "' + oCo2:GetValue("CO2_ITEM") + '",'
            cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
            cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
            cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
            cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ','
            cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))
            cParamJson += '}'
        next nI
        FWRestRows( aSaveLines )
        cParamJson += ' ],'

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"leiloeiro": "' + Self:cIdentModPCP + '"'
        cParamJson += '}'
    elseif nMetodo == 8 //Inexibilidade
        cParamJson := '{'
        cParamJson += '"id": "' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto": "' + oCo1:GetValue("CO1_OBJETO")   + '",'
        cParamJson += '"numeroProcessoInterno": "' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso": ' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ','
        cParamJson += '"anoProcesso": '   + oCo1:GetValue("CO1_ANOAB") + "," 
        cParamJson += '"exigeGarantia": ' + iif(oCo1:GetValue("CO1_EXIGEG") =="1","true","false") + ','
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'

        if !lLote
            cParamJson += '"separarPorLotes": ' + iif(nTamCo2 > 1,"true","false") + ','
            cParamJson += '"codigoEnquadramentoJuridico":' + oCo1:GetValue("CO1_ENQJUR") + ","
            cParamJson += '"lotes": ['
            cParamJson += '{'
            cParamJson += '"numero": 1,' 
            cParamJson += '"itens": ['

            aSaveLines := FWSaveRows()
            for nI := 1 to oCo2:Length()
                oCo2:GoLine(nI)
                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                cParamJson += '"numero": ' + cValToChar(nI) + ','
                cParamJson += '"numeroInterno": "' + oCo2:GetValue("CO2_ITEM") + '",'
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ','
                cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))

                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )

            cParamJson += ' ]'
            cParamJson += '}'
            cParamJson += ' ],'
        else
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"operacaoLote":' +oCo1:GetValue("CO1_OPERLO") + ','
            cParamJson += '"codigoEnquadramentoJuridico":' + oCo1:GetValue("CO1_ENQJUR") + ","

            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero": '  + cValToChar(nX) + ','
                cParamJson += '"descricao": "' + AllTrim(oCp3:GetValue("CP3_LOTE")) + '",'

                cParamJson += '"itens": ['
                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    cParamJson += '"numero": ' + cValToChar(nI) + ","
                    cParamJson += '"numeroInterno": "' + oCo2:GetValue("CO2_ITEM") + '",'
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                    cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ","
                    cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))

                    cParamJson += '}'
                next nI
                cParamJson += ' ]'

                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )
            cParamJson += ' ],'
        endif

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"operadorCompraDireta": "' + Self:cIdentModPCP + '"'
        cParamJson += '}'

    elseif nMetodo == 9 //Concurso
        cParamJson := '{'
        cParamJson += '"id": "' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto": "' + oCo1:GetValue("CO1_OBJETO")   + '",'
        cParamJson += '"tipoJulgamento": ' + self:TipoDeJulgamento(9,oCo1:GetValue("CO1_TIPO")) + ','
        cParamJson += '"numeroProcessoInterno": "' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso": ' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ','
        cParamJson += '"anoProcesso": '   + oCo1:GetValue("CO1_ANOAB") + ',' 
        cParamJson += '"dataInicioPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DATARP"),"00:00:00") + '",'
        cParamJson += '"dataFinalPropostas":"'  + FwTimeStamp( 5,oCo1:GetValue("CO1_DTFINP"),"00:00:00") + '",'
        cParamJson += '"dataLimiteImpugnacao":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLINP"),"00:00:00") + '",'
        cParamJson += '"dataAberturaPropostas":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTABPR"),"00:00:00") + '",'
        cParamJson += '"dataLimiteEsclarecimento":"' + FwTimeStamp( 5,oCo1:GetValue("CO1_DTLIES"),"00:00:00") + '",'
        cParamJson += '"exigeGarantia": ' + iif(oCo1:GetValue("CO1_EXIGEG") =="1","true","false") + ','
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'

        cParamJson += '"lotes": ['
        cParamJson += '{'
        cParamJson += '"numero": 1,'
        cParamJson += '"itens": ['

        aSaveLines := FWSaveRows()
        for nI := 1 to oCo2:Length()
            oCo2:GoLine(nI)
            If nI > 1
                cParamJson += ','
            EndIf
            cParamJson += '{'
            cParamJson += '"numero": ' + cValToChar(nI) + ','
            cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
            cParamJson += '"numeroInterno": "' + oCo2:GetValue("CO2_ITEM") + '",'
            cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
            cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
            cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ','
            cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))

            cParamJson += '}'
        next nI
        FWRestRows( aSaveLines )

        cParamJson += ' ]'
        cParamJson += '}'
        cParamJson += ' ],'

        cParamJson += self:GetDocuments(oCo1) //Retorna estrutura json com arquivo anexados ao processo pela base de conhecimento
        cParamJson += '"responsavel": "' + Self:cIdentModPCP + '",'
        cParamJson += '"autoridadeCompetente": "' + Self:cIdentAutoridade + '",'
        cParamJson += '}'

    ElseIf nMetodo == 10 //Credenciamento

        cParamJson := '{'
        cParamJson += '"id": "' + oCo1:GetValue("CO1_CODEDT") + '",'
        cParamJson += '"objeto": "' + oCo1:GetValue("CO1_OBJETO")   + '",'
        cParamJson += '"tipoCredenciamento": 1,'  //Credenciamento Prazo Fixo
        cParamJson += '"numeroProcessoInterno": "' + oCo1:GetValue("CO1_NUMPRO") + '",'
        cParamJson += '"numeroProcesso": ' + cValToChar(Val(oCo1:GetValue("CO1_NUMPRO"))) + ','
        cParamJson += '"anoProcesso": '   + oCo1:GetValue("CO1_ANOAB") + "," 
        cParamJson += '"dataInicioCredenciamento": "' + FwTimeStamp( 5, oCo1:GetValue("CO1_DATARP"), "00:00:00" )   + '",'
        cParamJson += '"dataFimCredenciamento": "' + FwTimeStamp( 5, oCo1:GetValue("CO1_DTFINP"), "00:00:00" )  + '",'
        cParamJson += '"casasDecimais": 2,'
        cParamJson += '"casasDecimaisQuantidade": 2,'
        cParamJson += '"codigoEnquadramentoJuridico":' + oCo1:GetValue("CO1_ENQJUR") + ","
        cParamJson += '"orcamentoSigiloso": ' + iif(oCo1:GetValue("CO1_ORCSIG") =="1","true","false")   + ","
        
        if lLote
            cParamJson += '"separarPorLotes": true,'
        else 
            if nTamCo2 > 1 
                cParamJson += '"separarPorLotes": true,'
            else 
                cParamJson += '"separarPorLotes": false,'
            endif
        endif     
        
        cParamJson += '"responsavel": "' + Self:cIdentModPCP + '",'
        cParamJson += '"autoridadeCompetente": "' + Self:cIdentAutoridade + '",'
       
        if !lLote //Se for por item
            cParamJson += '"separarPorLotes": false,'
            cParamJson += '"itens": ['

            aSaveLines := FWSaveRows()
            for nI := 1 to nTamCo2
                oCo2:GoLine(nI)
                If nI > 1
                    cParamJson += ','
                EndIf
                cParamJson += '{'
                //-- Posiciona SB5
                If SB5->(DbSeek(xFilial("SB5")+oModel:GetValue('CO2DETAIL','CO2_CODPRO')))
                    If !Empty(SB5->B5_CATMAT)
                        cParamJson += '"numeroCatalogo": ' + AllTrim(SB5->B5_CATMAT) + ','
                    EndIf
                EndIf
                cParamJson += '"numero": ' + cValToChar(nI) + ','
                cParamJson += '"numeroInterno": "' + oCo2:GetValue("CO2_ITEM") + '",'
                cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
                cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ','
                cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                If oCo1:GetValue("CO1_COTARE") =="1"
                    cParamJson += ','
                    cParamJson += '"quantidadeCota": ' + cValToChar(oCo2:GetValue("CO2_QTDRSV"))
                endif

                cParamJson += '}'
            next nI
            FWRestRows( aSaveLines )
            cParamJson += ' ]'
        else //por Lote
            cParamJson += '"separarPorLotes": true,'
            cParamJson += '"lotes": ['
            aSaveLines := FWSaveRows()
            for nX := 1 to oCp3:Length()
                oCp3:GoLine(nX)
                If nX > 1
                    cParamJson += ','
                EndIf

                cParamJson += '{'
                cParamJson += '"numero": ' + cValToChar(nX) + ',' 
                cParamJson += '"descricao": "' + oCp3:GetValue("CP3_LOTE") + '",'
                cParamJson += '"itens": ['
                for nI := 1 to oCo2:Length()
                    oCo2:GoLine(nI)
                    If nI > 1
                        cParamJson += ','
                    EndIf
                    cParamJson += '{'
                    //-- Posiciona SB5
                    If SB5->(DbSeek(xFilial("SB5")+oModel:GetValue('CO2DETAIL','CO2_CODPRO')))
                        If !Empty(SB5->B5_CATMAT)
                            cParamJson += '"numeroCatalogo": ' + AllTrim(SB5->B5_CATMAT) + ','
                        EndIf
                    EndIf
                    cParamJson += '"numero": ' + cValToChar(nI) + ','
                    cParamJson += '"numeroInterno": "' + oCo2:GetValue("CO2_ITEM") + '",'
                    cParamJson += '"descricao": "'   + oCo2:GetValue("CO2_DESCR") + '",'
                    cParamJson += '"natureza": '     + self:GetNatureza(oCo2:GetValue("CO2_CODPRO")) + ','
                    cParamJson += '"siglaUnidade": "'   + oCo2:GetValue("CO2_UM") + '",'
                    cParamJson += '"valorReferencia": ' + cValToChar(oCo2:GetValue("CO2_VLESTI")) + ','
                    cParamJson += '"quantidadeTotal": ' + cValToChar(oCo2:GetValue("CO2_QUANT"))
                    If oCp3:GetValue("CP3_COTARE")== "1"
                        cParamJson += ','
                        cParamJson += '"quantidadeCota": ' + cValToChar(oCo2:GetValue("CO2_QTDRSV"))
                    endif

                    cParamJson += '}'
                next nI
                cParamJson += ' ]'

                cParamJson += '}'
            next nX
            FWRestRows( aSaveLines )
            cParamJson += ' ]'
        endif
        cParamJson += '}'
    endif

oCo1 := Nil
oCo2 := Nil
oCp3 := Nil

Return cParamJson

/*/{Protheus.doc} GetObterProcesso
    (Retorna a Natureza do Produto)
    @author Thiago Rodrigues
    @since 06/03/2024
    @version version
/*/


Method GetNatureza(cProduto) Class GCPApiPCP
    local cNatureza  := ""
    Local aAreaSB1   := SB1->(GetArea())

     SB1->(dbSetOrder(1))
    if SB1->(MsSeek(xFilial('SB1') + cProduto))
        if !empty(SB1->B1_TPPROD) 
            cNatureza := "3"  //3 = Medicamento.
        elseif Upper(SB1->B1_TIPO) == "SV" 
            cNatureza := "2" //2 = Serviço
        else  
            cNatureza := "1" //1 = Produto
        endif    
    endif
    RestArea(aAreaSB1)

Return cNatureza

/*/{Protheus.doc} GetDocuments
    Retorna Documentos em anexo para envio da integração
    @author Leonardo Kichitaro
    @since 12/03/2024
    @version version
/*/
Method GetDocuments(oModMaster) Class GCPApiPCP

    Local oFindCO1  := Nil
    Local oFile     := Nil

    Local cQuery    := ""
    Local cAliTmp   := ""
    Local cQryStat  := ""
    Local cDirDocs  := MsDocRmvBar(MsDocPath())
    Local cPathFile := ""
    Local cExtArq   := ""
    Local cJsonArq  := ""

    Local aArea     := FwGetArea()

    cAliTmp := GetNextAlias() 

    oFindCO1 := FWPreparedStatement():New()

    cQuery := " SELECT ACB.ACB_CODOBJ, ACB.ACB_OBJETO, ACB.ACB_DESCRI"
    cQuery += " FROM " + RetSqlName('AC9') + " AC9"
    cQuery += " INNER JOIN " + RetSqlName('ACB') + " ACB ON"
    cQuery += " ACB.ACB_FILIAL = AC9.AC9_FILIAL AND"
    cQuery += " ACB.ACB_CODOBJ = AC9.AC9_CODOBJ"
    cQuery += " WHERE AC9.AC9_FILIAL = ? AND"
    cQuery += " AC9.AC9_ENTIDA = ? AND"
    cQuery += " AC9.AC9_CODENT = ? AND"
    cQuery += " AC9.D_E_L_E_T_ = ? "
    cQuery := ChangeQuery(cQuery)

    oFindCO1:SetQuery(cQuery)

    oFindCO1:SetString(1, FWxFilial("AC9"))
    oFindCO1:SetString(2, "CO1")
    oFindCO1:SetString(3, oModMaster:GetValue("CO1_FILIAL") + oModMaster:GetValue("CO1_CODEDT") + oModMaster:GetValue("CO1_NUMPRO"))
    oFindCO1:SetString(4, Space(1))

    cQryStat := oFindCO1:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)

    While !(cAliTmp)->(Eof())
        cPathFile   := cDirDocs + "\" + AllTrim((cAliTmp)->ACB_OBJETO)
        cExtArq     := ExtractExt(cPathFile)
        cExtArq     := StrTran(cExtArq,".","")

        oFile := FwFileReader():New(cPathFile)

        If oFile:Open()
            cData := oFile:FullRead()
            cData := Encode64(cData)
            oFile:Close()

            If Empty(cJsonArq)
                cJsonArq := '"arquivos": ['
            Else
                cJsonArq += ','
            EndIf
            cJsonArq += '{'
            cJsonArq += '"tipo": "EDI",'
            cJsonArq += '"extensao": "' + Lower(cExtArq) + '",'
            cJsonArq += '"nome": "' + AllTrim((cAliTmp)->ACB_DESCRI) + '",'
            cJsonArq += '"conteudo": "' + cData + '"'
            cJsonArq += '}'
        EndIf

        (cAliTmp)->(DbSkip()) 
    Enddo
    (cAliTmp)->(DbCloseArea())

    If !Empty(cJsonArq)
        cJsonArq += '],'
    EndIf

    FwRestArea(aArea)
    FwFreeArray(aArea)
    FreeObj(oFindCO1)
    FreeObj(oFile)

Return cJsonArq

/*/{Protheus.doc} TipoDeJulgamento
    (De-Para tipo de julgamento)
    @author Thiago Rodrigues
    @since 13/03/2024
    @version version
/*/

Method TipoDeJulgamento(nModalidade,cTipModal) Class GCPApiPCP

    local cTipoJulg := "1"


    if nModalidade == 1 //Pregão

        if cTipModal == "MP" //Menor preço
            cTipoJulg := "1"
        elseif cTipModal == "MO" //Maior oferta de preço
            cTipoJulg := "2"
        elseif cTipModal == "MD" //Maior desconto
            cTipoJulg := "3"
        endif

    elseif nModalidade == 3 .OR. nModalidade == 5  //Dispensa ou RDC

        if cTipModal == "MP" //Menor preço
            cTipoJulg := "1"
        elseif cTipModal == "MD" //Maior desconto
            cTipoJulg := "3"
        endif

    elseif nModalidade == 6 //Concorrencia

        if cTipModal == "MP" //Menor preço
            cTipoJulg := "1"
        elseif cTipModal == "MD" //Maior desconto
            cTipoJulg := "3"
        elseif cTipModal == "TP" //Técnica e preço
            cTipoJulg := "5"
        elseif cTipModal == "MT" //Melhor tecnica
            cTipoJulg := "7"
        endif
        
    elseif nModalidade == 9 //concurso
        if cTipModal == "MT" //Melhor Tecnica
            cTipoJulg := "7"
        elseif cTipModal == "CA" //Melhor Conteudo Artistico
            cTipoJulg := "9"
        endif    
    endif

Return cTipoJulg

/*/{Protheus.doc} GetNextItem
    Retorna Documentos próxima númeração do item do processo para DKG
    @author Leonardo Kichitaro
    @since 26/03/2024
    @version version
/*/
Method GetNextItem(cIdLict) Class GCPApiPCP

    Local oFindDKG  := Nil

    Local cQuery    := ""
    Local cAliTmp   := ""
    Local cNexItem  := StrZero(1, 6)

    Local aArea     := FwGetArea()

    cAliTmp := GetNextAlias() 

    oFindDKG := FWPreparedStatement():New()

    cQuery := " SELECT MAX(DKG_ITEM) AS MAXITEM "
    cQuery += " FROM " + RetSqlName('DKG') + " DKG"
    cQuery += " WHERE DKG.DKG_FILIAL = ? AND"
    cQuery += " DKG.DKG_IDLICT = ? AND"
    cQuery += " DKG.D_E_L_E_T_ = ? "
    cQuery := ChangeQuery(cQuery)

    oFindDKG:SetQuery(cQuery)

    oFindDKG:SetString(1, FWxFilial("DKG"))
    oFindDKG:SetString(2, cValToChar(cIdLict))
    oFindDKG:SetString(3, Space(1))

    cQryStat := oFindDKG:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)

    If (cAliTmp)->(!Eof())
        if !Empty((cAliTmp)->MAXITEM) 
            cNexItem := StrZero((Val((cAliTmp)->MAXITEM) + 1), 6)
        endif
    Endif
    (cAliTmp)->(DbCloseArea())

    FwRestArea(aArea)
    FwFreeArray(aArea)
    FreeObj(oFindDKG)

Return cNexItem

/*/{Protheus.doc} StatusInteg
	Valida se os dados informados para integração são válidos

@author Leonardo.Kichitaro
@since 26/03/2024
/*/
Method StatusInteg() Class GCPApiPCP

    Local oRest         := nil
    Local oJsonResp     := Nil
    Local cResource     := ""
    Local cRetJson      := ""
    Local cResProc      := "/usuarios"
    Local lRet          := .T.
    Local cResposta     := ""
    Local lOk           := .F. 

    If !Empty(Self:cPublicKey)
        cResource   := Self:cResourceApi + cResProc

        oRest := FwRest():New(Self:cURLApiPCP)
        oRest:SetPath(cResource)

        oJsonResp := JsonObject():New() 
        lOk := oRest:Get(Self:aHeaderPCP)

        cRetJson := oRest:GetResult()
        oJsonResp:FromJson(cRetJson)

        If !lOk
            If !oJsonResp:GetJsonObject("success")
                If Substr(oRest:GetHTTPCode(), 1, 1) == "4"
                    cResposta := STR0011 + CRLF //"Não foi possível concluir a autenticação no portal de compras públicas: "
                    cResposta += DecodeUTF8(oJsonResp:GetJsonObject("mensagem")) + CRLF //"Verifique se a 'chave pública' está corretamente configurada"
                    cResposta += STR0012

                    Help(nil, nil , STR0001  , nil, cResposta , 1, 0, nil, nil, nil, nil, nil, { ""} ) // "Atenção XXXXXXX"
                    lRet := .F.
                Else
                    If oJsonResp:HasProperty('message')
                        cResposta := DecodeUTF8(oJsonResp:GetJsonObject("message"))
                    Else
                        cResposta := STR0018 //-- Não foi possível se conectar ao servidor.
                    EndIf

                    Help(nil, nil , STR0001  , nil, STR0011 + cResposta , 1, 0, nil, nil, nil, nil, nil, { ""} ) // "Não foi possível concluir a autenticação no portal de compras públicas:"
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    Else
        cResposta := STR0013 //"Para utilizar essa opção, é necessário realizar previamente a configuração no Wizard de integração com o Portal de Compras Públicas."
                   
        Help(nil, nil , STR0001  , nil, cResposta , 1, 0, nil, nil, nil, nil, nil, { ""} ) // "Atenção XXXXXXX"
        lRet := .F.
    EndIf

    //-- Limpa objetos da memória
    FreeObj(oJsonResp)
    FreeObj(oRest)

Return lRet

/*/{Protheus.doc} LogMessage
	Registra mensagem de log

@param  cJson       Texto formato JSON
@param  cMessage    Texto

@author Leonardo.Kichitaro
@since 25/03/2024
/*/
Method LogMessage(cJson, cMessage) Class GCPApiPCP 

	Default cJson := ''
	Default cMessage := ''

	FWLogMsg('WARN',, 'GCPApiPCP', FunName(), '', '01', CRLF + 'GCPApiPCP:JSON: ' + cJson + CRLF + ' GCPApiPCP:MSG: ' + cMessage, 0, 0, {})

Return Nil

/*/{Protheus.doc} GerarDocProcesso
	Realiza geração do documento após a finalização do edital

@author Leonardo.Kichitaro
@since 02/04/2024
/*/
Method GerarDocProcesso() Class GCPApiPCP

    Local lRet  := .T.
    Local cEtapa := ""

    If IsInCallStack("A600GerDoc") //-- Quando executado pelo monitor
        //Posiciona na tabela CO1 caso a chamada seja executada pelo monitor de integração
        CO1->(DbSetOrder(1))
        If DKF->DKF_TPINTG == "1" 
            If !CO1->(dbSeek(FWxFilial("CO1") + DKF->DKF_CODEDT + DKF->DKF_NUMPRO + DKF->DKF_REVISA))
                lRet := .F.
            EndIf
        Else
            lRet := .F.
        Endif
    EndIf

    If lRet
        cEtapa := CO1->CO1_ETAPA
        
        If cEtapa == "AD" .Or. (cEtapa == "HO" .And. CO1->CO1_LEI == "5" )
            GCP200Perm()

            if CO1->CO1_STATUS == "2" //Encerrado, gerou o documento
                RecLock("DKF", .F.)
				DKF->DKF_STATUS := "7"
				DKF->(MsUnlock())
            Endif

            // Se for um edital que retornou do PCP com sessão publica finalizada, com a geração de ATA ativada e estiver na etapa AT
            if (CO1->CO1_STATUS == "F" .and. CO1->CO1_SRP == "1" .and. CO1->CO1_ETAPA == "AT")

                //Remove a integração do edital com o PCP, para dar andamento nas demais etapas para publicação da ATA
                RecLock("CO1", .F.)
				CO1->CO1_STATUS := "1"
                CO1->CO1_INTEGR := "0"
				CO1->(MsUnlock())
                
                RecLock("DKF", .F.)
				DKF->DKF_STATUS := "7" //Seta a legenda de documento gerado
				DKF->(MsUnlock())
            Endif
            
        EndIf
    EndIf

Return Nil


/*/{Protheus.doc} legislacaoAplicavel
    (De-Para lei do protheus para leis do PCP)
    @author Thiago Rodrigues
    @since 29/10/2024
    @version version
/*/

Method legislacaoAplicavel(cLei) Class GCPApiPCP
Local   cLegislacao := ""
Default cLei := ""

Do Case
    Case cLei == "5"
        cLegislacao := "8"  //8 - Lei nº 13.303, de 30 de junho de 2016 – Lei das Estatais.
    Case cLei == "6"
        cLegislacao := "3" //3 - Lei nº 14.133, de 1º de abril de 2021.
    OtherWise
        cLegislacao := cLei
EndCase

return cLegislacao
