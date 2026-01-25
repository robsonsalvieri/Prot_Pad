#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacReq
    Classe auxiliar que define atributos e métodos referentes às requisições do client da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transações Unimed - PTU Versão 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacReq
    Data cCdUniOri      As String               // cd_uni_ori    | Código Unimed      |  N  | 04 | M | Codificação: Código do Sistema + Cooperativa
                                                //               |                    |     |    |   | de 0001 à 0600 = Singulares
                                                //               |                    |     |    |   | de 0601 à 0650 = Seccionais
                                                //               |                    |     |    |   | de 0651 à 0850 = Entidades Internacionais
                                                //               |                    |     |    |   | de 0851 à 0949 = Intrafederativas
                                                //               |                    |     |    |   | de 0950 à 0990 = Interfederativas/Federação
                                                //               |                    |     |    |   | de 0991 à 0998 = Empresas do Complexo (Seguradora,UAS,etc.)
                                                //               |                    |     |    |   | 0999 = Confederação Nacional
                                                //               |                    |     |    |   | de 1001 à 1600 = Singulares Unicred
                                                //               |                    |     |    |   | de 1950 à 1990 = Centrais Unicred
                                                //               |                    |     |    |   | 1999 = Confederação Unicred
                                                //               |                    |     |    |   | de 2001 à 2999 = Usimeds
    Data cCdPacote      As String               // cd_pacote     | Código do Pacote   |  N  | 10 | O | Nota: Para o PTU A1200 no formato TXT deverá ser informado 8 dígitos. Para o
                                                //               |                    |     |    |   | PTU A1200 no formatao XML deverá ser informado 10 dígitos
    Data cCdItem        As String               // cd_item       | Código de Serviço  |  N  | 10 | O | Nota: Item principal somente poderá ser Honorário Médico
                                                //               | do Item Principal  |     |    |   | ou SADT (Rol de Procedimentos Unimed)
    Data cTpAcomodacao  As String               // tp_acomodação | Tipo de Acomodac.  | NA  | 02 | O | A=Coletiva; B=Individual; C=Não se aplica
    Data cStPacote      As String               // st_pacote     | Status do Pacote   |  N  | 02 | O | 1 - Em construção
                                                //               |                    |     |    |   | 2 - Em análise Administrativo
                                                //               |                    |     |    |   | 3 - Em análise Médico
                                                //               |                    |     |    |   | 4 - Em análise Enfermeiro
                                                //               |                    |     |    |   | 5 - Em análise Supervisor
                                                //               |                    |     |    |   | 6 – Exigência
                                                //               |                    |     |    |   | 7 – Aprovado
                                                //               |                    |     |    |   | 8 - Aprovado com ressalva
                                                //               |                    |     |    |   | 9 - Publicado sem Aprovação
                                                //               |                    |     |    |   | 10 – Reprovado
                                                //               |                    |     |    |   | 11 - Reprovado Vigente
                                                //               |                    |     |    |   | 12 – Cancelado
                                                //               |                    |     |    |   | 13 – Inválido
                                                //               |                    |     |    |   | 14 – Suspenso
                                                //               |                    |     |    |   | 15 – Bloqueado
                                                //               |                    |     |    |   | 16 – Duplicado
                                                //               |                    |     |    |   | 17 - Reajuste em Análise
                                                //               |                    |     |    |   | 18 - Expirado
    Data cCdEspec       As String               // cd_espec      | Código da          |  N  | 02 | O | Nota: Conforme Tabela “A” – Anexo 01
                                                //               | Especialidade      |     |    |   |
    Data cTpPacote      As String               // tp_pacote     | Tipo do Pacote     |  N  | 02 | O | 3 = SADT
                                                //               |                    |     |    |   | 4 = Hospitalar
                                                //               |                    |     |    |   | 5 = Consulta
                                                //               |                    |     |    |   | 6 = Atendimento Domiciliar
                                                //               |                    |     |    |   | 7 = Saúde Ocupacional
    Data cDtReferencia  As String               // dt_referencia | Data da referência | Dt3 | 10 | O | Nota:
                                                //               |                    |     |    |   | Para autorização: Deverá ser informado a data do pedido da autorização.
                                                //               |                    |     |    |   | Para cobrança: Deverá ser informado a data do atendimento.
                                                //               |                    |     |    |   | O Serviço irá retornar o pacote vigente na data informada. A data de
                                                //               |                    |     |    |   | referência poderá ser igual ou maior que a data inicio de vigência do pacote
                                                //               |                    |     |    |   | OU igual ou menor que a data fim de vigência.
    Data cCdPrest       As String               // cd_prest      | Cód. do Prestador  |  N  | 08 | O | Nota: Campo utilizado para autorização.
    Data cCdCPFCNPJ     As String               // cd_cpf_cnpj   | CNPJ ou CPF Prest. |  N  | 14 | O | Nota: Campo utilizado para cobrança.
    Data nOffset        As Numeric              // offset        | Deslocamento/pág.  |  N  | 02 | O | Quando não informado, será retornado a partir do primeiro pacote (offset = 0)
                                                //               | para pesquisa      |     |    |   |
    Data nLimit         As Numeric              // limit         | Qtd. de registros  |  N  | 03 | O | Quando não informado, será limitado a 10 pacotes. 
                                                //               | a serem retornados |     |    |   |

    Method New(cCodOpe)
    Method setCodOpe(cCodOpe)
    Method setCodPac(cCodPac)
    Method setCdItem(cCdItem)
    Method setTpAcom(cTpAcom)
    Method setStPaco(cStPaco)
    Method setCdEspe(cCdEspe)
    Method setTpPaco(cTpPaco)
    Method setDtRefe(cDtRefe)
    Method setCdPres(cCdPres)
    Method setCpfCnp(cCpfCnp)
    Method setOffset(nOffset)
    Method setLimite(nLimite)
