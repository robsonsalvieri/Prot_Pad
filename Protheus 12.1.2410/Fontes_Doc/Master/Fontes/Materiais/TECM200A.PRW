#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/
{Protheus.doc} minhasos

Centralizador de serviços do app minhas OS

@author     Alexandre Takaki
@since      07/01/2025
/*/
//------------------------------------------------------------------------------
WSRESTFUL minhasos DESCRIPTION "minhasos" //"minhasos"

    WSMETHOD GET ctrlRotas  DESCRIPTION "Obter endpoint correto da chamada" PATH "ctrlRotas"  PRODUCES APPLICATION_JSON //"Obter endpoint correto da chamada"

END WSRESTFUL

//------------------------------------------------------------------------------
/*/
{Protheus.doc} ctrlRotas

Obter endpoints conforme o ERP

@author     Alexandre Takaki
@since      07/01/2025
/*/
//------------------------------------------------------------------------------
WSMETHOD GET ctrlRotas  WSREST minhasos

    Local oResponse	    := JsonObject():New()
    Local lRet          := .T.
    Local nParam        := 0 // Obter do parâmetro mv_field -- 1==field legado --2=FSM
    Local nX            := 0
    Local aMeuTec       := {}
    Local aFSM          := {}
    Local aEndpoints    := {}

    //Array de endpoints do field legado (Módulo 28)
    aAdd(aMeuTec,   {"Login",                              "attendant",            "GET",  "getAttendant",      "Busca atendente",                                                                                                      ""})
    aAdd(aMeuTec,   {"Agenda",                             "productpages",         "GET",  "productsPages",     "Busca a quantidade de página dos produtos",                                                                            ""})
    aAdd(aMeuTec,   {"Agenda",                             "services",             "GET",  "getService",        "Retorna os serviços da base de dados",                                                                                 ""})
    aAdd(aMeuTec,   {"Agenda",                             "products",             "GET",  "getProduct",        "Retorna uma lista de produtos contendo código e nome do produto",                                                      ""})
    aAdd(aMeuTec,   {"Agenda",                             "agendas",              "GET",  "getSchedule",       "Retorna as ordens de serviço do usuário atual na data requisitada via parâmetros",                                     ""})
    aAdd(aMeuTec,   {"ItensOs > Histórico",                "historical",           "GET",  "getHistoric",       "Retorna o histórico do equipamento a qual a OS faz referência",                                                        ""})
    aAdd(aMeuTec,   {"ItensOs > Histórico > Detalhes",     "historicaldetails",    "GET",  "getDetail",         "Retorna os detalhes da OS listada no histórico do produto",                                                            ""})
    aAdd(aMeuTec,   {"ItensOs",                            "checkupdate",          "GET",  "ckatt",             "Verifica se a OS tem atualizações para enviar, caso retorne com um valor maior que 0 é por que precisa retransmitir",  ""})
    aAdd(aMeuTec,   {"ItensOs",                            "updateos",             "PUT",  "putEnceramento",    "Endpoint chamado ao finalizar uma OS ou ao atualizar uma OS",                                                          ""})
    aAdd(aMeuTec,   {"Fotos",                              "recnophotos",          "GET",  "pagesphoto",        "Retorna o recno de cada arquivo, gravado na tabela TXMEndFragment",                                                    ""})
    aAdd(aMeuTec,   {"Fotos",                              "photo",                "GET",  "photos",            "Retorna a foto solicitada pelo recnoId",                                                                               ""})
    aAdd(aMeuTec,   {"Fotos",                              "file",                 "POST", "file",              "Insere um arquivo na OS solicitada via parâmetro da requisição",                                                       "{'codigoOs': 'cNumOs', 'base64Foto': 'cBase64', 'itemOs': 'cItemOs', 'itemFoto': 'cItemFoto', 'descricaoFoto': 'cDescri', 'tipoArquivo': 'cFileType'}"})
    aAdd(aMeuTec,   {"Atendimento",                        "updatestatus",         "PUT",  "putStatus",         "Requisição feita para atualizar o status da OS",                                                                       ""})
    aAdd(aMeuTec,   {"Atendimento",                        "unproductiveos",       "PUT",  "putEnceramento",    "Endpoint chamado ao apontar uma visita improdutiva",                                                                   "{'codigoTecnico': 'CodTec', 'codigoOs': 'numOS', 'codigoAgenda': 'ab7item', 'status': 'statusOs', 'dtIniChegada': 'dtIniChegada', 'hrIniChegada': 'hrIniChegada', 'dtIniEncerra': 'dtIniEncerra', 'hrIniEncerra': 'hrIniEncerra', 'assinatura': 'assinatura', 'responsavel': 'responsavel', 'entidade': 'entida', 'itensOs': 'itensOs', 'numeroItem': 'numeroItem', 'apontamento': 'apontamento', 'requisicao': 'requisicao', 'produtos': 'produtos', 'laudo': 'laudo', 'fotos': 'foto'}"})
    aAdd(aMeuTec,   {"Atendimento",                        "finishos",             "PUT",  "putEnceramento",    "Endpoint chamado ao apontar um encerramento para a OS, seja improdutivo ou não",                                       "{'codigoTecnico': 'CodTec', 'codigoOs': 'numOS', 'codigoAgenda': 'ab7item', 'status': 'statusOs', 'dtIniChegada': 'dtIniChegada', 'hrIniChegada': 'hrIniChegada', 'dtIniEncerra': 'dtIniEncerra', 'hrIniEncerra': 'hrIniEncerra', 'assinatura': 'assinatura', 'responsavel': 'responsavel', 'entidade': 'entida', 'itensOs': 'itensOs', 'numeroItem': 'numeroItem', 'solicitaPeca': 'solicitaPeca', 'apontamento': 'apontamento', 'laudo': 'laudo', 'produtos': 'produtos', 'codProduto': 'produto', 'idUnicoProduto': 'ID', 'quantidadeProduto': 'quantidade', 'servicoProduto': 'servico', 'produtoAnterior': 'produtoant', 'idUnicoProdutoAnterior': 'idant', 'requisicao': 'requisicao', 'idUnicoRequisicao': 'id', 'codRequisicao': 'codigo', 'quantidadeRequisicao': 'quantidade', 'servicoRequisicao': 'codService', 'fotos': 'foto'}"})
    aAdd(aMeuTec,   {"Atendimento",                        "updatesolicitation",   "POST", "postsolicitation",  "Atualizar o atendimento e informar o produto solicitado (Atualiza a solicitação de peça e encerra a mesma)",           ""})
    aAdd(aMeuTec,   {"Laudo",                              "laudo",                "PUT",  "laudo",             "Endpoint chamado ao atualizar o laudo",                                                                                ""})
    aAdd(aMeuTec,   {"Atendimento",                        "requeststock",         "PUT",  "putRequest",        "Serviço para fazer requisição no estoque",                                                                             ""})

    //Array de endpoints do field service novo (FSM - módulo 72)
    aAdd(aFSM,      {"Login",                              "attendant",            "GET",  "atendente",             "Busca atendente",                                                                      ""})
    aAdd(aFSM,      {"Agenda",                             "productpages",         "GET",  "paginasProdutos",       "Busca a quantidade de página dos produtos",                                            ""})
    aAdd(aFSM,      {"Agenda",                             "services",             "GET",  "servico",               "Retorna os serviços da base de dados",                                                 ""})
    aAdd(aFSM,      {"Agenda",                             "products",             "GET",  "produto",               "Retorna uma lista de produtos contendo código e nome do produto",                      ""})
    aAdd(aFSM,      {"Agenda",                             "agendas",              "GET",  "agendas",               "Retorna as ordens de serviço do usuário atual na data requisitada via parâmetros",     ""})
    aAdd(aFSM,      {"Atendimento",                        "updatestatus",         "PUT",  "atualizaStatus",        "Requisição feita para atualizar o status da OS",                                       "{'codigoAgenda': 'codAgenda', 'numeroOS': 'numOs', 'codigoUsuario': 'codProtheus', 'codigoTecnico': 'codTecnico', 'data': 'data', 'hora': 'hora', 'utc': 'utc', 'status': 'situacao', 'origemAcao': 'origem'}"})
    aAdd(aFSM,      {"ItensOs > Histórico",                "historical",           "GET",  "historicoAtendimento",  "Retorna o histórico do equipamento a qual a OS faz referência",                        ""})
    aAdd(aFSM,      {"ItensOs > Histórico > Detalhes",     "historicaldetails",    "GET",  "detalhesAtendimento",   "Retorna os detalhes da OS listada no histórico do produto",                            ""})
    aAdd(aFSM,      {"ItensOs",                            "checkupdate",          "GET",  "requisicaoPecas",       "Retorna o status das requisições do FSM feitas ao estoque",                            "{'numOS': 'cNumOS', 'codigoTecnico': 'cAttendant', 'codigoAgenda': 'cCodAgenda'}"})
    aAdd(aFSM,      {"Fotos",                              "recnophotos",          "GET",  "pagsFotos",             "Retorna o recno de cada arquivo, gravado na tabela JO0",                               ""})
    aAdd(aFSM,      {"Fotos",                              "photo",                "GET",  "fotos",                 "Retorna a foto solicitada pelo recnoId",                                               ""})
    aAdd(aFSM,      {"Fotos",                              "file",                 "POST", "arquivo",               "Insere um arquivo na OS solicitada via parâmetro da requisição",                       "{'codigoAgenda': 'cNumAgenda', 'base64Foto': 'cBase64', 'descricaoFoto': 'cDescri', 'tipoArquivo': 'cFileType'}"})
    aAdd(aFSM,      {"Laudo",                              "laudo",                "PUT",  "laudo",                 "Endpoint chamado ao atualizar o laudo",                                                "{'codigoLaudo': 'cCodigo', 'laudoAlterado': 'cNewLaudo'}"})
    aAdd(aFSM,      {"Atendimento",                        "unproductiveos",       "PUT",  "visitaImprodutiva",     "Endpoint chamado ao apontar uma visita improdutiva",                                   "{'codigoUsuario': 'codProtheus', 'codigoTecnico': 'CodTec', 'codigoOs': 'numOS', 'codigoAgenda': 'codAgenda', 'status': 'statusOs', 'dtIniChegada': 'dtIniChegada', 'hrIniChegada': 'hrIniChegada', 'dtIniEncerra': 'dtIniEncerra', 'hrIniEncerra': 'hrIniEncerra', 'utc': 'utc', 'itensOs': 'itensOs', 'numeroItem': 'numeroItem', 'apontamento': 'apontamento', 'laudo': 'laudo', 'fotos': 'fotos', 'base64': 'base64', 'descricaoFoto': 'description', 'formatoFoto': 'cFileType'}"})
    aAdd(aFSM,      {"Atendimento",                        "finishos",             "PUT",  "encerramento",          "Endpoint chamado ao finalizar o atendimento",                                          "{'codigoUsuario': 'codProtheus', 'codigoTecnico': 'CodTec', 'codigoOs': 'numOS', 'codigoAgenda': 'codAgenda', 'status': 'statusOs', 'dtIniChegada': 'dtIniChegada', 'hrIniChegada': 'hrIniChegada', 'dtIniEncerra': 'dtIniEncerra', 'hrIniEncerra': 'hrIniEncerra', 'utc': 'utc', 'assinatura': 'assinatura', 'responsavel': 'responsavel', 'itensOs': 'itensOs', 'numeroItem': 'numeroItem', 'solicitaPeca': 'solicitaPeca', 'apontamento': 'apontamento', 'laudo': 'laudo', 'produtos': 'produtos', 'codProduto': 'produto', 'idUnicoProduto': 'id', 'quantidadeProduto': 'quantidade', 'servicoProduto': 'servico', 'produtoAnterior': 'produtoAnt', 'idUnicoProdutoAnterior': 'idAnt', 'requisicao': 'requisicao', 'idUnicoRequisicao': 'id', 'codRequisicao': 'produto', 'quantidadeRequisicao': 'quantidade', 'servicoRequisicao': 'servico', 'fotos': 'fotos', 'base64': 'base64', 'descricaoFoto': 'description', 'formatoFoto': 'cFileType', 'apontamentoHoras': 'apontamentoHoras', 'dataInclusao': 'dataIncl', 'horaIni': 'horaIni', 'horaFim': 'horaFim', 'totalHoras': 'totalHoras', 'codServico': 'codServico', 'codTecnico': 'codTecnico', 'descricao': 'descricao' }"})

    nParam := GetMv("MV_FIELD", .F., 1)

    If nParam == 1
        aEndpoints := aClone(aMeuTec)
    Else
        aEndpoints := aClone(aFSM)
    EndIf

    oResponse['module']     := iif( nParam == 1, 28, 72)
    oResponse['version']    := '1.0' 
    oResponse['mv_field']   := nParam
    oResponse['service']    := iif( nParam==1,"meutecnico","fsmapp" )
    oResponse['paths']      := {}
    
    For nX := 1 To Len(aEndpoints)
        Aadd(oResponse['paths'], JsonObject():New())

        oResponse['paths'][nX]['page']          := aEndpoints[nX][1]
        oResponse['paths'][nX]['action']        := aEndpoints[nX][2]
        oResponse['paths'][nX]['verb']          := aEndpoints[nX][3]
        oResponse['paths'][nX]['endpoint']      := aEndpoints[nX][4]
        oResponse['paths'][nX]['description']   := aEndpoints[nX][5]
        oResponse['paths'][nX]['body']          := aEndpoints[nX][6]
    Next nX    
    
    Self:SetResponse(EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.)))

Return lRet



