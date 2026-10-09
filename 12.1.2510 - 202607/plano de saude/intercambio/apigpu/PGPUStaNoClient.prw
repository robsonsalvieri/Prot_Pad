#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUStaNoClient
Classe para Enviar uma mensagem para a Unimed referente à consulta 
de status de um protocolo existente de um não cliente.
 
@author Vinicius Queiros Teixeira
@since 29/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUStaNoClient From PLRN395GPU

    // Dados do Cabeçalho
    Data cCodUniOri As String
	Data cCodUniDes As String
	Data cNumRegAns As String
	Data cNumTraPre As String
	Data dDataGer As Date
	Data cIdUsuario As String
    // Dados do Body
    Data cNumProtoc As String
    Data cCpf As String
    Data cCnpj As String
    Data cEmail As String
    // Dados da Resposta
    Data cDtSolicit As String
    Data cTipoSolic As String
    Data cNomeEmpresa As String
    Data cNomeSolic As String
    Data cDDD As String
    Data cTelefone As String
    Data cUF As String
    Data cCidade As String
    Data nNrVidas As Numeric
    Data cPlanoSaude As String 
    Data cPlanoAtual As String
    Data cFaixaEtaria As String
    Data cEstDependentes As String
    Data cMsgPlano As String
    Data cModalidade As String
    Data nSinistralidade As Numeric
    Data nIdErro As Numeric
    Data lStatus As Boolean
    Data cJsonResp As String

    Method New()
    Method procSolic(cJson)
    Method consultaProt()
    Method jsonResp()

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author Vinicius Queiros Teixeira
@since 29/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUStaNoClient
    
    _Super:new()

    self:cCodUniOri := ""
	self:cCodUniDes := ""
	self:cNumRegAns := ""
	self:cNumTraPre := ""
	self:dDataGer := CToD(" / / ")
	self:cIdUsuario := ""

    self:cCpf := ""
    self:cCnpj := ""
    self:cEmail := ""
    self:cNumProtoc := ""

    self:cTipoSolic := ""
    self:cNomeEmpresa := ""
    self:cNomeSolic := ""
    self:cCPF := ""
    self:cCNPJ := ""
    self:cDDD := ""
    self:cTelefone := ""
    self:cEmail := ""
    self:cUF := ""
    self:cCidade := ""
    self:nNrVidas := 0
    self:cPlanoSaude := "" 
    self:cPlanoAtual := ""
    self:cFaixaEtaria := ""
    self:cEstDependentes := ""
    self:cMsgPlano := ""
    self:cModalidade := ""
    self:nSinistralidade := 0
    self:nIdErro := 0
    self:lStatus := .F.
    self:cJsonResp := ""

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicitação
 
