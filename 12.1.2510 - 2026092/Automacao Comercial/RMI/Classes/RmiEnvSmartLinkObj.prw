#INCLUDE "TOTVS.CH"

Class RmiEnvSmartLinkObj From RmiEnviaObj
    
    Data cTipo
    Data oSmartLink
    Data oReg
    Data cTenantId
    Data cBody
    Data nQtdReg
    Data indice

    Method New()                                //Metodo construtor da Classe

    Method PreExecucao() 
    Method PosExecucao()
    Method Processa()
    Method Envia()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Evandro Pattaro
@Date    14/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvSmartLinkObj

	_Super:New("SMARTLINK", cProcesso)

	If self:lSucesso
    
        self:SetaProcesso(self:cProcesso)
		self:lLoteIdRet := .F.

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Pré-execução (pode adicionar validações ou inicializações)

@author  Evandro Pattaro
@Date    14/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvSmartLinkObj
    // ...pode adicionar lógica se necessário...
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} New
// Pós-execução (pode adicionar liberações ou logs)

@author  Evandro Pattaro
@Date    14/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method PosExecucao() Class RmiEnvSmartLinkObj
    // ...pode adicionar lógica se necessário...
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Processa: lê todos os dados recebidos e concatena no cBody, depois envia

@author  Evandro Pattaro
@Date    14/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa(aStDados,cFilPub) Class RmiEnvSmartLinkObj

    Local nI
    Local cChave := ""
    
    Self:oReg    := JsonObject():New()
    Self:cBody   := ""
    Self:nQtdReg := Len(aStDados)
        
    For nI := 1 To Self:nQtdReg
        cChave       := aStDados[nI][5]
        Self:indice  := aStDados[nI][12] // Pega o indice do primeiro registro (todos são iguais)
        Self:oReg:FromJson(aStDados[nI][6])

        Self:oReg["tabela"]     := Self:cTabela
        Self:oReg["processo"]   := Self:cProcesso
        Self:oReg["uuid"]       := aStDados[nI][10]
        Self:oReg["chave"]      := cChave
        Self:cBody += Self:oReg:ToJson() + ","
    Next
    
    If !Empty(Self:cBody)
        Self:cBody := SubStr(Self:cBody, 1, Len(Self:cBody) - 1) // Remove última vírgula
        Self:Envia()
    EndIf
    FwFreeObj(Self:oReg)
    Self:nQtdReg := 0
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Envia: envia o conteúdo de cBody, sem laço

@author  Evandro Pattaro
@Date    14/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvSmartLinkObj

    Local cMsg := ""
    Local cTempo := fwTimeStamp(5, Date(), TimeFull())
    Local oSmartLink := FwTotvsLinkClient():New(.T.)
    Local cTipo := Self:oConfProce["tipo"]
    Local lStruct := IIF(Self:oConfProce:hasProperty("vldStruct") .AND. Self:oConfProce["vldStruct"],'true','false')
    Local cTenantId := oSmartLink:GetTenantClient()

    If Empty(cTenantId)
        self:lSucesso := .F.
    EndIf

    If self:lSucesso
        BeginContent Var cMsg
            {
                "specversion": "1.0",
                "time": "%Exp:cTempo%",
                "type": "%Exp:cTipo%",
                "tenantId": "%Exp:cTenantId%",
                "vldStruct": %Exp:lStruct%,
                "indiceCampos": "%Exp:Self:indice%",
                "data": [ %Exp:Self:cBody% ]
            }
        EndContent
        
        Self:lSucesso := oSmartLink:SendAudience(cTipo, "LinkProxy", cMsg)
        
    EndIf
    
    If !Self:lSucesso
        cMsg := "Quantidade de itens não enviados ("+cValtochar(Self:nQtdReg)+") - "+oSmartLink:getError() + " Verificar a conexão e configuração do TenantId no SmartLink." 
        ljxjMsgErr("ERRO: " + cMsg)
        rmiGrvLog(  "3"  ,self:oReg["tabela"] ,, "ENVIA",;
                        cMsg, /*lRegNew*/   , /*lTxt*/          , /*cFilStatus*/    ,;
                        .F., /*nIndice*/, cTempo , Self:cProcesso   ,;
                        "SMARTLINK" , AllTrim(cTenantId))
    Else
        Conout(TimeFull()+" RmienvSmartLink - Mensagem enviada com sucesso. Total de registros: "+cValtochar(Self:nQtdReg) )
        LjGrvLog("RmienvSmartLink", "Mensagem enviada com sucesso. Conteúdo Enviado: ", cMsg)
    EndIf

Return
