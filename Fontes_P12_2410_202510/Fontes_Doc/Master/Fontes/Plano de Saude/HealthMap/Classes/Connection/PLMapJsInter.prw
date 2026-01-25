#Include "PROTHEUS.CH"

//----------------------------------------------------------
/*/{Protheus.doc} PLMapJsInter
Classe para montagem do JSON de Aviso de Internações

@author Vinicius Queiros Teixeira
@since 07/10/2021
@version Prothues 12
@Obs Utilização na Integração TOTVS Saúde Planos x HealthMap
/*/
//----------------------------------------------------------
Class PLMapJsInter From PLMapJson
    
    Data cOpeInt As String
    Data cAnoInt As String
    Data cMesInt As String
    Data cNumInt As String
    Data lFindInter As Boolean

    // Dados do Body do Json
    Data cCodigoInternacao As String
    Data cCodigoBeneficiario As String
    Data cCarteirinhaBenef As String
    Data cDataInternacao As String
    Data cDataSaida As String
    Data cCodEspecialidade As String
    Data cDescEspecialidade As String
    
    Method New(cChave) Constructor
    Method SetDadosAvisoInt()
    Method SetEspecialidades(cCodEspecialidade)
    Method GetJson()
    
EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 07/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(cChave) Class PLMapJsInter

    _Super:New()

    self:cOpeInt := Substr(cChave, 1, 4)
    self:cAnoInt := Substr(cChave, 5, 4)
    self:cMesInt := Substr(cChave, 9, 2)
    self:cNumInt := Substr(cChave, 11, 8)
    self:lFindInter := .F.

    self:cCodigoInternacao := ""
    self:cCodigoBeneficiario := ""
    self:cCarteirinhaBenef := ""
    self:cDataInternacao := ""
    self:cDataSaida := ""
    self:cCodEspecialidade := ""
    self:cDescEspecialidade := "" 

    self:SetDadosAvisoInt()

Return self


//----------------------------------------------------------
/*/{Protheus.doc} SetDadosAvisoInt
Alimenta os atributos utilizados na montagem do JSON

@author Vinicius Queiros Teixeira
@since 07/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetDadosAvisoInt() Class PLMapJsInter
    
    Local cQuery := ""
    Local cAliasTemp := ""
    
    cAliasTemp := GetNextAlias()
    cQuery := " SELECT BE4.BE4_OPEUSR, BE4.BE4_CODEMP, BE4.BE4_MATRIC, BE4.BE4_TIPREG, BE4.BE4_DIGITO, "
    cQuery += " BE4.BE4_DATPRO, BE4.BE4_HORPRO, BE4.BE4_DTALTA, BE4.BE4_HRALTA, BE4.BE4_CODESP" 
    cQuery += " FROM "+RetSqlName("BE4")+" BE4 "
    cQuery += " WHERE BE4.BE4_FILIAL = '"+xFilial("BE4")+"'
    cQuery += "   AND BE4.BE4_CODOPE = '"+self:cOpeInt+"' "
    cQuery += "   AND BE4.BE4_ANOINT = '"+self:cAnoInt+"' "
    cQuery += "   AND BE4.BE4_MESINT = '"+self:cMesInt+"' "
    cQuery += "   AND BE4.BE4_NUMINT = '"+self:cNumInt+"' "
    cQuery += "   AND BE4.D_E_L_E_T_= ' ' "
    
    DbUseArea(.T., "TOPCONN",TCGENQRY(,, cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(Eof())

        self:cCodigoInternacao := self:cOpeInt+self:cAnoInt+self:cMesInt+self:cNumInt
        self:cCodigoBeneficiario := Alltrim((cAliasTemp)->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO))
        self:cCarteirinhaBenef := Alltrim((cAliasTemp)->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO))
        self:cDataInternacao := self:FormatDatHora((cAliasTemp)->BE4_DATPRO, (cAliasTemp)->BE4_HORPRO)
        self:cDataSaida := self:FormatDatHora((cAliasTemp)->BE4_DTALTA, (cAliasTemp)->BE4_HRALTA)

        self:SetEspecialidades(Alltrim((cAliasTemp)->BE4_CODESP))
                                    
        self:lFindInter := .T.
    
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetEspecialidades
Seta os atributos da Especialidade da Guia de Internação
no Padrão da TISS

@author Vinicius Queiros Teixeira
@since 28/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetEspecialidades(cCodEspecialidade) Class PLMapJsInter

    Local lRetorno := .F.

    BAQ->(DbSetOrder(1))
    If BAQ->(MsSeek(xFilial("BAQ")+self:cOpeInt+cCodEspecialidade))

        self:cCodEspecialidade := PLSGETVINC("BTU_CDTERM", "BAQ", .F., "24")                                                                                      
        self:cDescEspecialidade := Alltrim(BAQ->BAQ_DESCRI)

        lRetorno := .T.
    EndIf

Return lRetorno


//----------------------------------------------------------
/*/{Protheus.doc} GetJson
Retorna o JSON referente ao Pedido

@author Vinicius Queiros Teixeira
@since 07/10/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetJson() Class PLMapJsInter

    Local oResponse := JsonObject():New()
    Local oEspecialidade := JsonObject():New()
    Local cJson := ""
    Local aListaInternacao := {}
    Local cChaveInternacao := self:cOpeInt + self:cAnoInt + self:cMesInt + self:cNumInt

    If self:lFindInter

        oResponse["codigoExtInternacao"] := self:SetAtributo(self:cCodigoInternacao)
        oResponse["codigoExtBeneficiario"] := self:SetAtributo(self:cCodigoBeneficiario)
        oResponse["carteirinhaBeneficiario"] := self:SetAtributo(self:cCarteirinhaBenef)
        oResponse["dataInternacao"] := self:SetAtributo(self:cDataInternacao)
        oResponse["dataSaida"] := self:SetAtributo(self:cDataSaida)

        oEspecialidade["codigo"] := self:SetAtributo(self:cCodEspecialidade)
        oEspecialidade["descricao"] := self:SetAtributo(self:cDescEspecialidade) 

        oResponse["especialidadeMedica"] := oEspecialidade  

        aAdd(aListaInternacao, oResponse)

        cJson := FWJsonSerialize(aListaInternacao, .F., .F.)

        If ExistBlock("PLMPJSIN")
			cJson := ExecBlock("PLMPJSIN", .F., .F., {cChaveInternacao, cJson})
        EndIf
    EndIf

    FreeObj(oResponse)
    oResponse := Nil

    FreeObj(oEspecialidade)
    oEspecialidade := Nil
  
Return cJson