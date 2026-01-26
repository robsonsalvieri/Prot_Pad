#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapStpInter
Classe STAMP do Aviso de Internação

@author Vinicius Queiros Teixeira
@since 06/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Class PLMapStpInter From PLMapGrvPed

    // Dados para o Envio Especifico
    Data cAnoInteDe As String
    Data cAnoInteAte As String
    Data cMesInteDe As String
    Data cMesInteAte As String
    Data cNumInteDe As String
    Data cNumInteAte As String

    Method New() Constructor
	Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp)
    Method GetQuery()
    Method GetQueryEsp()
    Method SetDadosEsp(lPergunte, cAnoInte, cMesInte, cNumInte)

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 06/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New() Class PLMapStpInter

    _Super:New()

    self:cTabPrimaria := "BE4" 
    self:cAnoInteDe := ""
    self:cAnoInteAte := ""
    self:cMesInteDe := ""
    self:cMesInteAte := ""
    self:cNumInteDe := ""
    self:cNumInteAte := ""
    
Return self


//----------------------------------------------------------
/*/{Protheus.doc} Setup
Configuração da Integração

@author Vinicius Queiros Teixeira
@since 21/07/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp) Class PLMapStpInter

	Default cDataStamp := DToS(dDataBase)
    Default lQueryStamp := .F.

    self:cOperadora := cOperadora
    self:cCodIntegracao := cCodIntegra
    self:cDataStamp := cDataStamp

    If lQueryStamp
	    self:GetQuery()
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQuery
Query para buscar o STAMP do Aviso de Internação

@author Vinicius Queiros Teixeira
@since 06/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQuery() Class PLMapStpInter

    self:cQuery := "" // Stamp não utilizado para essa Integração
    
Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQueryEsp
Query especifica para buscar a Internação

@author Vinicius Queiros Teixeira
@since 06/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQueryEsp() Class PLMapStpInter

    If self:cBanco $ "ORACLE|DB2|POSTGRES"
        self:cQuery := "SELECT (BE4_CODOPE || BE4_ANOINT || BE4_MESINT || BE4_NUMINT) CHAVE, " 
    Else
        self:cQuery := "SELECT (BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT) CHAVE, "
    EndIf
    self:cQuery += " ' ' AS DATA "

    self:cQuery += "FROM "+RetSQLName("BE4")+" BE4 "
    self:cQuery += "  WHERE BE4.BE4_FILIAL = '"+xFilial("BE4")+"'"
	self:cQuery += "	AND BE4.BE4_CODOPE = '"+self:cOperadora+"'"

    self:cQuery += "    AND BE4.BE4_ANOINT >= '"+self:cAnoInteDe+"' "
    self:cQuery += "    AND BE4.BE4_ANOINT <= '"+self:cAnoInteAte+"' "

    self:cQuery += "    AND BE4.BE4_MESINT >= '"+self:cMesInteDe+"' "
    self:cQuery += "    AND BE4.BE4_MESINT <= '"+self:cMesInteAte+"' "

    self:cQuery += "    AND BE4.BE4_NUMINT >= '"+self:cNumInteDe+"' "
    self:cQuery += "    AND BE4.BE4_NUMINT <= '"+self:cNumInteAte+"' "

    self:cQuery += "    AND BE4.BE4_DATPRO <> ' ' "
	self:cQuery += "	AND BE4.D_E_L_E_T_ = ' ' "

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosEsp
Set os dados utilizados na Query Especifica

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosEsp(lPergunte, cAnoInte, cMesInte, cNumInte) Class PLMapStpInter

    Default lPergunte := .F.
    Default cAnoInte := ""
    Default cMesInte := ""
    Default cNumInte := ""
    
    If lPergunte
        self:cAnoInteDe := IIF(!Empty(MV_PAR01), MV_PAR01, "")
        self:cAnoInteAte := IIF(!Empty(MV_PAR02), MV_PAR02, "")
        self:cMesInteDe := IIF(!Empty(MV_PAR03), MV_PAR03, "")
        self:cMesInteAte := IIF(!Empty(MV_PAR04), MV_PAR04, "")
        self:cNumInteDe := IIF(!Empty(MV_PAR05), MV_PAR05, "")
        self:cNumInteAte := IIF(!Empty(MV_PAR06), MV_PAR06, "")
    Else
        self:cAnoInteDe := cAnoInte
        self:cAnoInteAte := cAnoInte
        self:cMesInteDe := cMesInte
        self:cMesInteAte := cMesInte
        self:cNumInteDe := cNumInte
        self:cNumInteAte := cNumInte
    EndIf

    self:GetQueryEsp()

Return