#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapStpBenef
Classe STAMP do Cadastro de Beneficiários

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Class PLMapStpBenef From PLMapGrvPed

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
Method New() Class PLMapStpBenef

    _Super:New()
    self:cTabPrimaria := "BA1" 
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
Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp) Class PLMapStpBenef

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
Query para buscar o STAMP do Cadastro de Beneficiários

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQuery() Class PLMapStpBenef

    Local nQueryRet := 0
    Local aTabelas := {}
  
    If self:cBanco $ "ORACLE|DB2|POSTGRES"
        self:cQuery := "SELECT (BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO) CHAVE, " 
    Else
        self:cQuery := "SELECT (BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO) CHAVE, "
    EndIf
    self:cQuery += " (CASE WHEN BA1_DATBLO <> '' THEN BA1_DATBLO ELSE '' END) AS DATA "

    self:cQuery += "FROM "+RetSQLName("BA1")+" BA1 "	
	// Familia
	self:cQuery += " INNER JOIN "+RetSQLName("BA3")+" BA3 " 	
	self:cQuery += "	ON BA3.BA3_FILIAL = '"+xFilial("BA3")+"'" 
	self:cQuery += "	AND BA3.BA3_CODINT = BA1.BA1_CODINT "
	self:cQuery += "	AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
	self:cQuery += "	AND BA3.BA3_MATRIC = BA1.BA1_MATRIC " 
	self:cQuery += "	AND BA3.D_E_L_E_T_ = ' ' "		  		
	// Vidas
	self:cQuery += " INNER JOIN "+RetSQLName("BTS")+" BTS " 	
	self:cQuery += "	ON BTS.BTS_FILIAL = '"+xFilial("BTS")+"'"			
	self:cQuery += "	AND BTS.BTS_MATVID = BA1.BA1_MATVID " 
	self:cQuery += "	AND BTS.D_E_L_E_T_ = ' ' "

	self:cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"'"
	self:cQuery += "	AND BA1.BA1_CODINT = '"+self:cOperadora+"'"
	self:cQuery += "	AND BA1.D_E_L_E_T_= ' ' "
	self:cQuery += "	AND ("
	self:cQuery += self:FilterStamp("BA1") + " OR "
	self:cQuery += self:FilterStamp("BA3") + " OR "
	self:cQuery += self:FilterStamp("BTS")+" )"

    nQueryRet := TCSQLEXEC(self:cQuery)
 
    If nQueryRet < 0
        aTabelas := {"BA1", "BA3", "BTS"}
        self:AddStampBase(aTabelas)
    Endif

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQueryEsp
Query especifica para buscar o Cadastro de Beneficiários

@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQueryEsp() Class PLMapStpBenef

    If self:cBanco $ "ORACLE|DB2|POSTGRES"
        self:cQuery := "SELECT (BA1_CODINT || BA1_CODEMP || BA1_MATRIC || BA1_TIPREG || BA1_DIGITO) AS CHAVE, " 
    Else
        self:cQuery := "SELECT (BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO) AS CHAVE, "
    EndIf
    self:cQuery += " (CASE WHEN BA1_DATBLO <> '' THEN BA1_DATBLO ELSE '' END) AS DATA "

    self:cQuery += "FROM "+RetSQLName("BA1")+" BA1 "
    self:cQuery += "  WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"'"
	self:cQuery += "	AND BA1.BA1_CODINT = '"+self:cOperadora+"'"
    self:cQuery += "    AND BA1.BA1_CODEMP >= '"+self:cCodEmpDe+"' "
    self:cQuery += "    AND BA1.BA1_CODEMP <= '"+self:cCodEmpAte+"' "
	self:cQuery += "	AND BA1.D_E_L_E_T_= ' ' "

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosEsp
Set os dados utilizados na Query Especifica

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosEsp(lPergunte, cCodEmpDe, cCodEmpAte) Class PLMapStpBenef

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