@author Vinicius Queiros Teixeira
@since 29/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson) Class PGPUStaNoClient

    Local oRequest := JsonObject():New()

    self:impLog("Solicitar Status Protocolo de Atendimento – Não cliente", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:FromJSON(cJson)
    
    //Cabecalho
    self:setVarCab(oRequest, @self:cCodUniOri, @self:cCodUniDes, @self:cNumRegAns, @self:cNumTraPre, @self:dDataGer, @self:cIdUsuario, @self:cVersao)

    self:cCpf := self:GetAtributo(oRequest['solicitar_status_protocolo_nao_cliente']['cd_cpf'])
    self:cCnpj := self:GetAtributo(oRequest['solicitar_status_protocolo_nao_cliente']['cd_cnpj'])
    self:cEmail := self:GetAtributo(oRequest['solicitar_status_protocolo_nao_cliente']['email'])
    self:cNumProtoc := self:GetAtributo(oRequest['solicitar_status_protocolo_nao_cliente']['nr_protocolo'])

	self:consultaProt() 
    self:jsonResp() // Monta Json de Resposta

    self:impLog("Json de Resposta: "+self:cJsonResp)
    self:impLog("", .F.)
 
Return {self:lStatus, self:cJsonResp}


//-----------------------------------------------------------------
/*/{Protheus.doc} consultaProt
Consulta Protocolo Não Cliente
 
@author Vinicius Queiros Teixeira
@since 29/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method consultaProt() Class PGPUStaNoClient

    Local cQuery := ""
    Local cAliasTemp := ""

    cQuery += "SELECT * FROM "+RetSQLName("B00")+" B00 "
    cQuery += " WHERE B00.B00_FILIAL = '"+xFilial("B00")+"'"
	cQuery += "   AND B00.B00_COD = '"+Alltrim(self:cNumProtoc)+"'"
	cQuery += "	  AND B00.D_E_L_E_T_= ' ' "

    cAliasTemp := GetNextAlias()  
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    If (cAliasTemp)->(!Eof())

        self:cTipoSolic := (cAliasTemp)->B00_TPSOLI
        
        If (self:cTipoSolic == "1" .And. Empty(self:cCpf)) .Or.;
           (self:cTipoSolic == "2" .And. Empty(self:cCnpj)) .Or.;
           (self:cTipoSolic == "3" .And. Empty(self:cEmail))

            self:nIdErro := 1 // CPF, CPNJ ou e-mail inexistente
        Else
            self:cDtSolicit := Substr((cAliasTemp)->B00_DTPROT,1,4)+"-"+Substr((cAliasTemp)->B00_DTPROT,5,2)+"-"+;
                                Substr((cAliasTemp)->B00_DTPROT,7,2)+" "+Substr((cAliasTemp)->B00_HRPROT,1,2)+":"+;
                                Substr((cAliasTemp)->B00_HRPROT,3,2)+":00"

            self:cNomeEmpresa := Alltrim((cAliasTemp)->B00_NOMEMP)
            self:cNomeSolic := Alltrim((cAliasTemp)->B00_CONTAT)
            self:cCPF := Alltrim((cAliasTemp)->B00_CPFCLI)
            self:cCNPJ := Alltrim((cAliasTemp)->B00_CNPJCL)
            self:cDDD := Alltrim((cAliasTemp)->B00_DDDCLI)
            self:cTelefone := Alltrim((cAliasTemp)->B00_TELEFO)
            self:cEmail := Alltrim((cAliasTemp)->B00_EMAILD)
            self:cUF := Alltrim((cAliasTemp)->B00_CODUF)
            self:cCidade := Alltrim((cAliasTemp)->B00_CODCID)
            self:nNrVidas := (cAliasTemp)->B00_NRVIDA
            self:cPlanoSaude := Alltrim((cAliasTemp)->B00_PPLANO) 
            self:cPlanoAtual := Alltrim((cAliasTemp)->B00_PSATUA)
            self:cFaixaEtaria := Alltrim((cAliasTemp)->B00_FAIETA)
            self:cEstDependentes := Alltrim((cAliasTemp)->B00_ESTDEP)
            self:cMsgPlano := Alltrim((cAliasTemp)->B00_MSGPLA)
            self:cModalidade := Alltrim((cAliasTemp)->B00_MODPLA)
            self:nSinistralidade := (cAliasTemp)->B00_SINPLA
        EndIf
    Else
        self:nIdErro := 4 // Protocolo informado inexistente
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author Vinicius Queiros Teixeira
@since 29/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp() Class PGPUStaNoClient

    Local oResponse := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()
    Local oFaixaEtaria := JsonObject():New()

    //Arquivo processado com sucesso
    If self:nIdErro == 0

        oCabec := self:setCabRes("020", self:cCodUniOri, self:cCodUniDes, self:cNumRegAns, self:cNumTraPre, self:cDtSolicit)

        oBody["tp_solicitante"] := self:setAtributo(self:cTipoSolic)
        oBody["nome_empresa"] := self:setAtributo(self:cNomeEmpresa)
        oBody["nome_solicitante"] := self:setAtributo(self:cNomeSolic)
        oBody["cd_cpf"] := self:setAtributo(self:cCPF)
        oBody["cd_cnpj"] := self:setAtributo(self:cCNPJ)
        oBody["ddd"] := self:setAtributo(self:cDDD)
        oBody["telefone"] := self:setAtributo(self:cTelefone)
        oBody["email"] := self:setAtributo(self:cEmail)
        oBody["cd_uf"] := self:setAtributo(self:cUF)
        oBody["cd_cidade"] := self:setAtributo(self:cCidade)
        oBody["nr_vidas"] := self:setAtributo(self:nNrVidas)
        oBody["tp_plano"] := self:setAtributo(self:cPlanoSaude)
        oBody["plano_atual"] := self:setAtributo(self:cPlanoAtual)

        If !Empty(self:cFaixaEtaria)
            oFaixaEtaria["faixa_etaria"] := self:setAtributo(self:cFaixaEtaria, "N")
            oFaixaEtaria["nr_vidas"] := self:setAtributo(self:nNrVidas, "N")

            oBody["faixa_etaria"] := {oFaixaEtaria}
        Else
            oBody["faixa_etaria"] := Nil
        EndIf

        oBody["id_dependente"] := self:setAtributo(self:cEstDependentes)
        oBody["mensagem_plano"] := self:setAtributo(self:cMsgPlano)
        oBody["tp_modalidade"] := self:setAtributo(self:cModalidade)
        oBody["sinistralidade"] := self:setAtributo(self:nSinistralidade)
        oBody["id_origem_resposta"] := 1

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        oResponse["resposta_solicitar_status_protocolo_nao_cliente"] := oBody

        self:lStatus := .T.
        self:impLog("Resposta processada com sucesso!")

	Else //Arquivo com erro
        
        oResponse["id_Identificador"] := 2 // 1-Confirmado | 2-Conteúdo com erro 
        oResponse["id_erro"] := self:nIdErro

        self:lStatus := .F.
        self:impLog("Resposta com Erro.")
    EndIf

    self:cJsonResp := FWJsonSerialize(oResponse, .F., .F.)

Return