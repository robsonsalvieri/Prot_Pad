#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapStpInter
Classe STAMP do Aviso de Internação

@author Robson Nayland
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Class PLMapStpSocor From PLMapGrvPed

    // Dados para o Envio Especifico
    Data cAnoSocorDe As String
    Data cAnoSocorAte As String
    Data cMesSocorDe As String
    Data cMesSocorAte As String
    Data cNumSocorDe As String
    Data cNumSocorAte As String

    Method New() Constructor
	Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp)
    Method GetQuery()
    Method GetQueryEsp()
    Method SetDadosEsp(lPergunte, cAnoSocor, cMesSocor, cNumSocor)

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Robson Nayland
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method New() Class PLMapStpSocor

    _Super:New()

    self:cTabPrimaria := "BEA" 
 
    self:cAnoSocorDe := ''
    self:cAnoSocorAte:= ''
    self:cMesSocorDe := ''
    self:cMesSocorAte:= ''
    self:cNumSocorDe := ''
    self:cNumSocorAte:= ''

    
Return self


//----------------------------------------------------------
/*/{Protheus.doc} Setup
Configuração da Integração

@author Robson Nayland 
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method Setup(cOperadora, cCodIntegra, cDataStamp, lQueryStamp) Class PLMapStpSocor

	Default cDataStamp := DToS(dDataBase)
    Default lQueryStamp := .F.

    self:cOperadora := cOperadora
    self:cCodIntegracao := cCodIntegra
    self:cDataStamp := cDataStamp

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetQueryEsp
Query especifica para buscar a Internação

@author Robson Nayland
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetQueryEsp() Class PLMapStpSocor

    self:cQuery := IIf( self:cBanco $ "ORACLE|DB2|POSTGRES", "SELECT (BEA_OPEMOV || BEA_ANOAUT || BEA_MESAUT || BEA_NUMAUT) CHAVE, " ,"SELECT (BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT) CHAVE, ")
    self:cQuery += " ' ' AS DATA "

    self:cQuery += "FROM "+RetSQLName("BEA")+" BEA "
    self:cQuery += "  WHERE BEA.BEA_FILIAL = '"+xFilial("BEA")+"'"
	self:cQuery += "	AND BEA.BEA_OPEMOV = '"+self:cOperadora+"'"

    self:cQuery += "    AND BEA.BEA_ANOAUT >= '"+self:cAnoSocorDe+"' "
    self:cQuery += "    AND BEA.BEA_ANOAUT <= '"+self:cAnoSocorAte+"' "

    self:cQuery += "    AND BEA.BEA_MESAUT >= '"+self:cMesSocorDe+"' "
    self:cQuery += "    AND BEA.BEA_MESAUT <= '"+self:cMesSocorAte+"' "

    self:cQuery += "    AND BEA.BEA_NUMAUT >= '"+self:cNumSocorDe+"' "
    self:cQuery += "    AND BEA.BEA_NUMAUT <= '"+self:cNumSocorAte+"' "

    self:cQuery += "    AND BEA.BEA_DATPRO <> ' ' "
	self:cQuery += "	AND BEA.D_E_L_E_T_ = ' ' "

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosEsp
Set os dados utilizados na Query Especifica

@author Robson Nayland
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosEsp(lPergunte, cAnoSocor, cMesSocor, cNumSocor) Class PLMapStpSocor

    Default lPergunte := .F.
    Default cAnoSocor := ""
    Default cMesSocor := ""
    Default cNumSocor := ""
    
    If lPergunte
        self:cAnoSocorDe := IIF(!Empty(MV_PAR01), MV_PAR01, "")
        self:cAnoSocorAte := IIF(!Empty(MV_PAR02), MV_PAR02, "")
        self:cMesSocorDe := IIF(!Empty(MV_PAR03), MV_PAR03, "")
        self:cMesSocorAte := IIF(!Empty(MV_PAR04), MV_PAR04, "")
        self:cNumSocorDe := IIF(!Empty(MV_PAR05), MV_PAR05, "")
        self:cNumSocorAte := IIF(!Empty(MV_PAR06), MV_PAR06, "")
    Else
        self:cAnoSocorDe := cAnoSocor
        self:cAnoSocorAte := cAnoSocor
        self:cMesSocorDe := cMesSocor
        self:cMesSocorAte := cMesSocor
        self:cNumSocorDe := cNumSocor
        self:cNumSocorAte := cNumSocor
    EndIf

    self:GetQueryEsp()

Return