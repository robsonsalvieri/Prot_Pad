#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacDetalhe
    Classe auxiliar que define atributos e métodos referentes às informações sobre detalhes dos pacotes retornados da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transações Unimed - PTU Versão 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacDetalhe
    Data nTpComposicao    As Numeric            // tp_composicao Tipo da Composição              | N    | 1    | M | 1 = Taxas e Gases
                                                //                                               |      |      |   | 2 = Diárias
                                                //                                               |      |      |   | 4 = Materiais de Consumo
                                                //                                               |      |      |   | 5 = Medicamentos
                                                //                                               |      |      |   | 6 = Procedimentos
                                                //                                               |      |      |   | 7 = OPME
    Data nTpTabela        As Numeric            // tp_tabela     Identifica o Tipo de Tabela     | N    | 01   | O | 0 = Rol de Procedimentos Unimed
                                                //                                               |      |      |   | 1 = Serviços Hospitalares / Taxas / Complementos (Tabela C – Anexo 01)
                                                //                                               |      |      |   | 2 = TNUMM Materiais (Tabela E – Anexo 01)
                                                //                                               |      |      |   | 3 = TNUMM Medicamentos (Tabela D – Anexo 01)
                                                //                                               |      |      |   | 5 = TUSS Materiais
                                                //                                               |      |      |   | 6 = TUSS Medicamentos
    Data cCdItem          As String             // cd_item        Código do Item                 | N    | 08   | O | 
    Data cDsItem          As String             // ds_item        Descrição do Item              | ANS+ | 200  | O | 
    Data nQtServico       As Numeric            // qt_servico     Quantidade de Serviço          | N    | 4,4  | O | 
    Data nVlServico       As Numeric            // vl_servico     Valor do Serviço               | N    | 12,2 | O | Obs: separador das casas decimais deve ser “.” (ponto)
    Data nVlTotal         As Numeric            // vl_total       Valor total do item principal  | N    | 12,2 | M | Nota: Campo VL_SERVICO multiplicado pelo campo QT_SERVIÇO Obs: separador das casas decimais deve ser “.” (ponto)
    Data nUnidadeMedida   As Numeric            // unidade_medida Descrição da Unidade de Medida | N    | 03   | O | Conforme tabela X2 – Anexo 01
    Data cDsUnidadeMedida As String             // 

    Method New(oDetalheJson)
    Method toArray()
EndClass

/*/{Protheus.doc} SisPacDetalhe:New()
    Construtor de objetos da Classe auxiliar SisPacDetalhe
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(oItemJson) Class SisPacDetalhe
    self:nTpComposicao    := oItemJson['tp_composicao']
    self:nTpTabela        := oItemJson['tp_tabela']
    self:cCdItem          := IIf(ValType(oItemJson['cd_item']) == "N", cValtoChar(oItemJson['cd_item']), oItemJson['cd_item'])
    self:cDsItem          := oItemJson['ds_item']
    self:nQtServico       := oItemJson['qt_servico']
    self:nVlServico       := oItemJson['vl_servico']
    self:nVlTotal         := oItemJson['vl_total']
    self:nUnidadeMedida   := oItemJson['unidade_medida']
    self:cDsUnidadeMedida := oItemJson['ds_unidade_medida']
Return

/*/{Protheus.doc} SisPacDetalhe:toArray()
    Retorna objetos da Classe auxiliar SisPacDetalhe em forma de array
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method toArray() Class SisPacDetalhe
    Local aRet := {}
    aRet := {;
        self:nTpComposicao    ,;
        self:nTpTabela        ,;
        self:cCdItem          ,;
        self:cDsItem          ,;
        self:nQtServico       ,;
        self:nVlServico       ,;
        self:nVlTotal         ,;
        self:nUnidadeMedida   ,;
        self:cDsUnidadeMedida ;
    }
Return aRet