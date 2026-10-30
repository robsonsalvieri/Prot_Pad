#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapJsEmpre
Classe para montagem do JSON de Pedidos de Empresas

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
@Obs Utilização na Integração TOTVS Saúde Planos x HealthMap
/*/
//----------------------------------------------------------
Class PLMapJsEmpre From PLMapJson
    
    Data cCodInt As String
    Data cCodEmp As String
    Data lFindEmpre As Boolean

    // Dados do Body do Json
    Data cId As String
    Data cNome As String
    Data cContraSenha As String
    Data cIdExterno As String
    Data cStatus As String
    
    Method New(cChave) Constructor
    Method SetDadosEmpre()
    Method GetJson()
    
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(cChave) Class PLMapJsEmpre

    _Super:New()

    self:cCodInt := Substr(cChave, 1, 4)
    self:cCodEmp := Substr(cChave, 5, 4)
    self:lFindEmpre := .F.

    self:cId := "" 
    self:cNome := ""
    self:cContraSenha := ""
    self:cIdExterno := ""
    self:cStatus := ""

    self:SetDadosEmpre()

Return self


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosEmpre
Alimenta os atributos utilizados na montagem do JSON

@author Rafael Soares da Silva
@since 09/08/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosEmpre() Class PLMapJsEmpre
    
    Local cQuery := ""
    Local cAliasTemp := ""
    
    cAliasTemp := GetNextAlias()
    cQuery := " SELECT BG9_CODIGO, BG9_DESCRI FROM "+RetSqlName("BG9")+" BG9 "
    cQuery += " WHERE BG9_FILIAL = '"+xFilial("BG9")+"'
    cQuery += "   AND BG9_CODINT = '"+self:cCodInt+"' "
    cQuery += "   AND BG9_CODIGO = '"+self:cCodEmp+"' "
    cQuery += "   AND BG9.D_E_L_E_T_= ' ' "
    
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(Eof())

        self:cId := Alltrim(self:cCodEmp)
        self:cNome := Alltrim((cAliasTemp)->BG9_DESCRI)
        self:cContraSenha := ""
        self:cIdExterno := Alltrim(self:cCodEmp)
        self:cStatus := "A"

        self:lFindEmpre := .T.
    
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetJson
Retorna o JSON referente ao Pedido

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetJson() Class PLMapJsEmpre

    Local oResponse := JsonObject():New()
    Local cJson := ""
    Local cChaveEmpresa := self:cCodInt + self:cCodEmp

    If self:lFindEmpre

        oResponse["id"] := self:SetAtributo(self:cId)
        oResponse["nome"] := self:SetAtributo(self:cNome)
        oResponse["contraSenha"] := self:SetAtributo(self:cContraSenha)
        oResponse["idExterno"] := self:SetAtributo(self:cIdExterno)
        oResponse["status"] := self:SetAtributo(self:cStatus)

        cJson := FWJsonSerialize(oResponse, .F., .F.)

        If ExistBlock("PLMPJSEM")
			cJson := ExecBlock("PLMPJSEM", .F., .F., {cChaveEmpresa, cJson})
        EndIf
    EndIf

    FreeObj(oResponse)
    oResponse := Nil
  
Return cJson