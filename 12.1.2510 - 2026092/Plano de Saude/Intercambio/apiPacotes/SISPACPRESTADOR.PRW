#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SisPacPrestador
    Classe auxiliar que define atributos e métodos referentes às informações sobre prestadores dos pacotes retornados da API REST
        Sistema de Pacotes (SISPAC) da Unimed Brasil de acordo com Protocolo de Transações Unimed - PTU Versão 1.0 MS.104 Rev.01
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Class SisPacPrestador
    Data cNmPrest         As String             // nm_prest    | Nome do Prestador              | ANS+ | 60 | M | Nome do Prestador
    Data cCdPrest         As String             // cd_prest    | Código do Prestador            | N    | 08 | M | Código do Prestador
    Data cCdCPFCNPJ       As String             // cd_cpf_cnpj | CPF/CNPJ                       | N    | 14 | M | CPF ou CNPJ do Prestador

    Method New(oPresJson)
    Method toArray()
EndClass

/*/{Protheus.doc} SisPacPrestador:New()
    Construtor de objetos da Classe auxiliar SisPacPrestador
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method New(oPresJson) Class SisPacPrestador
    self:cNmPrest   := oPresJson['nm_prest']
    self:cCdPrest   := oPresJson['cd_prest']
    self:cCdCPFCNPJ := oPresJson['cd_cpf_cnpj']
Return

/*/{Protheus.doc} SisPacPrestador:toArray()
    Retorna objetos da Classe auxiliar SisPacPrestador em forma de array
    @author Thiago Paris
    @since 03/07/2020
    @version 1.0
    /*/
Method toArray() Class SisPacPrestador
    Local aRet := {}
    aRet := {;
        self:cNmPrest   ,;
        self:cCdPrest   ,;
        self:cCdCPFCNPJ ;
    }
Return aRet