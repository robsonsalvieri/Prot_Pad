#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapJsSocor
Classe para montagem do JSON de Aviso de Socornações

@author Robson Nayland 
@since 01/09/2022
@version Prothues 12
@Obs Utilização na Socoregração TOTVS Saúde Planos x HealthMap
/*/
//----------------------------------------------------------
Class PLMapJsSocor From PLMapJson
    
    Data cOpeSocor As String
    Data cAnoSocor As String
    Data cMesSocor As String
    Data cNumSocor As String
    Data lFindSocor As Boolean

    // Dados do Body do Json
    Data cCodigoSocorre As String
    Data cCodigoBeneficiario As String
    Data cCarteirinhaBenef As String
    Data cDataSocorre As String
    Data cObservacao As String

    
    Method New(cChave) Constructor
    Method SetDadosAvisoSocor()
    Method GetJson()
    
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Robson Nayland
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(cChave) Class PLMapJsSocor

    _Super:New()

    self:cOpeSocor := Substr(cChave, 1, 4)
    self:cAnoSocor := Substr(cChave, 5, 4)
    self:cMesSocor := Substr(cChave, 9, 2)
    self:cNumSocor := Substr(cChave, 11, 8)
    self:lFindSocor := .F.

    self:cCodigoSocorre := ""
    self:cCodigoBeneficiario := ""
    self:cCarteirinhaBenef := ""
    self:cDataSocorre := ""
    self:cObservacao := ""

     self:SetDadosAvisoSocor()

Return self


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosAvisoSocor
Alimenta os atributos utilizados na montagem do JSON

@author Robson Nayland 
@since 01/09/2022
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosAvisoSocor() Class PLMapJsSocor
    
    Local cQuery := ""
    Local cAliasTemp := ""
    
    cAliasTemp := GetNextAlias()
    cQuery := " SELECT BEA.BEA_OPEMOV, BEA.BEA_CODEMP, BEA.BEA_MATRIC, BEA.BEA_TIPREG, BEA.BEA_DIGITO, "
    cQuery += " BEA.BEA_DATPRO, BEA.BEA_HORPRO, BEA.BEA_MSG01  " 
    cQuery += " FROM "+RetSqlName("BEA")+" BEA "
    cQuery += " WHERE BEA.BEA_FILIAL = '"+xFilial("BEA")+"'
    cQuery += "   AND BEA.BEA_OPEMOV = '"+self:cOpeSocor+"' "
    cQuery += "   AND BEA.BEA_ANOAUT = '"+self:cAnoSocor+"' "
    cQuery += "   AND BEA.BEA_MESAUT = '"+self:cMesSocor+"' "
    cQuery += "   AND BEA.BEA_NUMAUT = '"+self:cNumSocor+"' "
    cQuery += "   AND BEA.D_E_L_E_T_= ' ' "
    
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(Eof())

        self:cCodigoSocorre := self:cOpeSocor+self:cAnoSocor+self:cMesSocor+self:cNumSocor
        self:cCodigoBeneficiario := Alltrim((cAliasTemp)->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO))
        self:cCarteirinhaBenef := Alltrim((cAliasTemp)->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO))
        self:cDataSocorre := self:FormatDatHora((cAliasTemp)->BEA_DATPRO, (cAliasTemp)->BEA_HORPRO)
        self:cObservacao:= Alltrim((cAliasTemp)->(BEA_MSG01 ))

                                        
        self:lFindSocor := .T.
    
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return

//----------------------------------------------------------
/*/{Protheus.doc} GetJson
Retorna o JSON referente ao Pedido

@author Vinicius Queiros Teixeira
@since 07/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetJson() Class PLMapJsSocor

    Local oResponse := JsonObject():New()
    Local oEspecialidade := JsonObject():New()
    Local cJson := ""
    Local aListaSocornacao := {}
    Local cChaveSocornacao := self:cOpeSocor + self:cAnoSocor + self:cMesSocor + self:cNumSocor

    If self:lFindSocor

        oResponse["codigoExtProntoSocorro"] := self:SetAtributo(self:cCodigoSocorre)
        oResponse["codigoExtBeneficiario"] := self:SetAtributo(self:cCodigoBeneficiario)
        oResponse["carteirinhaBeneficiario"] := self:SetAtributo(self:cCarteirinhaBenef)
        oResponse["dataProntoSocorro"] := self:SetAtributo(self:cDataSocorre)
        oResponse["observacao"] := self:SetAtributo( self:cObservacao)

    
        aAdd(aListaSocornacao, oResponse)


        cJson := FWJsonSerialize(aListaSocornacao, .F., .F.)

        If ExistBlock("PLMPJSSCR")
			cJson := ExecBlock("PLMPJSSCR", .F., .F., {cChaveSocornacao, cJson})
        EndIf
    EndIf

    FreeObj(oResponse)
    oResponse := Nil

    FreeObj(oEspecialidade)
    oEspecialidade := Nil
  
Return cJson