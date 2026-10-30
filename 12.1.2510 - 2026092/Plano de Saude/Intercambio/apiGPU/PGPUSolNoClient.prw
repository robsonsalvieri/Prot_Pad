#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PGPUSolNoClient
Classe para Enviar uma mensagem para a Unimed responsável pela área 
de atuação informada pelo "não cliente".
 
@author Vinicius Queiros Teixeira
@since 26/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Class PGPUSolNoClient From PLRN395GPU

    // Dados do Cabeçalho
    Data cCodUniOri As String
	Data cCodUniDes As String
	Data cNumRegAns As String
	Data cNumTraPre As String
	Data dDataGer As Date
	Data cIdUsuario As String
    // Dados do Body
    Data cTipoSolic As String
    Data cNomeEmpresa As String
    Data cNomeSolic As String
    Data cCPF As String
    Data cCNPJ As String
    Data cDDD As String
    Data cTelefone As String
    Data cEmail As String
    Data cUF As String
    Data cCidade As String
    Data cTipManif As String
    Data cTipCateg As String
    Data cSubCateg As String
    Data nNrVidas As Numeric
    Data cPlanoSaude As String 
    Data cPlanoAtual As String
    Data cFaixaEtaria As String
    Data cEstDependentes As String
    Data cMsgPlano As String
    Data cModalidade As String
    Data nSinistralidade As Numeric
    Data cIDResposta As String 
    Data cMsgLivre As String
    // Dados da Resposta
    Data cNumProtocolo As String
    Data nIdErro As Numeric
    Data lStatus As Boolean
    Data cJsonResp As String

    Method New()
    Method procSolic(cJson, aAuto)
    Method GrvSolic()
    Method jsonResp()
    
EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
Classe Construtora
 
@author Vinicius Queiros Teixeira
@since 26/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method New() Class PGPUSolNoClient
    
    _Super:new()

    self:cCodUniOri := ""
	self:cCodUniDes := ""
	self:cNumRegAns := ""
	self:cNumTraPre := ""
	self:dDataGer := CToD(" / / ")
	self:cIdUsuario := ""

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
    self:cTipManif := ""
    self:cTipCateg := ""
    self:cSubCateg := ""
    self:nNrVidas := 0
    self:cPlanoSaude := "" 
    self:cPlanoAtual := ""
    self:cFaixaEtaria := ""
    self:cEstDependentes := ""
    self:cMsgPlano := ""
    self:cModalidade := ""
    self:nSinistralidade := 0
    self:cIDResposta := "" 
    self:cMsgLivre := ""

    self:cNumProtocolo := ""
    self:nIdErro := 0
    self:lStatus := .F.
    self:cJsonResp := ""

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procSolic
Processa Solicitação
 
@author Vinicius Queiros Teixeira
@since 26/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method procSolic(cJson, aAuto) Class PGPUSolNoClient

    Local oRequest := JsonObject():New()
    Local aFaixaEtaria := {}

    Default aAuto := {.F.,""}

    self:impLog("Solicitar Protocolo de Atendimento – Não cliente - GPU", .F.)
    self:impLog("Json Recebido: "+cJson)

    oRequest:FromJSON(cJson)

    //Cabecalho
    self:setVarCab(oRequest, @self:cCodUniOri, @self:cCodUniDes, @self:cNumRegAns, @self:cNumTraPre, @self:dDataGer, @self:cIdUsuario, @self:cVersao)

    self:cTipoSolic := self:GetAtributo(oRequest["solicitar_protocolo"]["tp_solicitante"])
    self:cNomeEmpresa := self:GetAtributo(oRequest["solicitar_protocolo"]["nome_empresa"])
    self:cNomeSolic := self:GetAtributo(oRequest['solicitar_protocolo']['nome_solicitante'])
	self:cCPF := self:GetAtributo(oRequest['solicitar_protocolo']['cd_cpf'])
    self:cCNPJ := self:GetAtributo(oRequest['solicitar_protocolo']['cd_cnpj'])
	self:cDDD := self:GetAtributo(oRequest['solicitar_protocolo']['ddd'])
	self:cTelefone := self:GetAtributo(oRequest['solicitar_protocolo']['telefone'])
    self:cUF := self:GetAtributo(oRequest['solicitar_protocolo']['cd_uf'])
    self:cCidade := self:GetAtributo(oRequest['solicitar_protocolo']['cd_cidade'])
	self:cEmail := self:GetAtributo(oRequest['solicitar_protocolo']['email'])
	self:cTipManif := self:GetAtributo(oRequest['solicitar_protocolo']['tp_manifestacao'])
	self:cTipCateg := self:GetAtributo(oRequest['solicitar_protocolo']['tp_categoria_manifestacao'])

    if valtype(oRequest['solicitar_protocolo']['tp_sub_categoria']) == "A" 
        self:cSubCateg := self:GetAtributo(oRequest['solicitar_protocolo']['tp_sub_categoria'])
    endif

    self:nNrVidas := self:GetAtributo(oRequest['solicitar_protocolo']['nr_vidas'], "N")
    self:cPlanoSaude := self:GetAtributo(oRequest['solicitar_protocolo']['tp_plano'])
    self:cPlanoAtual := self:GetAtributo(oRequest['solicitar_protocolo']['plano_atual'])
    aFaixaEtaria := oRequest['solicitar_protocolo']['faixa_etaria']

    If ValType(aFaixaEtaria) == "A" .And. Len(aFaixaEtaria) > 0
        self:cFaixaEtaria := self:GetAtributo(aFaixaEtaria[1]['faixa_etaria'])
    EndIf

    self:cEstDependentes := self:GetAtributo(oRequest['solicitar_protocolo']['id_dependente'])
    self:cMsgPlano := self:GetAtributo(oRequest['solicitar_protocolo']['mensagem_plano'])
    self:cModalidade := self:GetAtributo(oRequest['solicitar_protocolo']['tp_modalidade'])
    self:nSinistralidade := self:GetAtributo(oRequest['solicitar_protocolo']['sinistralidade'], "N")
	self:cIDResposta := self:GetAtributo(oRequest['solicitar_protocolo']['id_resposta'])
	self:cMsgLivre := self:GetAtributo(oRequest['solicitar_protocolo']['mensagem'])
    
    self:GrvSolic() 
    self:jsonResp() // Monta Json de Resposta

    self:impLog("Json de Resposta: "+self:cJsonResp)
    self:impLog("", .F.)
    