EndClass

/*/{Protheus.doc} SisPacReq:New()
    Construtor de objetos da Classe auxiliar SisPacReq
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(cCodOpe) Class SisPacReq
    self:cCdUniOri     := cCodOpe
    self:cCdPacote     := ""
    self:cCdItem       := ""
    self:cTpAcomodacao := ""
    self:cStPacote     := ""
    self:cCdEspec      := ""
    self:cTpPacote     := ""
    self:cDtReferencia := ""
    self:cCdPrest      := ""
    self:cCdCPFCNPJ    := ""
    self:nOffset       := ""
    self:nLimit        := ""
Return

Method setCodOpe(cCodOpe) Class SisPacReq
    self:cCdUniOri     := cCodOpe
Return

Method setCodPac(cCodPac) Class SisPacReq
    self:cCdPacote     := cCodPac
Return

Method setCdItem(cCdItem) Class SisPacReq
    self:cCdItem     := cCdItem
Return

Method setTpAcom(cTpAcom) Class SisPacReq
    self:cTpAcomodacao     := cTpAcom
Return

Method setStPaco(cStPaco) Class SisPacReq
    self:cStPacote     := cStPaco
Return

Method setCdEspe(cCdEspe) Class SisPacReq
    self:cCdEspec     := cCdEspe
Return

Method setTpPaco(cTpPaco) Class SisPacReq
    self:cTpPacote     := cTpPaco
Return

Method setDtRefe(cDtRefe) Class SisPacReq
    self:cDtReferencia     := cDtRefe
Return

Method setCdPres(cCdPres) Class SisPacReq
    self:cCdPrest     := cCdPres
Return

Method setCpfCnp(cCpfCnp) Class SisPacReq
    self:cCdCPFCNPJ     := cCpfCnp
Return

Method setOffset(nOffset) Class SisPacReq
    self:nOffset     := nOffset
Return

Method setLimite(nLimite) Class SisPacReq
    self:nLimit     := nLimite
Return