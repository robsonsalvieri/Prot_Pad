#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapStpEmpre
Classe STAMP do Cadastro de Empresas

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Class PLMapStpEmpre From PLMapGrvPed

    // Dados para o Envio Especifico
    Data cCodEmpDe As String
    Data cCodEmpAte As String

    Method New() Constructor
	Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp)
    Method GetQuery()
    Method GetQueryEsp()
    Method SetDadosEsp(lPergunte, cCodEmpDe, cCodEmpAte)

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New() Class PLMapStpEmpre

    _Super:New()

    self:cTabPrimaria := "BG9" 
    self:cCodEmpDe := ""
    self:cCodEmpAte := ""
    
Return self


//----------------------------------------------------------
/*/{Protheus.doc} Setup
Configuração da Integração

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp) Class PLMapStpEmpre

	Default cDataStamp := DToS(dDataBase)
    Default lQueryStamp := .T.

    self:cOperadora := cOperadora
    self:cCodIntegracao := cCodIntegra
    self:cDataStamp := cDataStamp

    If lQueryStamp
	    self:GetQuery()
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQuery
Query para buscar o STAMP do Cadastro de Empresa

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQuery() Class PLMapStpEmpre

    Local nQueryRet := 0
    Local aTabelas := {}
  
	If self:cBanco $ "ORACLE|DB2|POSTGRES"
        self:cQuery := "SELECT (BG9_CODINT || BG9_CODIGO || BG9_TIPO) AS CHAVE, " 
    Else
        self:cQuery := "SELECT (BG9_CODINT + BG9_CODIGO + BG9_TIPO) AS CHAVE, "
    EndIf
    self:cQuery += " ' ' AS DATA "
    self:cQuery += "FROM "+RetSQLName("BG9")+" BG9 "
    self:cQuery += "  WHERE BG9.BG9_FILIAL = '"+xFilial("BG9")+"'"
	self:cQuery += "	AND BG9.BG9_CODINT = '"+self:cOperadora+"'"
	self:cQuery += "	AND BG9.D_E_L_E_T_ = ' ' "
	self:cQuery += "	AND "
	self:cQuery += self:FilterStamp("BG9")

    nQueryRet := TCSQLEXEC(self:cQuery)
 
    If nQueryRet < 0
        aTabelas := {"BG9"}
        self:AddStampBase(aTabelas)
    Endif

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQueryEsp
Query especifica para buscar o Cadastro de Empresa

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQueryEsp() Class PLMapStpEmpre

    If self:cBanco $ "ORACLE|DB2|POSTGRES"
        self:cQuery := "SELECT (BG9_CODINT || BG9_CODIGO || BG9_TIPO) CHAVE, " 
    Else
        self:cQuery := "SELECT (BG9_CODINT + BG9_CODIGO + BG9_TIPO) CHAVE, "
    EndIf
    self:cQuery += " ' ' AS DATA "

    self:cQuery += "FROM "+RetSQLName("BG9")+" BG9 "
    self:cQuery += "  WHERE BG9.BG9_FILIAL = '"+xFilial("BG9")+"'"
	self:cQuery += "	AND BG9.BG9_CODINT = '"+self:cOperadora+"'"
    self:cQuery += "    AND BG9.BG9_CODIGO >= '"+self:cCodEmpDe+"' "
    self:cQuery += "    AND BG9_CODIGO <= '"+self:cCodEmpAte+"' "
	self:cQuery += "	AND BG9.D_E_L_E_T_ = ' ' "

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosEsp
Set os dados utilizados na Query Especifica

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosEsp(lPergunte, cCodEmpDe, cCodEmpAte) Class PLMapStpEmpre

    Default lPergunte := .F.
    Default cCodEmpDe := ""
    Default cCodEmpAte := ""
    
    If lPergunte
        self:cCodEmpDe := IIF(!Empty(MV_PAR01), MV_PAR01, "") 
        self:cCodEmpAte := IIF(!Empty(MV_PAR02), MV_PAR02, "") 
    Else
        self:cCodEmpDe := cCodEmpDe
        self:cCodEmpAte := cCodEmpAte
    EndIf

    self:GetQueryEsp()

Return