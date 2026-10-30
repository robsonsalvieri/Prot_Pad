#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacPacote
    Classe auxiliar que define atributos e métodos referentes às informações sobre pacotes retornados da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transações Unimed - PTU Versão 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacPacote 
    Data cCdUniOri        As String             // cd_uni_ori              | Código da Unimed      |  N  | 04   | M | Cód. da Unimed Origem do Pacote.
    Data cNmUniOri        As String             // nm_uni_ori              | Nome da Unimed        |  N  | 04   | M | Nome da Unimed Origem do Pacote.
    Data aPrestadores     As Array              // Dados dos Prestadores   |                       |     |      |   |
    Data cCdItem          As String             // cd_item                 | Código do Item        |  N  | 10   | M | Item principal do pacote
    Data cDsItem          As String             // ds_item                 | Descrição do Item     | ANS+| 200  | M |
    Data nQtServico       As Numeric            // qt_servico              | Quantidade de Serviço |  N  | 4,4  | M |
    Data nVlServico       As Numeric            // vl_servico              | Valor do Serviço      |  N  | 12,2 | O | Obs: separador das casas decimais deve ser “.” (ponto)
    Data nVlTotal         As Numeric            // vl_total                | Valor total do item   |  N  | 12,2 | O | Campo VL_SERVICO multiplicado pelo campo QT_SERVIÇO
                                                //                         | principal             |     |      |   | Obs: separador das casas decimais deve ser “.” (ponto)
    Data cCdPacote        As String             // cd_pacote               | Código do Pacote      |  N  | 10   | M | Para o PTU A1200 no formato TXT deverá ser informado 8 dígitos. Para o PTU A1200 no
                                                //                                                       |      |   | formatao XML deverá ser informado 10 dígitos
    Data cStPacote        As String             // st_pacote               | Status do Pacote      |  N  | 02   | O | 1 - Em construção
                                                //                         |                       |     |      |   | 2 - Em análise Administrativo
                                                //                         |                       |     |      |   | 3 - Em análise Médico
                                                //                         |                       |     |      |   | 4 - Em análise Enfermeiro
                                                //                         |                       |     |      |   | 5 - Em análise Supervisor
                                                //                         |                       |     |      |   | 6 – Exigência
                                                //                         |                       |     |      |   | 7 – Aprovado
                                                //                         |                       |     |      |   | 8 - Aprovado com ressalva
                                                //                         |                       |     |      |   | 9 - Publicado sem Aprovação
                                                //                         |                       |     |      |   | 10 – Reprovado
                                                //                         |                       |     |      |   | 11 - Reprovado Vigente
                                                //                         |                       |     |      |   | 12 – Cancelado
                                                //                         |                       |     |      |   | 13 – Inválido
                                                //                         |                       |     |      |   | 14 – Suspenso
                                                //                         |                       |     |      |   | 15 – Bloqueado
                                                //                         |                       |     |      |   | 16 – Duplicado
                                                //                         |                       |     |      |   | 17 - Reajuste em Análise
                                                //                         |                       |     |      |   | 18 - Expirado
    Data cTpAcomodacao    As String             // tp_acomodação           | Tipo de Acomodac.     | NA  | 02   | O | A=Coletiva; B=Individual; C=Não se aplica
    Data cTpPacote                              // tp_pacote               | Tipo do Pacote        |  N  | 02   | O | 3 = SADT
                                                //                         |                       |     |      |   | 4 = Hospitalar
                                                //                         |                       |     |      |   | 5 = Consulta
                                                //                         |                       |     |      |   | 6 = Atendimento Domiciliar
                                                //                         |                       |     |      |   | 7 = Saúde Ocupacional
    Data cCdEspecialidade                       // cd_espec                | Código da             |  N  | 02   | O | Nota: Conforme Tabela “A” – Anexo 01
    Data cTpInternacao    As String             // tp_internacao           | Tipo de Internação    |  N  | 01   | O | 1- Internação Clínica
                                                //                         |                       |     |      |   | 2- Internação Cirúrgica
                                                //                         |                       |     |      |   | 3- Internação Obstétrica
                                                //                         |                       |     |      |   | 4- Internação Pediátrica
                                                //                         |                       |     |      |   | 5- Internação Psiquiátrica
    Data cDtNegocPacote   As String             // dt_negoc_pacote         | Data da Negociação do | Dt3 | 10   | M |
                                                //                         | Pacote                |     |      |   |
    Data cIndHm           As String             // ind_hm                  | Indicador se o honor. | A   | 01   | M | S – Sim N - Não
                                                //                         | está incluso          |     |      |   |
    Data cIndAnestesia    As String             // ind_anestesista         | Inclui Anestesista    | A   | 01   | M | S – Sim N – Não
    Data cIndAuxiliar     As String             // ind_auxiliar            | Inclui Auxiliar       | A   | 01   | M | S – Sim N – Não
    Data cTpRede          As String             // tp_rede                 | Tipo de Rede          | N   | 01   | O | 1 – Básica 2 – Especial (Tabela Própria) 3 – Master (Alto Custo)
    Data cIndOpme         As String             // ind_opme                | Inclui OPME           | A   | 01   | M | S – Sim N – Não
    Data cDtInicioVig     As String             // dt_inicio_vigencia      | Data Início de Vigên. | Dt3 | 10   | M |
    Data cDtFimVig        As String             // dt_fim_vigencia         | Data Fim de Vigência  | Dt3 | 10   | O |
    Data cDtPublicacao    As String             // dt_publicacao           | Data da Publicação    | Dt3 | 10   | O |
    Data cDtAprovRepro    As String             // dt_aprovacao_reprovacao | Data de aprovação ou  |     |      |   |
                                                //                         | reprovação do pacote  | Dt3 | 10   | O |
    Data nVlPacote        As Numeric            // vl_pacote               | Valor do Pacote       | N   | 12,2 | M | Obs: separador das casas decimais deve ser “.” (ponto)
    Data nVrPacote        As Numeric            // vr_pacote               | Versão do Pacote      | N   | 03   | M |
    Data nVlrMat          As Numeric
    Data nVlrMed          As Numeric 
    Data nVlrOpme         As Numeric
    Data nVlrDiarias      As Numeric
    Data nVlrTaxGas       As Numeric
    Data nVlrProc         As Numeric
    
    Data aOutrosProced    As Array              // Lista de Itens Alternativos
    Data aDetalhes        As Array              // Lista de Composição do Pacote
    //Data cNmPacote        As String           // Campo eliminado na versão mais nova da documentação do Sistema de Pacotes
    Data cEtPacote as character
    Data cIndDiaria as character

    Method New(oPacJson)
    Method toArray()