Return {self:lStatus, self:cJsonResp}


//-----------------------------------------------------------------
/*/{Protheus.doc} GrvSolic
Grava a Solicitação Protocolo de Atendimento – Não cliente

@author Vinicius Queiros Teixeira
@since 26/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method GrvSolic() Class PGPUSolNoClient

    If B00->(FieldPos("B00_TPSOLI")) > 0
        self:cNumProtocolo := P773GerPro()

        If Empty(self:cIDResposta)
            self:cIDResposta := "1"
        EndIf

        B00->(RecLock("B00",.T.))

            B00->B00_FILIAL := xFilial("B00")
            B00->B00_COD := self:cNumProtocolo
            B00->B00_STATUS := "1"
            B00->B00_DTPROT := dDataBase
            B00->B00_HRPROT := StrTran(Time(),":","")
            B00->B00_TPENVI := "2"
            B00->B00_INTERC := "1"
            B00->B00_OPESOL := self:cCodUniOri
            B00->B00_TRAPRE := self:cNumTraPre
            B00->B00_CANCEL := "0"
            B00->B00_TIPPRO := "1"
            B00->B00_OPEDES := PlsIntPad()
            B00->B00_MANIF := self:cTipManif
            B00->B00_CATEG := self:cTipCateg
			If B00->(FieldPos("B00_SUBCTG")) > 0
				B00->B00_SUBCTG := self:cSubCateg
			endif
            B00->B00_STAINT := self:cIDResposta
            B00->B00_MSGINT := self:cMsgLivre
            B00->B00_USUSOL := self:cIdUsuario
            B00->B00_CONTAT := self:cNomeSolic
            B00->B00_EMAILD := self:cEmail
            // Dados Não Cliente
            B00->B00_CPFCLI := self:cCPF
            B00->B00_DDDCLI := self:cDDD
            B00->B00_TELEFO := self:cTelefone
            B00->B00_CODUF := self:cUF
            B00->B00_CODCID := self:cCidade
            B00->B00_TPSOLI := self:cTipoSolic
            B00->B00_NOMEMP := self:cNomeEmpresa
            B00->B00_CNPJCL := self:cCNPJ
            B00->B00_NRVIDA := self:nNrVidas
            B00->B00_PPLANO := self:cPlanoSaude
            B00->B00_PSATUA := self:cPlanoAtual
            B00->B00_FAIETA := self:cFaixaEtaria
            B00->B00_ESTDEP := self:cEstDependentes
            B00->B00_MSGPLA := self:cMsgPlano
            B00->B00_MODPLA := self:cModalidade
            B00->B00_SINPLA := self:nSinistralidade

        B00->(MsUnLock())
	EndIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} jsonResp
Monta json de resposta

@author Vinicius Queiros Teixeira
@since 26/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Method jsonResp() Class PGPUSolNoClient

    Local oResponse := JsonObject():New()
    Local oCabec := JsonObject():New()
    Local oBody := JsonObject():New()    

    //Arquivo processado com sucesso
    If self:nIdErro == 0

        self:cIdUsuario := GetNewPar("MV_PLRESRN", "")

        If Empty(self:cNumRegAns)
            BA0->(DbSetOrder(1))
            If BA0->(MSSeek(xFilial("BA0")+PlsIntPad()))	
                self:cNumRegAns := Alltrim(BA0->BA0_SUSEP)
            EndIf
        EndIf  

        oCabec := self:setCabRes("016", self:cCodUniOri, self:cCodUniDes, self:cNumRegAns, self:cNumTraPre, ,self:cIdUsuario)

        oBody["nr_protocolo"] := self:setAtributo(self:cNumProtocolo)
        oBody["id_resposta"] := self:setAtributo(self:cIDResposta, "N")
        oBody["id_sistema"] := 1 // 1-Sistema próprio da Unimed | 2-Gestão de Protocolos 

        //Monta json completo
        oResponse["cabecalho_transacao"] := oCabec
        oResponse["resposta_solicitar_protocolo_nao_cliente"] := oBody

        self:lStatus := .T.
        self:impLog("Resposta processada com sucesso!")

    Else // Arquivo com erro        
        oResponse["id_Identificador"] := 2 // 1-Confirmado | 2-Conteúdo com erro 
        oResponse["id_erro"] := self:nIdErro

        self:lStatus := .F.
        self:impLog("Resposta com Erro.")
    EndIf

    self:cJsonResp := FWJsonSerialize(oResponse, .F., .F.)

Return
