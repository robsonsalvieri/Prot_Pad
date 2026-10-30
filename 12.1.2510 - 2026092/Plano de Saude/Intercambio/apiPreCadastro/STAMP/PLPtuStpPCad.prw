#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLPtuStpPCad
Classe STAMP do Pre cadastro do Beneficiario

@author Gabriel Mucciolo
@since 12/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Class PLPtuStpPCad From PLMapGrvPed

	// Dados para o Envio Especifico
    Data cCodEmpDe As String
    Data cCodEmpAte As String
    Data cMatricDe As String
    Data cMatricAte As String
    Data cDataDe As String
    Data cDataAte As String
    
    Method New() Constructor
	Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp)
    Method GetQuery()
	Method GetQueryEsp()
    Method SetDadosEsp(lPergunte, cCodEmpDe, cCodEmpAte, cMatricDe, cMatricAte, cDataDe, cDataAte)
    
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Gabriel Mucciolo
@since 12/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method New() Class PLPtuStpPCad

    _Super:New()
    self:cClasseStamp := "PLPtuStpPCad" 
    self:cTabPrimaria := "BA1" 
	self:cCodEmpDe := ""
    self:cCodEmpAte := ""
    self:cMatricDe := ""
    self:cMatricAte := ""
    self:cDataDe := ""
    self:cDataAte := ""

Return self


//----------------------------------------------------------
/*/{Protheus.doc} Setup
Configuração da Integração

@author Gabriel Mucciolo
@since 21/07/2021
@version Protheus 12
/*/
//----------------------------------------------------------
Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp) Class PLPtuStpPCad

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

@author Gabriel Mucciolo
@since 12/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method GetQuery() Class PLPtuStpPCad

    Local nQueryRet := 0
    Local aTabelas := {}
    Local cConcatQuery := IIF(AllTrim(TCGetDB()) $ "ORACLE|DB2|POSTGRES", '||', '+')
  
  
    self:cQuery := "SELECT (BA1_CODINT "+cConcatQuery+" BA1_CODEMP "+cConcatQuery+" BA1_MATRIC "+cConcatQuery+" BA1_TIPREG "+cConcatQuery+" BA1_DIGITO) CHAVE, "
    self:cQuery += " ' ' AS DATA "
    self:cQuery += "FROM "+RetSQLName("BA1")+" BA1 "	
	self:cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"'"
	self:cQuery += "	AND BA1.BA1_CODINT = '"+self:cOperadora+"'"
	self:cQuery += "	AND BA1.D_E_L_E_T_= ' ' AND BA1.BA1_DATBLO = ' ' AND  BA1.BA1_PTUCAD = '0' "
	self:cQuery += "	AND (" + self:FilterStamp("BA1") + " ) "
	
    nQueryRet := TCSQLEXEC(self:cQuery)
 
    If nQueryRet < 0
        aTabelas := {"BA1"}
        self:AddStampBase(aTabelas)
    Endif

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQueryEsp
Query especifica para buscar o Cadastro de Beneficiários

@author Gabriel Mucciolo
@since 12/01/2023
@version Protheus 12
/*/
//----------------------------------------------------------
Method GetQueryEsp() Class PLPtuStpPCad
    Local cConcatQuery := IIF(self:cBanco $ "ORACLE|DB2|POSTGRES", '||', '+')
  
    self:cQuery := "SELECT (BA1_CODINT "+cConcatQuery+" BA1_CODEMP "+cConcatQuery+" BA1_MATRIC "+cConcatQuery+" BA1_TIPREG "+cConcatQuery+" BA1_DIGITO) AS CHAVE, "
    self:cQuery += " ' ' AS DATA "
    self:cQuery += "FROM "+RetSQLName("BA1")+" BA1 "
    self:cQuery += "  WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"'"
    //pergunte
	self:cQuery += "	AND BA1.BA1_CODINT = '"+self:cOperadora+"'"
    //Empresa De/Ate
    self:cQuery += "    AND BA1.BA1_CODEMP >= '"+self:cCodEmpDe+"'"
    self:cQuery += "    AND BA1.BA1_CODEMP <= '"+self:cCodEmpAte+"'"
    //Matricula De/Ate
    self:cQuery += "    AND BA1.BA1_MATRIC >= '"+self:cMatricDe+"'"
    self:cQuery += "    AND BA1.BA1_MATRIC <= '"+self:cMatricAte+"'"
    //Data Inclusao De/Ate
    self:cQuery += "    AND BA1.BA1_DATINC >= '"+DToS(self:cDataDe)+"'"
    self:cQuery += "    AND BA1.BA1_DATINC <= '"+DToS(self:cDataAte)+"'"
    
	self:cQuery += "	AND BA1.D_E_L_E_T_= ' ' AND BA1.BA1_DATBLO = ' ' AND  BA1.BA1_PTUCAD = '0'"

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosEsp
Set os dados utilizados na Query Especifica

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Protheus 12
/*/
//----------------------------------------------------------
Method SetDadosEsp(lPergunte, cCodEmpDe, cCodEmpAte, cMatricDe, cMatricAte, cDataDe, cDataAte) Class PLPtuStpPCad

    Default lPergunte := .F.
    Default cCodEmpDe := ""
    Default cCodEmpAte := ""
    Default cMatricDe := ""
    Default cMatricAte := ""
    Default cDataDe := ""
    Default cDataAte := ""
    
    If lPergunte
        self:cCodEmpDe := IIF(!Empty(MV_PAR01), MV_PAR01, "") 
        self:cCodEmpAte := IIF(!Empty(MV_PAR02), MV_PAR02, "") 
        self:cMatricDe := IIF(!Empty(MV_PAR03), MV_PAR03, "") 
        self:cMatricAte := IIF(!Empty(MV_PAR04), MV_PAR04, "") 
        self:cDataDe := IIF(!Empty(MV_PAR05), MV_PAR05, "") 
        self:cDataAte := IIF(!Empty(MV_PAR06), MV_PAR06, "") 
    Else
        self:cCodEmpDe := cCodEmpDe
        self:cCodEmpAte := cCodEmpAte
        self:cMatricDe := cMatricDe
        self:cMatricAte := cMatricAte
        self:cDataDe := cDataDe
        self:cDataAte := cDataAte
    EndIf

    self:GetQueryEsp()

Return