EndClass

/*/{Protheus.doc} SisPacPacote:New()
    Construtor de objetos da Classe auxiliar SisPacPacote
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(oPacJson) Class SisPacPacote
    Local nI
    self:aPrestadores     := {}
    self:aDetalhes        := {}
    self:aOutrosProced    := {}
    self:cCdUniOri        := oPacJson['cd_uni_ori']
    self:cNmUniOri        := oPacJson['nm_uni_ori']
    For nI := 1 To Len(oPacJson['prestadores'])
        oPrestador := SisPacPrestador():New(oPacJson['prestadores'][nI])
        aAdd(self:aPrestadores, oPrestador:toArray())
    Next
    self:cCdItem          := oPacJson['cd_item']
    self:cDsItem          := oPacJson['ds_item']
    self:nQtServico       := oPacJson['qt_servico']
    self:nVlServico       := oPacJson['vl_servico']
    self:nVlTotal         := oPacJson['vl_total']
    self:cCdPacote        := Alltrim(oPacJson['cd_pacote'])
    self:cStPacote        := oPacJson['st_pacote']
    self:cEtPacote        := oPacJson['et_pacote']
    self:cTpAcomodacao    := oPacJson['tp_acomodacao']
    self:cTpPacote        := oPacJson['tp_pacote']
    self:cCdEspecialidade := oPacJson['cd_especialidade']
    self:cTpInternacao    := oPacJson['tp_internacao']
    self:cDtNegocPacote   := "" // Descontinuado
    self:cIndHm           := oPacJson['ind_hm']
    self:cIndAnestesia    := oPacJson['ind_anestesia']
    self:cIndAuxiliar     := oPacJson['ind_auxiliar']
    self:cTpRede          := oPacJson['tp_rede']
    self:cIndOpme         := oPacJson['ind_opme']
    self:cIndDiaria       := oPacJson['ind_diaria']
    self:cDtInicioVig     := oPacJson['dt_inicio_vigencia']
    self:cDtFimVig        := oPacJson['dt_fim_vigencia']
    self:cDtPublicacao    := oPacJson['dt_publicacao']
    self:cDtPublicacao    := oPacJson['dt_publicacao']
    self:cDtAprovRepro    := oPacJson['dt_aprovacao_reprovacao']
    self:nVlPacote        := oPacJson['vl_pacote']
    self:nVrPacote        := oPacJson['vr_pacote']
    self:nVlrMat          := oPacJson['vl_mat']
    self:nVlrMed          := oPacJson['vl_med']
    self:nVlrOpme         := oPacJson['vl_opme']   
    self:nVlrTaxGas       := oPacJson['vl_tax_gas']
    self:nVlrProc         := oPacJson['vl_proc']
    self:nVlrDiarias      := oPacJson['vl_diarias']

    If ValType(oPacJson['detalhes']) <> "U"
        For nI := 1 To Len(oPacJson['detalhes'])
            oDetalhes := SisPacDetalhe():New(oPacJson['detalhes'][nI])
            aAdd(self:aDetalhes, oDetalhes:toArray())
        Next
    EndIf

    If ValType(oPacJson['outros_procedimentos']) <> "U"
        For nI := 1 To Len(oPacJson['outros_procedimentos'])
            oItemAlter := SisPacItemAlt():New(oPacJson['outros_procedimentos'][nI])
            aAdd(self:aOutrosProced, oItemAlter:toArray())
        Next
    EndIf
Return

/*/{Protheus.doc} SisPacPacote:New()
    Retorna objetos da Classe auxiliar SisPacPacote em forma de array
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method toArray() Class SisPacPacote
    Local aRet := {}
    aRet := {;
        self:cCdUniOri        ,;
        self:cNmUniOri        ,;
        self:aPrestadores     ,;
        self:cCdItem          ,;
        self:cDsItem          ,;
        self:nQtServico       ,;
        self:nVlServico       ,;
        self:nVlTotal         ,;
        self:cCdPacote        ,;
        self:cStPacote        ,;
        self:cTpAcomodacao    ,;
        self:cTpPacote        ,;
        self:cCdEspecialidade ,;
        self:cTpInternacao    ,;
        self:cDtNegocPacote   ,;
        self:cIndHm           ,;
        self:cIndAnestesia    ,;
        self:cIndAuxiliar     ,;
        self:cTpRede          ,;
        self:cIndOpme         ,;
        self:cDtInicioVig     ,;
        self:cDtFimVig        ,;
        self:cDtPublicacao    ,;
        self:cDtAprovRepro    ,;
        self:nVlPacote        ,;
        self:nVrPacote        ,;
        self:aOutrosProced    ,;
        self:aDetalhes        ,;
        self:nVlrMat          ,;
        self:nVlrMed          ,;
        self:nVlrOpme         ,;
        self:nVlrTaxGas       ,;
        self:nVlrProc         ,;
        self:nVlrDiarias      ,;
        self:cEtPacote        ,;
        self:cIndDiaria       ;
    }
Return aRet